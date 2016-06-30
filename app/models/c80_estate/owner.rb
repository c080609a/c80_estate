module C80Estate

  module Owner

    extend ActiveSupport::Concern

    #  ERROR: Cannot define multiple 'included' blocks for a Concern
    # included do
    #
    # end

    def self.included(klass)
      klass.extend ClassMethods
      klass.send(:include, InstanceMethods)
    end

    module ClassMethods

      def act_as_owner
        class_eval do
          has_many :areas, :as => :owner, :class_name => 'C80Estate::Area', :dependent => :nullify
          has_many :properties, :as => :owner, :class_name => 'C80Estate::Property', :dependent => :nullify
          has_many :comments, :as => :owner, :class_name => 'C80Estate::Comment', :dependent => :destroy
        end
      end
    end

    module InstanceMethods

    end

  end
end

ActiveRecord::Base.send :include, C80Estate::Owner