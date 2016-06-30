module C80Estate
  class Atphoto < ActiveRecord::Base
    belongs_to :atype
    mount_uploader :image, AtphotoUploader
  end
end