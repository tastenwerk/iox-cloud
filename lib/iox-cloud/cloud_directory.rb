module Iox
  class CloudDirectory

    attr_accessor :name,
                  :oid,
                  :path,
                  :ctime,
                  :atime,
                  :mtime

    def initialize( attrs, user, repo, cloud_container )

      @repo = repo
      @cloud_container = cloud_container
      @user = user

      attrs.each do |key,val|
        next unless methods.include?( key )
        send("#{key}=", val)
      end

      @orig_file = CloudFile.new( @repo.index[path], user, repo )

      self.name = File::basename( File::dirname( path ) )
      self.path = File::dirname( File::dirname( path ) )

    end

    def absolute_path
      !path.blank? && !path.match(/^.\/$|^.$/) ? "#{path}/#{name}" : name
    end

    def rename( new_name )
      @orig_file.remove # old entry
      self.name = new_name
      @orig_file.path = absolute_path
      oid = @repo.write( @orig_file.read, :blob )
      @repo.index.add(  path: @orig_file.absolute_path,
                        oid: oid,
                        mode: 0100644 )
      self
    end

    def remove
      @repo.index.remove_dir( absolute_path )
      self
    end

    def commit( message="updated file #{name}" )
      options = { message: message }
      options[:tree] = @repo.index.write_tree(@repo)
      options[:author] = user_opts
      options[:time] = Time.now
      options[:committer] = user_opts
      options[:parents] = @repo.empty? ? [] : [ @repo.head.target ].compact
      options[:update_ref] = 'HEAD'
      Rugged::Commit.create(@repo, options)
    end

    # lists amount of files with path of this directory
    # @return [Integer] amount of files within this directory
    #
    def size
      list.size
    end

    # lists files and directories in this directory
    #
    def list
      @cloud_container.list( absolute_path )
    end

    private

    def user_opts
      { email: @user.email,
        name: @user.full_name,
        time: Time.now }
    end

  end
end