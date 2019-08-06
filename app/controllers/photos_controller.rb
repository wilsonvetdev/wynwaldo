class PhotosController < ApplicationController
  def index
    @photo = Photo.new
    @photos = Photo.with_attached_image
  end

  def show
    @photo = Photo.find_by_id(params[:id])
  end

  def create
    photo = Photo.create!(photo_params)
    redirect_to photo_path(photo.id)
  end

  private
  def photo_params
    params.require(:photo).permit(:image)
  end
end