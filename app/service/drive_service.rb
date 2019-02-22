# frozen_string_literal: true

class DriveService
  attr_accessor :drive_service

  def initialize(user_id)
    user = User.find(user_id)

    require 'google/apis/drive_v3'

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.client_options.application_name = 'DriveMyDoc'
    @drive_service.authorization = user.google_authorization
  end

  def list_files(page_size: 10)
    drive_service.list_files(page_size: page_size).files
  end

  def get_file(id, fields: nil)
    fields ||= 'id, name, web_content_link, web_view_link'
    drive_service.get_file(id, fields: fields)
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
end
