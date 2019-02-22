# frozen_string_literal: true

# http://localhost:3000/auth/google_oauth2
class DriveController < ActionController::Base
  before_action :init_drive_service

  def index
    # https://drive.google.com/drive/folders/1ZrcMsg9vniVT2FpvjgZseGUG4SartwLz?usp=sharing
    @files = @service.list_files
    render 'drive/index'
  end

  def show
    # http://localhost:3000/drive/1ZrcMsg9vniVT2FpvjgZseGUG4SartwLz

    @file = @service.get_file(params[:id])

    content = open(@file.web_content_link).read
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, autolink: true, fenced_code_blocks: true)
    @content = markdown.render(content).html_safe # rubocop:disable Rails/OutputSafety
    render 'drive/show'
  end

  private

  def init_drive_service
    @service = DriveService.new(session[:user_id])
  end
end
