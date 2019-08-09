class MapsController < ApplicationController
  def show
    respond_to do |format|
      format.html
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
                image: url_for(photo.image)
              }
            }
          end
        }
      end
    end
  end
end
