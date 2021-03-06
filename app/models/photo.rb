class Photo < ApplicationRecord
  include Rails.application.routes.url_helpers
  geocoded_by :nothing
  has_one_attached :image
  belongs_to :user
  has_many :visits, dependent: :destroy

  scope :most_visited, -> { order(visits_count: :desc) }

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
