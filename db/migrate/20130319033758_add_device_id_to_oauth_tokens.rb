class AddDeviceIdToOauthTokens < ActiveRecord::Migration
  def change
    add_column :oauth_tokens, :encrypted_device_key, :string, :limit => 255
  end
end
