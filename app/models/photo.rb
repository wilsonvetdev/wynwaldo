class Photo < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :image
  belongs_to :user
  has_many :visits, dependent: :destroy

  def pull_coords_from_image_metadata
    if image.attached?
      self.latitude   = image.blob.metadata["latitude"]
      self.longitude  = image.blob.metadata["longitude"]
    end
  end

  def as_json(options={})
    {
      id: id,
      location: "/photos/#{id}",
      image: url_for(image),
      coordinates: [longitude, latitude],
      user: {
        email: user.email
      },
      visits: visits.count
    }
  end
end
