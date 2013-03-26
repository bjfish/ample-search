# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#puts 'CREATING ROLES'
#Role.create([
#  { :name => 'owner' }
#], :without_protection => true)
#puts 'SETTING UP DEFAULT USER LOGIN'
#user = User.create! :email => 'user@example.com', :password => 'please', :password_confirmation => 'please'
#puts 'New user created: '
#user2 = User.create! :email => 'user2@example.com', :password => 'please', :password_confirmation => 'please'
#puts 'New user created: '
puts 'CREATING INTGRATIONS'
Integration.create([{:name => 'Trello', :auth_type => 'Custom'},{:name => 'Bitbucket', :auth_type => 'Omniauth'}])