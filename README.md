Arduinos get more and more connected and I use an Arduino together with a GSM/GPRS shield to build the [wind stations](http://www.blast.nu/products).

But the Arduino is a very limited platform and some (as the [Nano](http://arduino.cc/en/Main/ArduinoBoardNano)) has as little as 1k RAM! Then it becomes a real challenge to do web and HTTP communication. Here I will summarise the experience gathered during the construction of a tiny secure REST client for the Arduino.

## Why REST?
Ruby on Rails is the framework I prefer when it comes to write web applications. It is powerful still quite fast to work with. Rails uses REST a lot and it is definite the easiest way to considering the server-side. Though HTML is quite talkative so lots of strings(which take RAM) will be needed in the Arduino, or clever use of PROGMEM with which we can put the strings in ROM.

## Secure?
What I mainly want to achieve is to make it hard for someone to send/post false information into the Rails application. For the wind stations it does not matter so much but say we use an Arduino for some kind of real world game. Then some clever hacker could quite easily figure out the URL to make a post and then just start posting in actions or whatever the Arduino controls. So we want to make sure those post requests we receive comes from a unit we have put the software inside.

## HMAC
But what kind of authentication should one use? Have read around a bit and regarding REST so seems HMAC(Hash based Message AuthentiCation) a good option and recommended ([http://restcookbook.com/Basics/loggingin/](http://restcookbook.com/Basics/loggingin/)). Also found an Arduino lib that supports HMAC called [Cryptosuite](https://github.com/Cathedrow/Cryptosuite). It seems at first glance to be really memory efficient (uses PROGMEM) but when reading through the code it seems to use about 196 bytes of RAM which is still quite a lot in these circumstances.

## Rails application
Lets start with the Rails application. [API_AUTH](http://github.com/mgomes/api_auth) seems to be a good library to get HMAC support for Rails applications so that was my choice.

Create a new Rails project:
```
rail new ArduinoAuthenticatedClientExample
```

Then using you favourite text editor add API_AUTH to the `Gemfile`:
```ruby
gem 'api-auth'
```

After that do a bundle update to get all gems installed.
```
bundle update
```

Our model is quite simple, we have probes(an Arduino) that can post temperature readings(Measures). So lets create these two:
```
rails generate scaffold Probe name:string secret:string
rails generate scaffold Measure temperature:float
```

We need to setup the relationships between these models, a probe has many measures and measures belongs to probes. In `app/models/probe.rb` add:
```
has_many :measures
```
and in `app/models/measure.rb` add:
```
belongs_to:probe
```

Now give the following command to generate the migration and have it create the needed index in measures:
```
rails generate migration AddProbeRefToMeasures user:references
```

Now it is time to update the database:
```
rake db:migrate
```

Add the following code to `app/controllers/measures_controller.rb` so that all REST calls that modify the model needs to be authenticated using HMAC:
```
# require any kind of change and creation of a measure to come through our authenticated api using HMAC 
# and we skip the CSRF check for these requests
before_action :require_authenticated_api, only: [:edit, :update, :destroy, :create]
skip_before_action :verify_authenticity_token, only: [:edit, :update, :destroy, :create]

def require_authenticated_api
  @current_probe = Probe.find_by_id(ApiAuth.access_id(request))
  logger.info request.raw_post # needed due to a bug in api_auth
  # if a probe could not be found via the access id or the one found did not authenticate with the data in the request
  # fail the call
  if @current_probe.nil? || !ApiAuth.authentic?(request, @current_probe.secret) 
    flash[:error] = "Authentication required"
    redirect_to measures_url, :status => :unauthorized
  end
end 
```

We added a flash error message in the code above so we need to add support in `app/views/layouts/application.html.erb` to get that presented:
```
<% flash.each do |name, msg| -%>
  <%= content_tag :div, msg, class: name %>
<% end -%>
```

We want the secret keys generated automatically rather then entered by the user. So in `app/controllers/probes_controller.rb`, in the create method change so the first lines looks like this:
```
@probe = Probe.new(probe_params)
@probe.secret = ApiAuth.generate_secret_key
```

And we want to remove the input field. Change in `app/views/probes/_form.html.erb` so
```
<%= f.text_field :secret %>
```
becomes
```
<%= @probe.secret %>
```

Now we are almost done but we want to add some more security. We do not want anyone be able to change the secret keys and actually we would like to add user authentication so that like an admin is the only one who ca see the secrets but that is not a task for this tutorial. If you need that see for example the [Devise getting started guide](https://github.com/plataformatec/devise#getting-started). Add the following to app/models/probe.rb so that the secret only can be read and not modified:
```
attr_readonly :secret
```

Now you can run the server and start creating probes. Do
```
> rails server
```
and create a probe or two by going to [http://localhost:3000/probes/](http://localhost:3000/probes/).

To test that is's working create a simple client:
```ruby 
require 'openssl'
require 'rest_client'
require 'date'
require 'api_auth'

@probe_id = "2"
@secret_key = "rNwtKjjVZ4UUTQWvL+ZpK1PVjXz5N1uKpYRCfLfTD+ySTMaeswfPhkokN/ttjX3J78KNqclcYLHSw/mzHeJDow=="
    
headers = { 'Content-Type' => "text/yaml", 'Timestamp' => DateTime.now.httpdate}

@request = RestClient::Request.new(:url => "http://localhost:3000/measures.json",
        :payload => {:measure => { :temperature => 12}},
        :headers => headers,
        :method => :post)
        
@signed_request = ApiAuth.sign!(@request, @probe_id, @secret_key)    

response = @signed_request.execute()
puts "Response " + response.inspect
``` 

And run that and you should get something like:
```
Response “{\"id\":19,\"temperature\":12.0,\"created_at\":\"2014-09-30T15:04:26.286Z\",\"updated_at\":\"2014-09-30T15:04:26.286Z\"}"
```
