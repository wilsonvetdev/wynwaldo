require 'rails_helper'

RSpec.describe Photo, type: :model do
  describe Photo, '.pull_coords_from_image_metadata' do
    let(:photo_gps) { create :photo_gps, :with_image }
    let(:photo_no_gps) { create :photo_no_gps, :with_image }
    let(:photo_no_image) { create :photo_no_gps }

    it 'sets lat and long to image metadata' do      
      photo_gps.pull_coords_from_image_metadata
      
      expect(photo_gps[:latitude]).to eq photo_gps.image.blob.metadata["latitude"]
      expect(photo_gps[:longitude]).to eq photo_gps.image.blob.metadata["longitude"]
    end

    it 'sets to nil when there is no location' do      
      photo_no_gps.pull_coords_from_image_metadata
      
      expect(photo_no_gps[:latitude]).to eq nil
      expect(photo_no_gps[:longitude]).to eq nil
    end

    it 'sets to nil if no image attached' do      
      photo_gps.pull_coords_from_image_metadata
      
      expect(photo_gps[:latitude]).to eq nil
      expect(photo_gps[:longitude]).to eq nil
    end
  end
end
