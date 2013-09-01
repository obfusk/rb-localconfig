LocalConfig['rails'].configure do |c|
  puts "env: #{c.env}, #{Rails.env}"

  c.require 'init.rb'
  c.load_json 'pg.json'

  c.on_admin_exists do |username|
    false
  end

  c.on_admin_create do |username, password, email|
    # ...
  end
end
