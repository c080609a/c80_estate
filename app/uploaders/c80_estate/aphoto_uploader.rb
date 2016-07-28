module C80Estate
  class AphotoUploader < BaseFileUploader

    # ограничение оригинальной картинки
    process :resize_to_limit => [1024, 1024]

    version :thumb512 do
      process :resize_to_fill => [621, 377]
    end

    version :thumb256 do
      process :resize_to_fill => [310, 188]
    end

    def store_dir
      "uploads/areas/#{model.id}"
    end

  end

end