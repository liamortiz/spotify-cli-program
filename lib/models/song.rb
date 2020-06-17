class Song < ActiveRecord::Base
  has_many :records
  has_many :playlists, through: :records

  def play
    Spotify.launch(self.external_url)
  end

  def self.get_song_from_playlist(playlist, user)
    # Ask the user to pick a song from a playlist and returns it
    choices = {}
    playlist.songs.map.with_index(1) do |song, index|
      choices["#{index}) #{song.name} - #{song.artist_name}"] = song
    end

    user.prompt_select("Select a song for more options.", choices)
  end

  def self.add_song(user)
    # If the user has no playlist, ask to make one.
    if user.playlists.size == 0
      PROMPT.warn("Console: No playlist found, please create one.")
      Playlist.create_playlist(user)
      user.reload
    end

    # Ask the user to select the playlist where the song will go
    playlist = Playlist.get_playlist(user)

    # Load song from other playlists or Spotify API
    choice = user.prompt_select("Select a song from your playlists or Spotify", ["1) Playlists", "2) Spotify"])
    if choice == "2) Spotify"
      self.load_song_from_api(playlist, user)
    else
      self.load_song_from_playlists(playlist, user)
    end
  end

  private

  def self.load_song_from_api(playlist, user)
    song_name = PROMPT.ask("What is the song name or artist name?")
    # Call Spotify static class handles API calls
    songs = Spotify.find_track_by_name(song_name)

    choices = {}
    songs.map.with_index(1) do |song, index|
      choices["#{index}) #{song.name} - #{song.artists.first.name}"] = song
    end
    # Ask the user to select from the list of songs and return an array of selections
    PROMPT.warn("Console: Use space to select multiple songs then Enter. (Include Back to Cancel All)")
    user.prompt_select_multi("Select the song.", choices).map do |song|
      db_song = Song.find_or_create_by({:name => song.name, :artist_name => song.artists.first.name, :external_url => song.external_urls['spotify']})
      Record.find_or_create_by({:song_id => db_song.id, :playlist_id => playlist.id}) # Joiner table
    end
  end


  def self.load_song_from_playlists(playlist, user)
    # moves a song from one playlist to another
    choices = {}
    user.songs.uniq.map.with_index(1) do |song, index|
      choices["#{index}) #{song.name} - #{song.artist_name}"] = song
    end
    song = user.prompt_select("Select the song.", choices)
    Record.find_or_create_by({:song_id => song.id, :playlist_id => playlist.id}) # Joiner table
  end
end
