require 'test_helper'

class IoxCloudContainerTest < ActiveSupport::TestCase

  def get_cc
    Iox::CloudContainer.where( name: @cc_attrs[:name] ).first
  end

  setup do
    @cc = Iox::CloudContainer.new
    @cc_attrs = { name: 'test', user: Iox::User.new( username: 'user1', email: 'user1@localhost.site' ) }
  end

  test "instance of a new cloud container (cc)" do
    assert_instance_of Iox::CloudContainer, @cc
  end

  test "cc requires a name" do
    assert_not @cc.valid?
  end

  test "cc with a name is valid" do
    @cc.attributes = @cc_attrs
    assert @cc.valid?
  end

  test "storing to db will require a iox.cloud_storage_path to be set in configuration.iox" do
    Rails.configuration.iox.cloud_storage_path = '/should/not/be/valid/path'
    assert_raises Iox::Cloud::InvalidPathError do
      @cc.attributes = @cc_attrs
      @cc.save
    end
  end

  test "storing withoug having iox.cloud_storage_path set, will raise an error" do
    Rails.configuration.iox.cloud_storage_path = nil
    assert_raises Iox::Cloud::InvalidPathError do
      @cc.attributes = @cc_attrs
      @cc.save
    end
  end

  test "storing cc without a user will raise an InvalidUserError" do
    Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
    assert_raises Iox::Cloud::InvalidUserError do
      @cc.name = 'test'
      @cc.save
    end
  end

  test "setting path to a valid directory will store a cc" do
    Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
    cc = Iox::CloudContainer.new @cc_attrs
    assert cc.save
  end

  test "cc can be retrieved" do
    cc = get_cc    
    assert_instance_of Iox::CloudContainer, cc
  end

  test "returns full path to the this container" do
    Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
    cc = get_cc
    puts cc.inspect
    assert_equal "#{Iox::CloudContainer.storage_path}/#{cc.public_key}", cc.storage_path
  end
  
end
