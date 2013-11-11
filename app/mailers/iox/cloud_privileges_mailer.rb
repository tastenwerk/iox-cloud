module Iox
  class CloudPrivilegesMailer < ActionMailer::Base

    # default_from is defined in the config/application.rb file

    def email_invitation( email, link )
      @link = link
      mail( to: email, subject: "[#{Rails.configuration.iox.site_title}] #{I18n.t('cloud_container.privilege.mailer.subject')}" )
    end

  end
end
