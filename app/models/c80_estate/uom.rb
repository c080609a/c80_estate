module C80Estate
  class Uom < ActiveRecord::Base
    has_many :prop_names
  end
end