class MapsController < ApplicationController
  def show
    respond_to do |format|
      format.json do
        if params[:latitude] && params[:longitude]
          @photos = Photo.most_visited.near([params[:latitude], params[:longitude]], 0.25)
        else
          @photos = Photo.most_visited.with_attached_image.includes(:user, :visits).limit(50)
        end

        render json: {
          photos: @photos.map do |photo|
            {
              id: photo.id,
              image: url_for(photo.image),
              location: url_for(photo),
              visits: photo.visits,
              user: {
                email: photo.user.email
              }
            }
          end
        }
      end
    end
  end
end

# @photos = Photo.with_attached_image.includes(:user, :visits)
# user_location = request.location.coordinates
# if user_location.empty?
#   @photos = Photo.most_visited.with_attached_image.includes(:user, :visits).limit(10)
#   @criteria = "Most Visited"
# else
#   @photos = Photo.most_visited.near(user_location).with_attached_image.includes(:user, :visits).limit(10)
#   @criteria = "Nearby"
#   if @photos.count < 10
#     @photos = Photo.most_visited.with_attached_image.includes(:user, :visits).limit(10)
#     @criteria = "Most Visited"
#   end
# end
# photo = Photo.last
# if photo
#   @coordinates = [photo.longitude, photo.latitude]
# else
#   @coordinates = [-80.199145, 25.800791]
# end
