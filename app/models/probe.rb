class Probe < ActiveRecord::Base
  has_many :measures
  attr_readonly :secret
end
