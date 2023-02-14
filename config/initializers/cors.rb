Rails.application.config.middleware.insert_before 0, Rack::Cors do

  # Local Piggy-UI React App
  allow do
    origins 'http://localhost:3000'
    resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options, :head], credentials: true
  end

  # Prod Piggy-UI React App
  # allow do
  #   origins 'http://aws.ec2.piggy.onrails'
  #   resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options, :head], credentials: true
  # end

end