# frozen_string_literal: true

# http://localhost:3000/auth/google_oauth2
class DriveController < ActionController::Base
  before_action :init_drive_service
  helper_method :render_list_files, :render_file

  def index
    @files_hierarchy = @service.files_hierarchy
    render 'drive/index'
  end

  def show
    @file = @service.get_file(params[:id])
    # @content = FileService.viewer_factory(@file)
    render 'drive/show'
  end

  def search
    @files = @service.search_files(query: params[:query])
    render 'drive/search'
  end

  def render_list_files(files, html = [])
    t = files.map do |file|
      if file.is_a? Hash
        folder = file.first.first
        files = file.first.second
        temp = ["<li><em> <a href=#{folder.web_view_link} target=\"_blank\">#{folder.name}</a></em></li>"]
        render_list_files(files, temp)
      else
        "<li><img src=#{file.icon_link}/> <a href=#{file.id}>#{file.name}</a> </li>"
      end
    end
    html << '<ul>'
    html.concat(t)
    html << '</ul>'
  end

  def render_file
    FileService.viewer_factory(@file)
  end

  private

  def init_drive_service
    @service = DriveService.new(session[:user_id])
  end
end
