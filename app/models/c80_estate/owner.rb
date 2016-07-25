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

          # эти взаимосвязи можно трактовать, как "создатель объектов этих классов"
          has_many :areas, :as => :owner, :class_name => 'C80Estate::Area', :dependent => :nullify
          has_many :properties, :as => :owner, :class_name => 'C80Estate::Property', :dependent => :nullify
          has_many :comments, :as => :owner, :class_name => 'C80Estate::Comment', :dependent => :destroy

          # эта взаимосвязь трактуется, как "роль, назначенная персоне"
          has_many :roles, :as => :owner, :class_name => 'C80Estate::Role', :dependent => :destroy
          accepts_nested_attributes_for :roles,
                                        :reject_if => lambda { |attributes|
                                          !attributes.present?
                                        },
                                        :allow_destroy => true

          # эта взаимосвязь трактуется, как "площадь, назначенная сотруднику"
          has_many :assigned_areas, :as => :assigned_person, :class_name => 'C80Estate::Area', :dependent => :nullify

          # эта взаимосвязь трактуется, как "площадь, назначенная сотруднику"
          has_many :assigned_properties, :as => :assigned_person, :class_name => 'C80Estate::Property', :dependent => :nullify

          has_many :sevents, :as => :auser, :class_name => 'C80Estate::Sevent', :dependent => :nullify

          after_create :create_role

          def create_role
            # Rails.logger.debug('<Owner.create_role>')
            r = C80Estate::Role.create({ role_type_id: nil })
            roles << r
          end

          def can_view_statistics?
            r1 = roles.where(role_type: 1)
            r2 = roles.where(role_type: 2)
            r1.count > 0 || r2.count > 0
          end

          def can_view_comments?
            r1 = roles.where(role_type: 1)
            r2 = roles.where(role_type: 2)
            r1.count > 0 || r2.count > 0
          end

          def can_view_settings?
            r1 = roles.where(role_type: 1)
            r1.count > 0
          end

          def can_view_users?
            r1 = roles.where(role_type: 1)
            r1.count > 0
            # true
          end

          def can_edit_area?(area)
            r1 = roles.where(role_type: 1)
            # mark_is_owner = area.owner.id == id
            mark_is_assigned = area.assigned_person.id == id
            r1.count > 0 || mark_is_assigned # || mark_is_owner
            # true
          end


          def can_edit_property?(property)
            r1 = roles.where(role_type: 1)
            # mark_is_owner = property.owner.id == id
            mark_is_assigned = property.assigned_person.id == id
            r1.count > 0 || mark_is_assigned # || mark_is_owner
            # true
          end

          def can_create_areas?
            r1 = roles.where(role_type: 1)
            r1.count > 0
            # true
          end

          def can_create_properties?
            r1 = roles.where(role_type: 1)
            r1.count > 0
            # true
          end

          def can_delete_area?
            r1 = roles.where(role_type: 1)
            r1.count > 0
            # true
          end

        end
      end
    end

    module InstanceMethods

      def role_type_title
        res = " - "
        if roles.count > 0
          if roles.first.role_type_id.present?
            res = roles.first.role_type.title
          end
        end
        res
      end

    end

  end
end

ActiveRecord::Base.send :include, C80Estate::Owner