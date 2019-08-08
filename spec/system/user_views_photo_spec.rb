require "rails_helper"

RSpec.describe "viewing photos", type: :system, js: true do  
  before do
    visit root_path
    page.attach_file("#{Rails.root}/spec/support/assets/location.jpeg", visible: false) do
      page.find('#image-upload-dropzone').click
    end
    sleep 1
    visit root_path
  end

  it "lists the photos" do
    within "ul > li:first-of-type > a" do
      expect(page).to have_css("img[src*='#{url_for(Photo.last.image)}']")
    end
  end
  
  it "has links to show page for photo" do
    find("ul > li:first-of-type > a").click
    sleep 1
    expect(page.current_path).to eq(photo_path(Photo.last.id))
  end

  xit "can scroll to top when scrolled down"

  def remove_uploaded_files
    FileUtils.rm_rf("#{Rails.root}/storage_test")
  end

  def after_teardown
    super
    remove_uploaded_files
  end
end