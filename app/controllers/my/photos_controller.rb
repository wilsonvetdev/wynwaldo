class My::PhotosController < ApplicationController
  def index
    if user_signed_in?
      @photos = current_user.photos
    else
      redirect_to root_path
    end
  end
end
