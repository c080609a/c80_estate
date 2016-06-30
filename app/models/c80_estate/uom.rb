module C80Estate
  class Uom < ActiveRecord::Base
    has_one :prop_name
  end
end