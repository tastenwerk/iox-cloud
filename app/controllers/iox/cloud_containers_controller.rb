require_dependency "iox/application_controller"

module Iox
  class CloudContainersController < ApplicationController

    before_filter :authenticate!, except: [ :frontpage, :show, :by_slug ]

    #
    # list all cloud_containers
    #
    def index
      if request.xhr?
        @num_cloud_containers = CloudContainer.count
        if params[:query].blank?
          @cloud_containers = CloudContainer.where('')
        else
          @cloud_containers = CloudContainer.where("name LIKE ?", "%#{params[:query]}%")
        end
        @cloud_containers = @cloud_containers.where(type: nil).order(:name).load
        render json: { items: @cloud_containers }
      end
    end

    #
    # show form for new cloud_container
    #
    def new
      @cloud_container = CloudContainer.new
      render json: @cloud_container
    end

    #
    # create new cloud_container
    #
    def create
      @cloud_container = CloudContainer.new cloud_container_params
      return if !redirect_if_no_rights
      @cloud_container.set_creator_and_updater( current_user )
      if @cloud_container.save

        Iox::Activity.create! user_id: current_user.id, obj_name: @cloud_container.name, action: 'created', icon_class: 'CloudContainer', obj_id: @cloud_container.id, obj_type: @cloud_container.class.name

        flash.notice = I18n.t('created', name: @cloud_container.name)
      else
        flash.alert = I18n.t('creation_failed') + ": " + @cloud_container.errors.full_messages.inspect
      end

      render json: {
        item: @cloud_container,
                      errors: @cloud_container.errors.full_messages,
                      success: @cloud_container.persisted?,
                      flash: flash }

    end

    #
    # edit a cloud_container
    #
    def edit
      @cloud_container = CloudContainer.where( id: params[:id] ).first
      @frontpage = cloud_container.where(template: 'frontpage').first
      return if !redirect_if_no_cloud_container
      redirect_if_no_cloud_container
      redirect_if_no_rights
      render layout: 'application'
    end

    #
    # update a cloud_container
    #
    def update
      @cloud_container = CloudContainer.where( id: params[:id] ).first
      return if !redirect_if_no_cloud_container
      return if !redirect_if_no_rights
      @cloud_container.set_creator_and_updater( current_user )
      if @cloud_container.update cloud_container_params

        Iox::Activity.create! user_id: current_user.id, obj_name: @cloud_container.name, action: 'edited', icon_class: 'icon-cloud', obj_id: @cloud_container.id, obj_type: @cloud_container.class.name

        flash.now.notice = I18n.t('saved', name: @cloud_container.name)
      else
        flash.now.alert = t('saving_failed', name: @cloud_container)
      end
      render json: { flash: flash }
    end

    def destroy
      @cloud_container = CloudContainer.where( id: params[:id] ).first
      return if !redirect_if_no_cloud_container
      return if !redirect_if_no_rights
      if @cloud_container.delete
        @cloud_container.children.each{ |c| c.delete }
        flash.now.notice = t('cloud_container.deleted', name: @cloud_container.name, id: @cloud_container.id)
      else
        flash.now.alert = t('cloud_container.failed_to_delete', name: @cloud_container.name)
      end
      if request.xhr?
        render json: { flash: flash, success: flash[:alert].blank? }
      else
        redirect_to cloud_containers_path
      end
    end

    private

    def cloud_container_params
      params.require(:cloud_container).permit(
        :name,
        :access,
        :public_access_expires
      )
    end

    def update_stat

      return unless @cloud_container

      if day_stat = @cloud_container.stats.where( day: Time.now.to_date, ip_addr: request.remote_ip.to_s, user_agent: request.env["HTTP_USER_AGENT"].to_s ).first
        day_stat.views += 1
        if day_stat.updated_at < 30.minutes.ago
          day_stat.visits += 1
        end
        day_stat.save!
      else
        @cloud_container.stats.create!( ip_addr: request.remote_ip.to_s, day: Time.now.to_date, user_agent: request.env["HTTP_USER_AGENT"].to_s )
      end

    end

  end

end
