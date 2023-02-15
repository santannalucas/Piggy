require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Piggy
  class Application < Rails::Application
    config.active_record.yaml_column_permitted_classes = [
      Symbol,
      ActiveSupport::HashWithIndifferentAccess,
      ActionController::Parameters
    ]

    config.time_zone = "Sydney"
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.autoload_paths += [config.root.join('app', 'models', 'admins')]
    config.autoload_paths += [config.root.join('app', 'models', 'config')]
    config.autoload_paths += [config.root.join('app', 'models', 'schedulers')]
    config.autoload_paths += [config.root.join('app', 'models', 'tools')]

    config.after_initialize do
      # Refactor Users
      Role.rebuild
    end

  end
end
