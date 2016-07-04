module C80Estate
  class Pphoto < ActiveRecord::Base
    mount_uploader :image, PphotoUploader
  end
end