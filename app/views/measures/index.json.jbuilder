json.array!(@measures) do |measure|
  json.extract! measure, :id, :temperature
  json.url measure_url(measure, format: :json)
end
