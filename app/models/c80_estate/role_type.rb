module C80Estate
  class RoleType < ActiveRecord::Base
    has_many :roles, :dependent => :nullify
  end
end