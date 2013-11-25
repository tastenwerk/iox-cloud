require_dependency "iox/application_controller"

module Iox
  class ReposController < ApplicationController

    before_filter :authenticate!, :get_cloud_container

    # uploads a file to the cloud container
    #
    def create
      return if redirect_if_no_app_access( :write )
      return if redirect_if_not_owner( @cloud_container )

      @cloud_container.add_file( params[:file].original_filename, '', params[:file].read ).commit

      render :json => [@cloud_container.get_file( params[:file].original_filename ).to_json]
    end

    # returns a list of files
    # inside the container
    #
    def index
      return if redirect_if_no_app_access( :write )
      return if redirect_if_not_owner( @cloud_container )
      render json: { items: @cloud_container.list, total: @cloud_container.list.size, order: 'name' }
    end

    # change a file name
    #
    def update
      return if redirect_if_no_app_access( :write )
      return if redirect_if_not_owner( @cloud_container )
      if cloud_file = @cloud_container.get_file( params[:absolute_path] )
        old_name = cloud_file.name
        if cloud_file.rename(params[:name]).commit
          flash.now.notice = I18n.t('cloud_file.renamed', name: old_name, new_name: cloud_file.name)
        else
          flash.now.alert = I18n.t('cloud_file.renaming_failed', name: cloud_file.absolute_path)
        end
      else
        flash.now.alert = I18n.t('cloud_file.not_found', name: params[:absolute_path] )
      end
      render json: { success: flash.alert.blank?, flash: flash, item: cloud_file }
    end

    # remove a file
    #
    def destroy
      return if redirect_if_no_app_access( :write )
      return if redirect_if_not_owner( @cloud_container )
      if cloud_file = @cloud_container.get_file( params[:absolute_path] )
        if cloud_file.remove.commit
          flash.now.notice = I18n.t('cloud_file.removed', name: cloud_file.absolute_path)
        else
          flash.now.alert = I18n.t('cloud_file.removing_failed', name: cloud_file.absolute_path)
        end
      else
        flash.now.alert = I18n.t('cloud_file.not_found', name: params[:absolute_path] )
      end
      render json: { success: flash.alert.blank?, flash: flash, item: cloud_file }
    end

    private

    def get_cloud_container
      @cloud_container = CloudContainer.where( id: params[:cloud_container_id] ).first
      @cloud_container.user = current_user
    end

  end
end