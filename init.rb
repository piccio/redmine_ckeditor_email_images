require 'redmine_ckeditor_email_images/ckeditor_email_images_logger'
require 'redmine_ckeditor_email_images/ckeditor_email_images'

Rails.configuration.to_prepare do
  # plugin does its actions only if ckeditor plugin is present
  if Redmine::Plugin.registered_plugins[:redmine_ckeditor].present?
    ActionMailer::Base.register_interceptor(RedmineCkeditorEmailImages::CkeditorEmailImages)
  end
end

Redmine::Plugin.register :redmine_ckeditor_email_images do
  name 'Redmine Ckeditor Email Images plugin'
  author 'Roberto Piccini'
  description 'insert images in html notification'
  version '2.0.2'
  url 'https://github.com/piccio/ckeditor_email_images.git'
  author_url 'https://github.com/piccio'

  settings default: { 'enable_log' => false }, partial: 'settings/ckeditor_email_images'
end
