# frozen_string_literal: true

class User < ApplicationRecord
  def self.from_omniauth(auth)
    # Creates a new user only if it doesn't exist
    user = find_or_initialize_by(email: auth.info.email)
    user.name = auth.info.name
    user.email = auth.info.email
    user.token = auth.credentials.token
    user.refresh_token = auth.credentials.refresh_token
    user.expires_at = auth.credentials.expires_at
    user.save! if user.changed?
    user
  end
end
