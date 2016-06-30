module C80Estate
  class Astatus < ActiveRecord::Base
    has_and_belongs_to_many :areas # Площадь имеет единственный статус: либо занята, либо свободна
  end
end