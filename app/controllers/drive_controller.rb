# frozen_string_literal: true

class DriveController < ActionController::Base
  before_action :init_drive_service
  helper_method :render_list_files, :render_file

  def index
    @root_folder = @service.get_file(ENV['ROOT_FOLDER_ID'])
    @files_hierarchy = @service.files_hierarchy
    @file = nil
    @file = @service.get_file(params[:file_id]) if params[:file_id]
    render 'drive/index'
  end

  def search
    @files_hierarchy = @service.files_hierarchy
    render_list_files(@files_hierarchy)
    @files = @service.search_files(query: params[:query], folder_ids: folder_ids)
    render 'drive/search'
  end

  private

  def render_list_files(files, html = [])
    t = files.map do |file|
      if file.is_a? Hash
        folder = file.first.first
        folder_ids << folder.id
        files = file.first.second
        temp = ["<a href=#{folder.web_view_link} target=\"_blank\" class=\"collection-item folder\">#{folder.name}</a>"]
        render_list_files(files, temp)
      else
        selected = file.id == @file&.id ? 'active' : nil
        "<a href=/drive?file_id=#{file.id} class=\"collection-item #{selected}\"><img src=#{file.icon_link}/>#{file.name}</a>"
      end
    end
    html << '<div class="collection">'
    html.concat(t)
    html << '</div>'
  end

  def render_file
    FileService.viewer_factory(@file)
  end

  def init_drive_service
    @service = DriveService.new(session[:user_id])
  end

  def folder_ids
    @folder_ids ||= []
  end
end
