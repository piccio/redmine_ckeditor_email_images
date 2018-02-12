# thanks to https://github.com/dkalachov/redmine_email_images
class CkeditorEmailImages

  DEBUG = false
  INVISIBLE_EMAIL_HEADER = '&#8203;' * 20
  FIND_IMG_SRC_PATTERN = /(<img[^>]+src=")([^"]+)("[^>]*>)/

  def self.delivering_email(message)
    text_part = message.text_part
    html_part = message.html_part

    if html_part
      related = Mail::Part.new
      related.content_type = 'multipart/related'
      related.add_part html_part
      html_part.body = html_part.body.to_s.gsub(/<body[^>]*>/, "\\0 " << INVISIBLE_EMAIL_HEADER.html_safe)
      html_part.body = html_part.body.to_s.gsub(FIND_IMG_SRC_PATTERN) do
        image_url = URI.unescape $2
        Logger.new("#{Rails.root}/log/ckeditor_email_images.log").info("IMAGE_URL=#{image_url}") if DEBUG
        attachment_url = image_url
        if File.exist?(File.join(Rails.public_path, image_url))
          image_name = File.basename(image_url)
          Logger.new("#{Rails.root}/log/ckeditor_email_images.log").info("IMAGE_NAME=#{image_name}") if DEBUG
          related.attachments.inline[image_name] = File.read(File.join(Rails.public_path, image_url))
          attachment_url = related.attachments[image_name].url
          Logger.new("#{Rails.root}/log/ckeditor_email_images.log").info("ATTACHMENT_URL=#{attachment_url}") if DEBUG
        end

        $1 << attachment_url << $3
      end

      # multipart/alternative
      # - text/plain
      # - multipart/relative
      # -- text/html
      # -- image/*
      message.parts.clear
      message.parts << text_part
      message.parts << related
    end
  end

end
