class Photo < ApplicationRecord
  has_one_attached :image

  before_create :pull_coords_from_image_metadata

  def pull_coords_from_image_metadata
    if image.attached?
      self.latitude   = image.blob.metadata["latitude"]
      self.longitude  = image.blob.metadata["longitude"]
    end
  end
end
