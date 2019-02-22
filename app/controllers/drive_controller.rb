# frozen_string_literal: true

# http://localhost:3000/auth/google_oauth2
class DriveController < ActionController::Base
  before_action :init_drive_service

  def index
    @files_hierarchy = @service.files_hierarchy
    render 'drive/index'
  end

  def show
    @file = @service.get_file(params[:id])
    @content = MarkdownService.render(DriveService.raw_content(@file))
    render 'drive/show'
  end

  def render_list_files(files, html = [])
    t = files.map do |file|
      if file.is_a? Hash
        folder = file.first.first
        files = file.first.second
        temp = ["<li><em> <a href=#{folder.web_view_link} target=\"_blank\">#{folder.name}</a><em/></li>"]
        render_list_files(files, temp)
      else
        href = if file.mime_type.start_with?('text/')
                 "/drive/#{file.id}"
               else
                 "#{file.web_view_link} target=\"_blank\" "
               end
        "<li><img src=#{file.icon_link}/> <a href=#{href}>#{file.name}</a> </li>"
      end
    end
    html << '<ul>'
    html.concat(t)
    html << '</ul>'
  end
  helper_method :render_list_files

  private

  def init_drive_service
    @service = DriveService.new(session[:user_id])
  end
end
