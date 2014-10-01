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




