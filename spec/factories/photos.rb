FactoryBot.define do
  factory :photo_gps, class: Photo do
    transient do
      gps { true }
    end

    trait :with_image do
      image { Rack::Test::UploadedFile.new('spec/support/assets/good/location.jpeg', 'image/jpeg') }
    end
    latitude { nil }
    longitude { nil }
    after(:create) do |photo, args|
      photo.latitude = photo.image.blob.metadata[:latitude] if args.gps
      photo.longitude = photo.image.blob.metadata[:longitude] if args.gps
    end
  end
  factory :photo_no_gps, class: Photo do
    trait :with_image do
      image { Rack::Test::UploadedFile.new('spec/support/assets/bad/no-location.jpg', 'image/jpeg') }
    end
  end
end
