class MapsController < ApplicationController
  def show
    respond_to do |format|
      format.html do
        photo = Photo.last
        @coordinates = [photo.longitude, photo.latitude]
      end
      format.json do
        @photos = Photo.all
        render json: {
          type: "FeatureCollection",
          features: @photos.map do |photo|
            {
              type: "Feature",
              geometry: {
                type: "Point",
                coordinates: [photo.longitude, photo.latitude]
              },
              properties: {
                id: photo.id,
                image: url_for(photo.image)
              }
            }
          end
        }
      end
    end
  end
end
