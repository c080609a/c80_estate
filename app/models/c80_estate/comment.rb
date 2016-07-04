module C80Estate
  class Comment < ActiveRecord::Base
    belongs_to :area
    belongs_to :property
    belongs_to :owner, :polymorphic => true
  end
end