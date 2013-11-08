require 'spec_helper'

describe 'Iox::CloudContainer' do

  before :all do
    @user = Iox::User.new email: 'test@localhost.site', username: 'test'
  end

  describe '#initialize' do

    def valid_cc
      Iox::CloudContainer.new name: 'test', user: @user
    end

    it "will be an instance of CloudContainer" do
      Iox::CloudContainer.new.should be_an_instance_of(Iox::CloudContainer)
    end

    it "will not be valid without a name given" do
      cc = Iox::CloudContainer.new
      expect(cc.valid?).to be_false
    end

    it "will not be valid witout a user given" do
      cc = Iox::CloudContainer.new name: 'test'
      expect(cc.valid?).to be_false
    end

    it "will be valid with a name given" do
      cc = valid_cc
      expect(cc.valid?).to be_true
    end

    it "will not create an object if no config.iox.cloud_storage_path is set in application.rb" do
      Rails.configuration.iox.cloud_storage_path = nil
      cc = valid_cc
      expect{ cc.save }.to raise_error
    end

    it "will not create an object if config.iox.cloud_storage_path is not writeable" do
      cc = valid_cc
      Rails.configuration.iox.cloud_storage_path = '/should/not/be/valid/path'
      expect{ cc.save }.to raise_error Iox::Cloud::InvalidPathError
    end

    it "will save a CloudContainer if config.iox.cloud_storage_path is valid and writable" do
      cc = valid_cc
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      expect( cc.save ).to be_true
    end

  end

  describe "#list contents of a CloudContainer" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
    end

    it "lists 1 file object in a just fresly created CloudContainer (.git_keep)" do
      expect( @cc.list.size ).to eq(1)
    end

  end

  describe "#add_file - adds a file to the CloudContainer" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
    end

    it "adds one plain empty file" do
      expect( @cc.list.size ).to eq(1)
      @cc.add_file( 'test', '/', File::open('/tmp/test', 'w+').read ).commit
      expect( @cc.list.size ).to eq(2)
    end

  end

  describe "#add_directory - adds a directory to the CloudContainer" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
    end

    it "adds one plain directory" do
      expect( @cc.list.size ).to eq(1)
      @cc.add_directory( 'testdir' ).commit
      expect( @cc.list.size ).to eq(2)
    end

  end

  describe "#get_file - retrieve a file as Iox::CloudFile" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
      @cc.add_file( 'favicon.ico', '/', File::open( File::expand_path( '../fixtures/favicon.ico', __FILE__ ), 'r' ).read )
      @cc.add_file( 'test.txt', '/', File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      @cc.commit
    end

    describe "CloudFile" do

      it "is an instance of CloudFile" do
        cf = @cc.get_file( 'favicon.ico' )
        expect( cf ).to be_an_instance_of( Iox::CloudFile )
      end

      it "#name (the name of the cloud file" do
        cf = @cc.get_file( 'favicon.ico' )
        expect( cf.name ).to eq('favicon.ico')
      end

      it "#path (the path of the cloud file" do
        cf = @cc.get_file( 'favicon.ico' )
        expect( cf.path ).to eq('.')
      end

      it "#absolute_path (the path of the cloud file" do
        cf = @cc.get_file( 'favicon.ico' )
        expect( cf.absolute_path ).to eq('favicon.ico')
      end

    end

  end

  describe "#get_directory - retrieve a file as Iox::CloudDirecotry" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
      @cc.add_directory('testdir')
      @cc.add_file( 'favicon.ico', '', File::open( File::expand_path( '../fixtures/favicon.ico', __FILE__ ), 'r' ).read )
      @cc.add_file( 'test.txt', 'testdir', File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      @cc.commit
    end


    describe "CloudDirectory" do

      it "is an instance of CloudDirectory" do
        cd = @cc.get_directory( 'testdir' )
        expect( cd ).to be_an_instance_of( Iox::CloudDirectory )
      end

      it "#name - has a name attribute" do
        cd = @cc.get_directory( 'testdir' )
        expect( cd.name ).to eq('testdir')
      end

      it "#path - has a path attribute" do
        cd = @cc.get_directory( 'testdir' )
        expect( cd.path ).to eq('.')
      end

      it "#absolute_path - returns the absolute_path of the directory" do
        cd = @cc.get_directory( 'testdir' )
        expect( cd.absolute_path ).to eq('testdir')
      end

    end

  end

  describe "#rename a file" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
      @cc.add_file( 'test.txt', '/', File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      @cc.commit
    end

    it "renames test.txt -> new.txt" do
      cf = @cc.get_file( 'test.txt' )
      expect( cf ).to be_true
      cf.rename( 'new.txt' ).commit
      cf = @cc.get_file( 'test.txt' )
      expect( cf ) .to be_false
      cf = @cc.get_file( 'new.txt' )
      expect( cf ).to be_true
    end

  end

  describe "#rename a directory" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
      @cc.add_file( 'test.txt', 'test-dir', File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      @cc.commit
    end

    it "renames test-dir -> test---dir" do
      cd = @cc.get_directory( 'test-dir' )
      expect( cd ).to be_true
      cd.rename( 'test---dir' ).commit
      cd = @cc.get_directory( 'test-dir' )
      expect( cd ) .to be_false
      cd = @cc.get_directory( 'test---dir' )
      expect( cd ) .to be_true
    end

    it "returns size of test-dir" do
      @cc.add_file( 'test2.txt', 'test-dir', File::open( File::expand_path( '../fixtures/favicon.ico', __FILE__ ), 'r' ).read )
      cd = @cc.get_directory( 'test-dir' )
      expect( cd.size ).to eq(2)
    end

    it "renames test-dir and all other files within test-dir" do
      @cc.add_file( 'test2.ico', 'test-dir', File::open( File::expand_path( '../fixtures/favicon.ico', __FILE__ ), 'r' ).read )
      cd = @cc.get_directory( 'test-dir' )
      expect( cd.list.first.name ).to eq( 'test.txt' )
      expect( cd.list.last.name ).to eq( 'test2.ico' )
    end

  end

  describe "#remove a file" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
      @cc.add_file( 'test.txt', 'test-dir', File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      @cc.commit
    end

    it "removes a file" do
      cf = @cc.get_file( 'test-dir/test.txt' )
      expect( cf ).to be_true
      cf.remove.commit
      cf = @cc.get_file( 'test.txt' )
      expect( cf ).to be_false
    end

  end


  describe "#remove a directory" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
      @cc.add_file( 'test.txt', 'test-dir', File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      @cc.commit
    end

    it "removes a directory" do
      cd = @cc.get_directory( 'test-dir' )
      expect( cd ).to be_true
      cd.remove.commit
      cd = @cc.get_directory( 'test-dir' )
      expect( cd ).to be_false
    end

  end

  describe "#changes to file" do

    before do
      Rails.configuration.iox.cloud_storage_path = 'cloud-storage/'
      @cc = Iox::CloudContainer.create! name: 'test', user: @user
      @cc.add_file( 'test.txt', '/', File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      @cc.commit
    end

    it "changes a file's content" do
      file = @cc.get_file( 'test.txt' )
      expect( file.read ).to eq( File::open( File::expand_path( '../fixtures/test.txt', __FILE__ ), 'r' ).read )
      file.write( File::open( File::expand_path('../fixtures/favicon.ico', __FILE__ ) ).read )
      file.commit
      file = @cc.get_file( 'test.txt' )
      expect( file.read.size ).to eq( File::open( File::expand_path( '../fixtures/favicon.ico', __FILE__ ), 'r' ).read.size )
    end

  end

end