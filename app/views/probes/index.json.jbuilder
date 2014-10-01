json.array!(@probes) do |probe|
  json.extract! probe, :id, :name, :secret
  json.url probe_url(probe, format: :json)
end
