LocalConfig['rails'].configure do |c|
  puts "env: #{c.env}, #{Rails.env}"

  c.require 'init.rb'
  c.load_json 'pg.json'

  c.on_admin_exists do |username|
    puts 'exists'
    User.where(name: username).count > 0
  end

  c.on_admin_create do |username, password, email|
    puts 'create'
    User.create! name: username, password: password,
      password_confirmation: password, email: email
  end
end
