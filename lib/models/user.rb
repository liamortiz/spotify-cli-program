class User < ActiveRecord::Base
    has_many :playlists
    has_many :songs, through: :playlists

    include BCrypt
    PROMPT = TTY::Prompt.new

    def listen
      # List all user songs and plays them through browser
      # TODO: Check if user has any songs at all
      choices = {}
      self.songs.uniq.map do |song|
        choices["#{song.name} - #{song.artist_name}"] = song
      end
      song = PROMPT.select("Console: Choose a song", choices)
      Spotify.launch(song.external_url)
    end

    def show_playlists
      self.playlists.each_with_index do |playlist, index|
        puts "#{index + 1}) #{playlist.name}"
      end
      sleep 5
    end

    def create_playlist
      name = PROMPT.ask("What is the playlist name?")
      # Check if a playlist exists with that name
      if self.playlists.find_by({:name => name})
        puts "Console: You already have a playlist with that name, try again."
      else
        Playlist.create({:name => name, :user_id => self.id})
      end
    end

    def add_song
      song_name = PROMPT.ask("What is the song name?")

      # Call the Spotify APi and get a list of songs
      songs = Spotify.find_track_by_name(song_name)
      choices = {}

      songs.each_with_index.map do |song, index|
        choices["#{index + 1}) #{song.name} - #{song.artists.first.name}"] = song
      end

      song = PROMPT.select("Select the song", choices)
      # Create a new song instance or find it
      song = Song.find_or_create_by({:name => song.name, :artist_name => song.artists.first.name, :external_url => song.external_urls['spotify']})

      # Select the playlist
      playlist_name = PROMPT.select("Select the playlist", self.playlists.map(&:name))
      playlist = Playlist.find_by(:name => playlist_name)

      # Create record joiner table
      Record.find_or_create_by({:song_id => song.id, :playlist_id => playlist.id})
    end

    def self.register_user
      credentials = get_credentials
      username = credentials[:username]
      password = credentials[:password]
        if User.find_by(username: username)
            puts "This username already exists, Please choose a different username"
         else
            password = Password.create(password) # Hash the password
            User.create({:username => username, :password => password})
         end
    end

    def self.login_user
      credentials = get_credentials
      username = credentials[:username]
      password = credentials[:password]

      user = User.find_by(username: username)
        if user
          password_hash = Password.new(user.password)
          if password_hash == password then return user end
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
