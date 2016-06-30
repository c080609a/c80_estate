module C80Estate
  class AtphotoUploader < BaseFileUploader

    # ограничение оригинальной картинки
    process :resize_to_limit => [1024, 1024]

    version :thumb512 do
      process :resize_to_limit => [512, 512]
    end

    version :thumb256 do
      process :resize_to_limit => [256, 256]
    end

    def store_dir
      "uploads/atypes/#{model.id}"
    end

  end

end