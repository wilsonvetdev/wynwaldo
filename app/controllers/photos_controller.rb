class PhotosController < ApplicationController
  before_action :set_photo, only: [:destroy]

  def index
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
    if user_agent.platform == 'iPhone'
      flash[:alert] = "Device not supported.  Please try from a desktop computer."
      return render json: { location: root_path }
    end
    photo = current_user.photos.create(photo_params)
    photo.image.blob.analyze unless photo.image.blob.analyzed?
    if photo.image.blob.metadata["latitude"] && photo.image.blob.metadata["longitude"]
      photo.pull_coords_from_image_metadata
      photo.save
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
