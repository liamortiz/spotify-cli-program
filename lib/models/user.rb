class User < ActiveRecord::Base
    has_many :playlists
    has_many :songs, through: :playlists
    include BCrypt

    PROMPT = TTY::Prompt.new

    attr_accessor :username, :password

    def listen
      choices = self.songs.map do |song|
        "#{song.name} - #{song.artist_name}"
      end
      song_name = PROMPT.select("Console: Choose a song", choices.push("exit"))

      # Select the song
      binding.pry

    end

    def self.register_user
        get_credentials
        if User.find_by(username: @username)
            puts "This username already exists, Please choose a different username"
         else
            password = Password.create(@password) # Hash the password
            User.create({:username => @username, :password => @password})
         end
    end

    def self.login_user
        get_credentials

        user = User.find_by(username: @username)
        if user
            password_hash = Password.new(user.password)
            if password_hash == @password
                return user
            end

        end
    end

    private
    def self.get_credentials
        @username = PROMPT.ask('Username:') do |q|
            q.validate{|input| input.size.between?(4, 15) && input =~ /[a-zA-Z0-9]/}
        end
        @password = PROMPT.mask('Password:') do |q|
            q.validate{|input| input.size.between?(4, 15) && input =~ /[a-zA-Z0-9]/}
        end
    end


end
