# frozen_string_literal: true

class FileService
  MARKDOWN_EXTENSION = %w[md markdown mkd mkdown].freeze

  def self.viewer_factory(file)
    raise 'Need file_name' unless file.respond_to? :name
    raise 'Need mime_type' unless file.respond_to? :mime_type

    extension = extension(file.name)
    mime_type = file.mime_type

    info = extension || mime_type

    if MARKDOWN_EXTENSION.include? info
      MarkdownViewerService.render file
    else
      "<div class=\"embedded\">
        <iframe src=\"https://docs.google.com/viewer?srcid=#{file.id}&pid=explorer&efh=false&a=v&chrome=false&embedded=true\" width=\"100%\" height=\"100%\"></iframe>
       </div>"
    end
  end

  def self.extension(file_name)
    file_name.split('.').second
  end
end
