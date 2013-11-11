module Iox

  class InvalidObjectError < StandardError
  end

  class CloudFile

    attr_accessor :name,
                  :oid,
                  :path,
                  :ctime,
                  :atime,
                  :mtime

    def initialize( attrs, user, repo )

      @repo = repo
      @user = user

      attrs.each do |key,val|
        next unless methods.include?( key )
        send("#{key}=", val)
      end

      self.name = File::basename( path )
      self.path = File::dirname( path )

    end

    def absolute_path
      !path.blank? && !path.match(/^.\/$|^.$/) ? "#{path}/#{name}" : name
    end

    def read
      @repo.lookup( oid ).read_raw.data
    end

    def rename( new_name )
      remove # old entry
      self.name = new_name
      oid = @repo.write( read, :blob )
      @repo.index.add(  path: absolute_path,
                        oid: oid,
                        mode: 0100644 )
      self
    end

    def write( content )
      oid = @repo.write( content, :blob )
      @repo.index.add(  path: absolute_path,
                        oid: oid,
                        mode: 0100644 )
      self
    end

    def remove
      @repo.index.remove( absolute_path )
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
      @repo.index.write
      true
    end

    # basic to_hash functionality
    #
    def to_hash
      { name: name,
        id: oid,
        content_type: File::extname(name).sub('.',''),
        filesize: (read.size / 1000.0),
        absolute_path: absolute_path,
        path: path,
        updated_at: mtime,
        created_at: ctime }
    end

    def to_json
      to_hash
    end

    private

    def user_opts
      { email: @user.email,
        name: @user.full_name,
        time: Time.now }
    end

  end
end