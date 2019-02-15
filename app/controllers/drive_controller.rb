# frozen_string_literal: true

class DriveController < ActionController::Base
  require 'google/apis/drive_v3'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  def show
    user = User.find(session[:user_id])

    authorization = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: "userinfo.email, drive",
      access_token: user.token,
      refresh_token: user.refresh_token,
      expires_at: user.expires_at
    )

    drive_service = Google::Apis::DriveV3::DriveService.new
    drive_service.client_options.application_name = 'DriveMyDoc'
    drive_service.authorization = authorization

    response = drive_service.list_files(page_size: 10,
                                        fields: 'files(name,modified_time,web_view_link),next_page_token')

    puts response

    render html: response.files.map(&:name).join("<br>")
  end
end
