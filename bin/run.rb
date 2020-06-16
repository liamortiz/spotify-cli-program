require_relative '../config/environment'

# Start the spotify static class
Spotify.authenticate
Spotify.sample_track({:name => "Wasted Times"})
binding.pry
