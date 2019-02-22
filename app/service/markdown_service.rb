# frozen_string_literal: true

class MarkdownService
  def self.render(raw_content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, autolink: true, fenced_code_blocks: true)
    markdown.render(raw_content).html_safe # rubocop:disable Rails/OutputSafety
  end
end
