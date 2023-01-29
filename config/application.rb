require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VolcanoFin
  class Application < Rails::Application
    config.time_zone = "Sydney"
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoload_paths += [config.root.join('app', 'models', 'admins')]
    config.autoload_paths += [config.root.join('app', 'models', 'config')]
    config.autoload_paths += [config.root.join('app', 'models', 'schedulers')]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
