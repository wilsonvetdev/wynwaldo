class PhotosController < ApplicationController
  before_action :set_photo, only: [:destroy]

  def index
    @photo = Photo.new
    @photos = Photo.with_attached_image.includes(:user, :visits)
    photo = Photo.last
    if photo 
      @coordinates = [photo.longitude, photo.latitude]
    else
      @coordinates = [-80.199145, 25.800791]
    end
  end

  def show
    @photo = Photo.find_by_id(params[:id])
    @coordinates = [@photo.longitude, @photo.latitude]
    if user_signed_in?
      Visit.create(user: current_user, photo: @photo)
    else
      Visit.create(photo: @photo)
    end
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

  def destroy
    @photo.destroy
    redirect_to root_path, notice: 'Photo was successfully deleted.'
  end

  private

  def set_photo

    @photo = current_user.photos.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:image)
  end
end
