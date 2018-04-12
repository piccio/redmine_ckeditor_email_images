module RedmineCkeditorEmailImages
  class CkeditorEmailImagesLogger < Logger

    def self.write(level, message)
      if Setting.plugin_redmine_ckeditor_email_images['enable_log'] == 'true'
        logger ||= new("#{Rails.root}/log/ckeditor_email_images.log")
        logger.send(level, message)
      end
    end

  end
end
