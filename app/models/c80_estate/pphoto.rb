module C80Estate
  class Pphoto < ActiveRecord::Base
    belongs_to :property
    mount_uploader :image, PphotoUploader
  end
end