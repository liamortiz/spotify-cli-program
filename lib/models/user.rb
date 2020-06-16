class User < ActiveRecord::Base
    has_many :playlists
    has_many :songs, through: :playlists
    include BCrypt

    PROMPT = TTY::Prompt.new

    def listen
      choices = self.songs.map do |song|
        "#{song.name} - #{song.artist_name}"
      end
      song_name = PROMPT.select("Console: Choose a song", choices.push("exit"))

      # Select the song
      binding.pry

    end

    def self.register_user
        username = PROMPT.ask("Username:")

        if User.find_by(username: username)
            puts "This username already exists, Please choose a different username"
         else
            password = PROMPT.mask("Password:")
            password = Password.create(password) # Hash the password
            User.create({:username => username, :password => password})
         end
    end

    def self.login_user
        username = PROMPT.ask("Username:")
        user = User.find_by(username: username)
        if user
            password = PROMPT.mask("Password:")
            password_hash = Password.new(user.password)
            if password_hash == password
                return user
            end
        end
    end
end
