class User < ActiveRecord::Base
    has_many :playlists
    has_many :songs, through: :playlists

    include BCrypt

    def play_songs
      # List all user songs and plays them through browser
      choices = {}
      self.songs.uniq.map.with_index(1) do |song, index|
        choices["#{index}) #{song.name} - #{song.artist_name}"] = song
      end
      song = prompt_select("Choose a song to play.", choices)
      song.play
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
