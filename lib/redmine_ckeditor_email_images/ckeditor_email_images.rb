module RedmineCkeditorEmailImages
  class CkeditorEmailImages

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
          img_early_part = $1
          src_part = $2
          img_latter_part = $3

          image_url = URI.unescape src_part
          sub_uri = Rails.configuration.relative_url_root
          unless sub_uri.blank?
            image_url = image_url.gsub(/\A#{sub_uri}/, '')
          end
          RedmineCkeditorEmailImages::CkeditorEmailImagesLogger.write(:info, "IMAGE URL=#{image_url}")
          attachment_url = image_url
          if File.exist?(File.join(Rails.public_path, image_url))
            related.attachments.inline[image_url] = File.read(File.join(Rails.public_path, image_url))
            attachment_url = related.attachments[image_url].url
            RedmineCkeditorEmailImages::CkeditorEmailImagesLogger.write(
              :info, "ATTACHMENT URL=#{attachment_url}")
          end

          img_early_part << attachment_url << img_latter_part
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
end