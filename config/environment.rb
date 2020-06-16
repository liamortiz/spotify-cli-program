require 'bundler'
Bundler.require

API_CREDS = YAML::load(File.open('config/api.yml')) # Load our API keys
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger = nil

require_all 'lib'
