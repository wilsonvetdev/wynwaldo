require "rails_helper"

RSpec.describe "upload photo", type: :system, js: true do
  context "when uploading photo that has location" do
    before do
      visit root_path
      page.attach_file("#{Rails.root}/spec/support/assets/location.jpeg", visible: false) do
        page.find('.dz-hidden-input', visible: false)
      end
      sleep 1
    end

    it "should redirect to the show page" do
      expect(page.current_path).to eq(photo_path(Photo.last.id))
    end

    it "should have upload success notice" do
      expect(page).to have_text("Photo uploaded!")
    end

    it "should have the uploaded image on show page" do
      expect(page).to have_css("img[src*='#{url_for(Photo.last.image)}']")
    end

    it "should have the lat and long on the show page" do
      expect(page).to have_text("Latitude: 25.803819444444443") # may have to move this to controller once map is here
      expect(page).to have_text("Longitude: 80.20327777777777") # may have to move this to controller once map is here
    end
  end

  context "when uploading photo that has no location" do
    before do
      visit root_path
      page.attach_file("#{Rails.root}/spec/support/assets/no-location.jpg", visible: false) do
        page.find('.dz-hidden-input', visible: false)
      end
      sleep 1
    end

    it "should not redirect" do
      expect(page.current_path).to eq(root_path)
    end

    it "should show alert error message" do
      expect(page).to have_text("Sorry, we couldn't determine the location of that photo.")
    end
  end

  context "when uploading photo that is not a jpeg" do
    before do
      visit root_path
      page.attach_file("#{Rails.root}/spec/support/assets/image.png", visible: false) do
        page.find('#image-upload-dropzone').click
      end
      sleep 1
    end

    it "should not redirect" do
      expect(page.current_path).to eq(root_path)
    end

    it "should have a single file in the dropzone" do
      expect(page.find('#image-upload-dropzone')).to have_selector('.dz-image-preview', count: 1)
    end
    
    xit "should have error on the image preview" do
      error = page.find('#image-upload-dropzone > .dz-image-preview > .dz-error-message')
      expect(error).to have_text("You can't upload files of this type.")
    end
    
    context "when file already in dropzone" do
      xit "should remove the first file when submitting another file" do
        # add a second file - ***not working***
        page.attach_file("#{Rails.root}/spec/support/assets/image2.png", visible: false) do
          page.find('#image-upload-dropzone')
        end
        sleep 1
        
        # check if theres still one file
        expect(page.find('#image-upload-dropzone')).to have_selector('.dz-image-preview', count: 1) 
      end
      xit "should allow user to click on form to clear files" do
        page.find('#image-upload-dropzone').click        
        expect(page.find('#image-upload-dropzone')).to_not have_selector('.dz-image-preview') 
      end
      it "should still work with a photo that has location if there is an error file" do
        page.find('#image-upload-dropzone').click 
        page.attach_file("#{Rails.root}/spec/support/assets/location.jpeg", visible: false) do
          page.find('#image-upload-dropzone').click
        end
        sleep 1

        expect(page.current_path).to eq(photo_path(Photo.last.id))
        expect(page).to have_text("Photo uploaded!")
        expect(page).to have_css("img[src*='#{url_for(Photo.last.image)}']")
      end
    end
  end

  def remove_uploaded_files
    FileUtils.rm_rf("#{Rails.root}/storage_test")
  end

  def after_teardown
    super
    remove_uploaded_files
  end
end
