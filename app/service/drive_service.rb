# frozen_string_literal: true

class DriveService
  attr_accessor :drive_service

  FIELDS = 'nextPageToken, files(id, name, parents, webViewLink, iconLink, mime_type)'

  def initialize(user_id)
    require 'google/apis/drive_v3'

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.client_options.application_name = 'DriveMyDoc'
    @drive_service.authorization = google_authorization(user_id)
  end

  def list_files(**params)
    list_files_query(**params).files
  end

  def get_file(id, fields: nil)
    fields ||= 'id, name, web_content_link, web_view_link'
    drive_service.get_file(
      id,
      fields: fields,
      supports_team_drives: true
    )
  end

  def search_files(query: nil, folder_ids:)
    params = {
      fields: FIELDS,
      page_size: 10,
      supports_team_drives: true,
      include_team_drive_items: true
    }

    text = []
    name = []

    folder_ids.each do |folder_id|
      name.concat list_files(q: "'#{folder_id}' in parents and name contains '#{query}' and trashed = false", **params)
      text.concat list_files(q: "'#{folder_id}' in parents and fullText contains '#{query}' and trashed = false", **params)
    end
    [name, text]
  end

  def files_hierarchy(parent_id: ENV['ROOT_FOLDER_ID'])
    params = {
      q: "'#{parent_id}' in parents and trashed = false",
      order_by: 'folder',
      fields: FIELDS,
      page_size: 1000,
      supports_team_drives: true,
      include_team_drive_items: true
    }

    result = Rails.cache.fetch(parent_id, expires_in: 120.minutes) do
      drive_service.list_files(**params)
    end
    items = result.files.sort_by(&:name)

    hierarchy = []

    items&.each do |item|
      next if item.name.start_with?('.') # hidden file and folders

      current_id = item.id
      hierarchy <<
        if item.mime_type == 'application/vnd.google-apps.folder'
          { item => files_hierarchy(parent_id: current_id) }
        else
          item
        end
    end
    hierarchy.sort_by do |file|
      if file.is_a? Hash
        # If is a Hash it's a folder. Adding "A" before to boost the sorting
        "A#{file.first.first.name}"
      else
        "Z#{file.name}"
      end
    end
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

  def list_files_query(page_size: 1000, **params)
    drive_service.list_files(page_size: page_size, **params)
  end
end
