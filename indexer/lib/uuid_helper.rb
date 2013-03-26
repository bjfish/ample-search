# lib/uuid_helper.rb
require 'uuidtools'

module UUIDHelper
  def before_create()
    self.uuid = UUID.timestamp_create.to_s
  end
end