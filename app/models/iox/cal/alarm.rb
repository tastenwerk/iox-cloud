module Iox

  module Cal
    class Alarm < ActiveRecord::Base

      belongs_to :user
      belongs_to :event

    end

  end
end
