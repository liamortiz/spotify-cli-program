class Song < ActiveRecord::Base
  has_many :records
  has_many :playlists, through: :records
end
