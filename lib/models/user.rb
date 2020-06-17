class User < ActiveRecord::Base
    has_many :playlists
    has_many :songs, through: :playlists

    include BCrypt
    PROMPT = TTY::Prompt.new(track_history: false)

    def listen
      # List all user songs and plays them through browser
      if self.songs.size <= 0
        PROMPT.warn("Console: You don't have any songs.")
        sleep 4
        throw :menu
      end
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

    def show_playlists
      choices = {}
      self.playlists.each_with_index do |playlist, index|
        choices["#{index + 1}) #{playlist.name}"] = playlist
      end

      playlist = prompt_select("Choose a playlist to view songs.", choices)
      if playlist.songs.empty?
        PROMPT.warn("Console: Sorry you don't have any songs here.")
        sleep 3
      else
        choices = {}
        playlist.songs.map.with_index(1) do |song, index|
          choices["#{index}) #{song.name} - #{song.artist_name}"] = song
        end
        song = prompt_select("Select a song to play.", choices)
        Spotify.launch(song.external_url) 
      end
    end

    def create_playlist
      name = PROMPT.ask("What is the playlist name?")
      # Check if a playlist exists with that name
      if self.playlists.find_by({:name => name})
        PROMPT.error("Console: You already have a playlist with that name, try again.")
      else
        Playlist.create({:name => name, :user_id => self.id})
      end
    end

    def add_song
      choice = PROMPT.select("Select a song from your playlists or Spotify", ["1) Playlists", "2) Spotify"])

      if choice == "2) Spotify"
        song = load_song_from_api
      else
        song = load_song_from_playlists
      end

      # Ask the user to select a playlist
      choices = {}
      self.playlists.each_with_index do |playlist, index|
        choices["#{index + 1}) #{playlist.name}"] = playlist
      end
      playlist = prompt_select("Select the playlist.", choices)

      # Create record joiner table
      Record.find_or_create_by({:song_id => song.id, :playlist_id => playlist.id})
    end

    def load_song_from_api
      song_name = PROMPT.ask("What is the song name?")
      songs = Spotify.find_track_by_name(song_name) # Call Spotify static class handles API calls

      choices = {}
      songs.map.with_index(1) do |song, index|
        choices["#{index}) #{song.name} - #{song.artists.first.name}"] = song
      end
      # Ask the user to select from the list of songs
      song = prompt_select("Select the song.", choices)

      # Return a new song instance
      Song.find_or_create_by({:name => song.name, :artist_name => song.artists.first.name, :external_url => song.external_urls['spotify']})
    end


    def load_song_from_playlists
      choices = {}
      self.songs.uniq.map.with_index(1) do |song, index|
        choices["#{index}) #{song.name} - #{song.artist_name}"] = song
      end
      # Return the selected song
      prompt_select("Select the song.", choices)
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
