require "rails_helper"

RSpec.describe "uploading photo", type: :system, js: true do
  let(:user){ User.create(admin: true, email: "some@guy.com", password: "password") }
  before do
    sign_in(user)
  end

  context "when photo has location" do
    before do
      visit root_path
      page.attach_file("#{Rails.root}/spec/support/assets/good/location.jpeg", visible: false) do
        page.find('.dz-hidden-input', visible: false)
      end
      sleep 5
    end

    it "should redirect to the show page" do
      expect(page.current_path).to eq(photo_path(Photo.last.id))
    end

    it "should have upload success notice" do
      expect(page).to have_text("Photo uploaded!")
    end

    xit "should have the uploaded image on show page" do
      expect(page).to have_css("img[src*='#{url_for(Photo.last.image)}']")
    end
  end

  context "when photo has no location" do
    before do
      visit root_path
      page.attach_file("#{Rails.root}/spec/support/assets/bad/no-location.jpg", visible: false) do
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

  context "when photo is not a jpeg" do
    before do
      visit root_path
      click_button "📎"
      page.attach_file("#{Rails.root}/spec/support/assets/bad/image.png", visible: false) do
        page.find('.dz-hidden-input', visible: false)
      end
      sleep 1
    end

    it "should not redirect" do
      expect(page.current_path).to eq(root_path)
    end

    it "should have a single file in the dropzone" do
      files = page.all('#image-upload-dropzone > .dz-image-preview')
      expect(files.length).to eq(1)
      expect(files[0]).to have_css("img[alt*='image.png']")
    end
    
    it "should have error on the image preview" do
      find('#image-upload-dropzone > .dz-error').hover
      errorMessage = page.find('#image-upload-dropzone > .dz-error > .dz-error-message')
      expect(errorMessage).to have_text("You can't upload files of this type.")
    end
  end

  context "when file already in dropzone" do
    before do
      visit root_path
      click_button "📎"
      page.attach_file("#{Rails.root}/spec/support/assets/bad/image.png", visible: false) do
        page.find('.dz-hidden-input', visible: false)
      end
      sleep 1
    end

    it "should remove the first file when submitting another error file" do
      page.attach_file("#{Rails.root}/spec/support/assets/bad/image2.png", visible: false) do
        page.find('#image-upload-dropzone')
      end
      sleep 1

      files = page.all('#image-upload-dropzone > .dz-image-preview')
      expect(files.length).to eq(1)
      expect(files[0]).to have_css("img[alt*='image2.png']")
      expect(files[0]).to_not have_css("img[alt*='image.png']")
    end

    it "should allow user to click on error image to clear dropzone" do
      page.find('#image-upload-dropzone > .dz-error').click
      expect(page.find('#image-upload-dropzone')).to_not have_selector('.dz-image-preview') 
    end

    xit "should still work with a photo that has location" do
      page.attach_file("#{Rails.root}/spec/support/assets/good/location.jpeg", visible: false) do
        page.find('#image-upload-dropzone')
      end
      sleep 1
      
      expect(page.current_path).to eq(photo_path(Photo.last.id))
      expect(page).to have_text("Photo uploaded!")
      expect(page).to have_css("img[src*='#{url_for(Photo.last.image)}']")
    end

    it "should display error with a photo that has no location" do
      page.attach_file("#{Rails.root}/spec/support/assets/bad/no-location.jpg", visible: false) do
        page.find('#image-upload-dropzone')
      end
      sleep 1

      expect(page.current_path).to eq(root_path)
      expect(page).to have_text("Sorry, we couldn't determine the location of that photo.")
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
