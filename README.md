# Final Project at Wyncode(coding bootcamp out of Miami, FL)

live: https://wynwaldo.herokuapp.com/

# Intro
Wynwaldo was accomplished by a team of 4 brilliant students and with tremendous help from various instructors. Wynwaldo allows a user to browse the various wall-arts in Wynwood area. The application utilizes a React frontend and Rails backend. Amazon AWS for the storage of art images. Mapbox API for rendering of the app and showing the locations of these art pieces in Wynwood.

## Wireframe

![Wireframe Example](readme_assets/wireframe.png)

## ERD

![ERD Example](readme_assets/erd.png)
^^`visits` and `keywords` are not attributes of the `Photo` or `User` models -- AW
^^ Images will be handled through `ActiveStorage`: https://edgeguides.rubyonrails.org/active_storage_overview.html#has-one-attached

## Deployment

If your project uses the `react_on_rails` gem, you will need to:

- `heroku create your-app-name`
- `heroku buildpacks:set --index 1 heroku/nodejs`
- `heroku buildpacks:add heroku/ruby`
- `git push heroku master`
- `heroku run rails db:migrate`
- optional: `heroku run rails db:seed`
