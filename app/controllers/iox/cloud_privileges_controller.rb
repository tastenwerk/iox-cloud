require_dependency "iox/application_controller"

module Iox
  class CloudPrivilegesController < ApplicationController

    def create
      if @cloud_container = Iox::CloudContainer.find_by_id( params[:cloud_container_id] )
        if priv = @cloud_container.privileges.where(email: params[:privilege][:email]).first
          PrivilegesMailer.email_invitation( params[:privilege][:email], get_full_key(priv) ).deliver
          flash.notice = I18n.t('cloud_container.privilege.email_sent_again')
        else
          priv = @cloud_container.privileges.build
          priv.email = params[:privilege][:email]
          priv.gen_access_key
          priv.expires_at = @cloud_container.access_expires
          if priv.save
            flash.notice = I18n.t('cloud_container.privilege.confirm_next')
            PrivilegesMailer.email_invitation( params[:privilege][:email], get_full_key( priv ) ).deliver
          else
            flash.alert = I18n.t('cloud_container.privilege.email_failed')
          end
        end
      else
        flash.alert = I18n.t('cloud_container.not_found')
      end
      render json: { flash: flash }
    end

    def index
    end

    private

    def get_full_key( priv )
      url = request.protocol
      url += request.host
      url += ":#{request.port}" unless request.port == 80
      url += "/shf/?k=#{Base64.encode64("#{@cloud_container.id},#{priv.access_key},#{priv.email}")}"
      url
    end

  end
end