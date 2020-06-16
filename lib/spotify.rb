class Spotify
  def self.authenticate
    client_id =     API_CREDS['spotify_creds']['client_id']
    client_secret = API_CREDS['spotify_creds']['client_secret']

    # Authenticate
    begin
      RSpotify.authenticate(client_id, client_secret)
    rescue RestClient::BadRequest
      puts "ERROR: Failed to authenticate!"
      # Exit for now but we wanna handle this error correctly
      exit
    else
      puts "Successfully authenticated."
    end
  end

  # Make a simple request to find a track via name
  def self.sample_track(name:)
    tracks = RSpotify::Track.search(name, limit: 5, market: 'US')
    tracks.each_with_index do |track, index|
      puts "#{index + 1}) #{track.name} - #{track.artists.first.name}"
    end
  end
end
