class Visit < ApplicationRecord
  belongs_to :photo, counter_cache: true
  belongs_to :user, optional: true
end
