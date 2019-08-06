class Photo < ApplicationRecord
  has_one_attached :image

  def pull_coords_from_ar_metadata
    if image.attached?
      self.latitude = image.blob.metadata["latitude"]
      self.longitude = image.blob.metadata["longitude"]
      self.save!
    end    
  end
end
