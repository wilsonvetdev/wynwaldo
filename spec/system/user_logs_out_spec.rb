require "rails_helper"

RSpec.describe "logging out", type: :system, js: true do
  xit "lets users logs out" do
    user = User.create(email: "some@guy.com", password: "password")
    sign_in(user)

    visit root_path
    find(".dropdown").click
    click_link "Log Out"

    expect(page.current_path).to eq(root_path)
    expect(page).to have_text("Logged out successfully.")
  end
end
