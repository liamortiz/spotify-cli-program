class User < ActiveRecord::Base
    has_many :playlists
    has_many :songs, through: :playlists

    attr_accessor :prompt
    include BCrypt

    # def initialize
    #     @prompt = TTY::Prompt.new 
    # end

    def self.register_user
        @prompt = TTY::Prompt.new 
        username = @prompt.ask("Username:")
        
        if User.find_by(username: username)
            puts "This username already exists, Please choose a different username"
         else
            password = @prompt.mask("Password:")
            password = Password.create(password) # Hash the password
            User.create({:username => username, :password => password})
         end
    end

    def self.login_user
        @prompt = TTY::Prompt.new 
        username = @prompt.ask("Username:")
        user = User.find_by(username: username)
        if user
            password = @prompt.mask("Password:")
            password_hash = Password.new(user.password)
            if password_hash == password 
                puts "Welcome!"
            end
        end
    end

    def self.create_playlist 
        
    end
end