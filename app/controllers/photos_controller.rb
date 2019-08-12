class PhotosController < ApplicationController
  def index
    @photo = Photo.new
    @photos = Photo.with_attached_image.includes(:user)
  end

  def show
    @photo = Photo.find_by_id(params[:id])
  end

  def create
    photo = current_user.photos.create(photo_params)
    photo.image.blob.analyze
    if photo.image.blob.metadata["latitude"] && photo.image.blob.metadata["longitude"]
      flash[:notice] = "Photo uploaded!"
      render json: { location: photo_path(photo) }
    else
      photo.destroy
      flash[:alert] = "Sorry, we couldn't determine the location of that photo."
      render json: { location: root_path }
    end
  end

  private
  def photo_params
    params.require(:photo).permit(:image)
  end
end
