# frozen_string_literal: true

# http://localhost:3000/auth/google_oauth2
class DriveController < ActionController::Base
  require 'google/apis/drive_v3'

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  def index
    # https://drive.google.com/drive/folders/1ZrcMsg9vniVT2FpvjgZseGUG4SartwLz?usp=sharing
    user = User.find(session[:user_id])

    drive_service = Google::Apis::DriveV3::DriveService.new
    drive_service.client_options.application_name = 'DriveMyDoc'
    drive_service.authorization = user.google_authorization

    response = drive_service.list_files(page_size: 10)

    @files = response.files
    render 'drive/index'
  end

  def show
    # http://localhost:3000/drive/1ZrcMsg9vniVT2FpvjgZseGUG4SartwLz
    user = User.find(session[:user_id])

    drive_service = Google::Apis::DriveV3::DriveService.new
    drive_service.client_options.application_name = 'DriveMyDoc'
    drive_service.authorization = user.google_authorization

    file = drive_service.get_file(params[:id], fields: 'id, name, web_content_link, web_view_link')

    # puts file

    @file = file
    # render 'drive/show'

    content = open(file.web_content_link).read
    # require 'github/markup'
    #
    # GitHub::Markup.render(file.name, content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true, safe_links_only: true, escape_html: true, highlight: true), autolink: true, fenced_code_blocks: true)
    @content = markdown.render(content).html_safe # rubocop:disable Rails/OutputSafety
    render 'drive/show'
  end
end
