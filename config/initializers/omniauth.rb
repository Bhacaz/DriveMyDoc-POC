# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'],
           ENV['GOOGLE_CLIENT_SECRET'],
           scope: 'userinfo.email, https://www.googleapis.com/auth/drive.readonly',
           verify_iss: false,
           skip_jwt: true
end
