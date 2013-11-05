require 'test_helper'

class IoxCloudContainerTest < ActiveSupport::TestCase

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
    @cc.name = 'Test3'
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
    @cc.attributes = @cc_attrs
    assert @cc.save
  end
  
end
