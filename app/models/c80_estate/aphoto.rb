module C80Estate
  class Aphoto < ActiveRecord::Base
    belongs_to :area
    mount_uploader :image, AphotoUploader
  end
end