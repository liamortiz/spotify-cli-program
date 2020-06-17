class User < ActiveRecord::Base
    has_many :playlists
    has_many :songs, through: :playlists

    include BCrypt
    PROMPT = TTY::Prompt.new(track_history: false)

    def listen
      # List all user songs and plays them through browser
      choices = {}
      self.songs.uniq.map.with_index(1) do |song, index|
        choices["#{index}) #{song.name} - #{song.artist_name}"] = song
      end
      song = prompt_select("Choose a song.", choices)
      Spotify.launch(song.external_url)

    end

    def prompt_select(title, choices)
      PROMPT.select("Console: #{title}") do |menu|
        menu.choices choices
        menu.choice "Back", -> {throw :menu}
        menu.per_page 10
      end
    end

    def prompt_select_multi(title, choices)
      PROMPT.multi_select("Console: #{title}") do |menu|
        menu.choices choices
        menu.choice "Back", -> {throw :menu}
        menu.per_page 10
      end
    end

    def show_playlists
      choices = {}
      self.playlists.each_with_index do |playlist, index|
        choices["#{index + 1}) #{playlist.name}"] = playlist
      end

      playlist = prompt_select("Choose a playlist to view songs.", choices)

      choices = {}
      playlist.songs.map.with_index(1) do |song, index|
        choices["#{index}) #{song.name} - #{song.artist_name}"] = song
      end
      song = prompt_select("Select a song for more options.", choices)
      choice = prompt_select("What do you want to do?", ["1) Play", "2) Remove"])
      if choice == "1) Play"
        Spotify.launch(song.external_url)
      else
        record = Record.find_by({:song_id => song.id, :playlist_id => playlist.id})
        record.destroy
        PROMPT.ok("Console: Song removed from playlist.")
        sleep 2
      end
    end

    def create_playlist
      name = PROMPT.ask("Console: What is the playlist name?")
      # Check if a playlist exists with that name
      if self.playlists.find_by({:name => name})
        PROMPT.error("Console: You already have a playlist with that name, try again.")
      else
        PROMPT.ok("Console: Playlist #{name} created!")
        sleep 2
        Playlist.create({:name => name, :user_id => self.id})
      end
    end

    def remove_playlist
      choices = {}
      self.playlists.map.with_index(1) do |playlist, index|
        choices["#{index}) #{playlist.name} - #{playlist.songs.size} songs."] = playlist
      end
      playlist = prompt_select("Choose the playlist.", choices)
      PROMPT.ok("Console: The playlist #{playlist.name} was removed!")
      playlist.destroy
      sleep 2
    end

    def remove_song

    end

    def add_song
      # If the user has no playlist, ask to make one.
      if self.playlists.size == 0
        PROMPT.warn("Console: No playlist found, please create one.")
        create_playlist
        self.reload
      end
      # Ask the user to select the playlist where the song will go
      choices = {}
      self.playlists.each_with_index do |playlist, index|
        choices["#{index + 1}) #{playlist.name}"] = playlist
      end
      playlist = prompt_select("Select the playlist to populate.", choices)
      choice = prompt_select("Select a song from your playlists or Spotify", ["1) Playlists", "2) Spotify"])

      if choice == "2) Spotify"
        load_song_from_api(playlist)
      else
        load_song_from_playlists(playlist)
      end
    end

    def load_song_from_api(playlist)
      song_name = PROMPT.ask("What is the song name or artist name?")
      songs = Spotify.find_track_by_name(song_name) # Call Spotify static class handles API calls

      choices = {}
      songs.map.with_index(1) do |song, index|
        choices["#{index}) #{song.name} - #{song.artists.first.name}"] = song
      end
      # Ask the user to select from the list of songs and return an array of selections
      PROMPT.warn("Console: Use space to select multiple songs then Enter. (Include Back to Cancel All)")
      prompt_select_multi("Select the song.", choices).map do |song|
        db_song = Song.find_or_create_by({:name => song.name, :artist_name => song.artists.first.name, :external_url => song.external_urls['spotify']})
        Record.find_or_create_by({:song_id => db_song.id, :playlist_id => playlist.id}) # Joiner table
      end
    end


    def load_song_from_playlists(playlist)
      choices = {}
      self.songs.uniq.map.with_index(1) do |song, index|
        choices["#{index}) #{song.name} - #{song.artist_name}"] = song
      end
      # Return the selected song
      song = prompt_select("Select the song.", choices)
      Record.find_or_create_by({:song_id => song.id, :playlist_id => playlist.id}) # Joiner table
    end


    def self.register_user
      credentials = get_credentials
      # Handle for multiple users
      if User.find_by(username: credentials[:username])
        PROMPT.error("Console: This username already exists, Please choose a different username")
        sleep 2
        return nil
      end

      password = Password.create(credentials[:password]) # Hash the password
      User.create({:username => credentials[:username], :password => password})

    end

    def self.login_user
      credentials = get_credentials
      username = credentials[:username]
      password = credentials[:password]

      user = User.find_by(username: username)
        if user
          password_hash = Password.new(user.password)
          if password_hash == password then return user end
        else
          PROMPT.error("Console: Could not find a user with these credentials!")
          sleep 2
          return nil
        end
    end

    private
    def self.get_credentials
        username = PROMPT.ask('Username:') do |q|
            q.validate{|input| input.size.between?(4, 15) && input =~ /[a-zA-Z0-9]/}
        end
        password = PROMPT.mask('Password:') do |q|
            q.validate{|input| input.size.between?(4, 15) && input =~ /[a-zA-Z0-9]/}
        end
        {:username => username, :password => password}
    end
end
