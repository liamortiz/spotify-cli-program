class Song < ActiveRecord::Base
  has_many :playlists, through: :records
end
