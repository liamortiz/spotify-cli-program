class Controller
    attr_accessor :user, :prompt

    def initialize
        @prompt = TTY::Prompt.new(track_history: false)
    end

    def run
      if !user
        main_menu
      else
        catch :menu do
          logged_in
        end
      end
    end

    def main_menu
        puts "Console: Welcome to the " + "Spotify CLI App".colorize({:background => :red})
        @user = prompt.select("Console: Login/Register") do |menu|
            menu.choice "Register", -> {User.register_user}
            menu.choice "Login", -> {User.login_user}
        end
    end

    def logged_in
      self.user.reload
      puts "Console: Logged in as " + "#{self.user.username}".colorize({:background => :red})
      
      prompt.select("Console: What do you want to do?") do |menu|
        menu.choice "1) Listen to a song", -> {@user.listen}
        menu.choice "2) Create playlist", -> {@user.create_playlist}
        menu.choice "3) Show playlists", -> {@user.show_playlists}
        menu.choice "4) Add song to playlist", -> {@user.add_song}
        menu.choice "5) Exit", -> {exit}
      end
    end

    def self.clear_screen
      system(MACOS ? "clear" : "cls")
    end
end
