module C80Estate
  class Role < ActiveRecord::Base
    belongs_to :owner
    belongs_to :role_type
  end
end