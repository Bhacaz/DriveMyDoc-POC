# frozen_string_literal: true

class MarkdownViewerService
  def self.render(file)
    raw_content = DriveService.raw_content(file)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, autolink: true, fenced_code_blocks: true)
    "<div class=\"markdown-body\">#{markdown.render(raw_content)} </div>"
  end
end
