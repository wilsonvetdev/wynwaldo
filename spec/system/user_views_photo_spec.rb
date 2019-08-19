# require "rails_helper"

# RSpec.describe "viewing photos", type: :system, js: true do  
#   let(:user){ User.create(admin: true, email: "some@guy.com", password: "password") }
#   before do
#     sign_in(user)
#     visit root_path
#     click_button "📎"
#     page.attach_file("#{Rails.root}/spec/support/assets/good/location.jpeg", visible: false) do
#       page.find('#image-upload-dropzone').click
#     end
#     sleep 1
#     visit root_path
#     sign_out(user)
#     visit root_path
#   end

#   it "lists the photos" do
#     sleep 10
#     first_list_image = page.all('ul > li:first-of-type a:first-of-type')[0]
#     within first_list_image do
#       expect(page).to have_css("img#photo-#{Photo.last.id}")
#     end
#   end

#   it "should have links on photos that go to show page" do
#     first_list_image = page.all('ul > li:first-of-type a:first-of-type')[0]
#     first_list_image.click
#     sleep 1
#     expect(page.current_path).to eq(photo_path(Photo.last.id))
#   end

#   it "can scroll to top when scrolled down" do
#     # need more photos to test the scrolling.
#     sign_in(user)
#     visit root_path
#     4.times do
#       page.attach_file("#{Rails.root}/spec/support/assets/good/location.jpeg", visible: false) do
#         page.find('#image-upload-dropzone')
#       end
#       sleep 1
#       visit root_path
#     end
#     sign_out(user)
#     visit root_path
#     page.execute_script "window.scrollBy(0,10000)"
#     page.find('#scrollButton').click
#     sleep 1
#     expect(page.execute_script "return window.pageYOffset").to eq(0)
#   end

#   def remove_uploaded_files
#     FileUtils.rm_rf("#{Rails.root}/storage_test")
#   end

#   def after_teardown
#     super
#     remove_uploaded_files
#   end
# end
