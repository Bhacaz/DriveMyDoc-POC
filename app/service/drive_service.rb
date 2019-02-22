# frozen_string_literal: true

class DriveService
  attr_accessor :drive_service

  def initialize(user_id)
    require 'google/apis/drive_v3'

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.client_options.application_name = 'DriveMyDoc'
    @drive_service.authorization = google_authorization(user_id)
  end

  def list_files(page_size: 10)
    list_files_query(page_size: page_size).files
  end

  def get_file(id, fields: nil)
    fields ||= 'id, name, web_content_link, web_view_link'
    drive_service.get_file(id, fields: fields)
  end

  def files_hierarchy(parent_id: ENV['ROOT_FOLDER_ID'])
    page_token = nil

    params = {
      q: "'#{parent_id}' in parents",
      order_by: 'folder',
      fields: 'nextPageToken, files(id, name, parents, webViewLink, iconLink, mime_type)'
    }

    params.merge(page_token: page_token) if page_token

    result = drive_service.list_files(**params)
    items = result.files.sort_by(&:name)

    hierarchy = []

    items&.each do |item|
      next if item.name.start_with?('.')

      current_id = item.id

      hierarchy << if item.mime_type == 'application/vnd.google-apps.folder'
                     { item => files_hierarchy(parent_id: current_id) }
                   else
                     item
                   end
    end
    hierarchy
  end

  def self.raw_content(file)
    web_content_link =
      if file.is_a? Google::Apis::DriveV3::File
        file.web_content_link
      else
        file
      end
    URI.open(web_content_link).read
  end

  private

  def google_authorization(user_id)
    user = User.find(user_id)

    scope = 'userinfo.email, drive'
    Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: scope,
      access_token: user.token,
      refresh_token: user.refresh_token,
      expires_at: user.expires_at
    )
  end

  def list_files_query(page_size: 10)
    drive_service.list_files(page_size: page_size)
  end
end
