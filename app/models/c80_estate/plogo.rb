module C80Estate
  class Plogo < ActiveRecord::Base
    belongs_to :property
    mount_uploader :image, PlogoUploader
  end
end