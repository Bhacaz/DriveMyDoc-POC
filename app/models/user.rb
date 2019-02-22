# frozen_string_literal: true

class User < ApplicationRecord
  def self.from_omniauth(auth)
    # Creates a new user only if it doesn't exist
    where(email: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.expires_at = Time.at.utc(auth.credentials.expires_at)
      user.save!
    end
  end
end
