# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += %w( jquery/jquery.js )
Rails.application.config.assets.precompile += %w( jquery/jquery.min.js )
Rails.application.config.assets.precompile += %w( jquery/jquery_ujs.js )
Rails.application.config.assets.precompile += %w( jquery/jquery-ui.js )
Rails.application.config.assets.precompile += %w( jquery/jquery.multiselect.min.js )
Rails.application.config.assets.precompile += %w( batch_selection.js )
Rails.application.config.assets.precompile += %w( indexes.js )
Rails.application.config.assets.precompile += %w( scheduler.js )

# 3RD PARTY CSS

Rails.application.config.assets.precompile += %w( jquery/jquery-ui.custom.css.erb )
Rails.application.config.assets.precompile += %w( jquery/jquery.multiselect.css.erb )


# Applications CSS
Rails.application.config.assets.precompile += %w( dashboard.css transactions.css navbar.css layout.css login.css indexes.css search.css jquery/jquery-ui.custom.css menus.css)


# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
