class Spotify
  def self.authenticate
    client_id =     API_CREDS['spotify_creds']['client_id']
    client_secret = API_CREDS['spotify_creds']['client_secret']
    # Authenticate
    begin
      RSpotify.authenticate(client_id, client_secret)
    rescue RestClient::BadRequest
      puts "ERROR: Failed to authenticate!"
      # Exit for now but we want to handle this error correctly
      exit
    else
      #puts "DEBUG: Successfully authenticated."
    end
  end

  def self.find_track_by_name(name)
    RSpotify::Track.search(name, limit: 8, market: 'US')
    # Returns an array of tracks
  end

  def self.find_track_by_name_artist(name:, artist:)
    find_track_by_name(name).find do |track|
      track.artists.first.name.downcase == artist.downcase
    end
    # Returns nil or a single instance of a track
  end

  def self.find_artist(name)
    RSpotify::Artist.search(name, limit: 8, market: 'US')
    # Returns nil or single instance of artist
  end

  def self.launch(url)
    # Opens the browser to the Spotify app pointing to the track using Launchy gem.
    Launchy.open(url) do |exception|
      puts "ERROR: Tried openning #{url} but failed because #{exception}"
    end
  end
end
