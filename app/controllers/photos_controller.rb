class PhotosController < ApplicationController
  def index
    @photo = Photo.new
    @photos = Photo.with_attached_image
  end

  def show
    @photo = Photo.find_by_id(params[:id])
  end

  def create
    photo = Photo.create(photo_params)
    photo.image.blob.analyze
    if photo.image.blob.metadata["latitude"] && photo.image.blob.metadata["longitude"]
      redirect_to photo, notice: "Photo created!"
    else
      photo.destroy
      redirect_to photos_url, alert: "Sorry, we couldn't determine the location of that photo."
    end
  end

  private
  def photo_params
    params.require(:photo).permit(:image)
  end
end
