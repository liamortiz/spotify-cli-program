class Controller
    attr_accessor :user, :prompt

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
        @user = PROMPT.select("Console: Login/Register") do |menu|
            menu.choice "Register", -> {User.register_user}
            menu.choice "Login", -> {User.login_user}
        end
    end

    def logged_in
      self.user.reload
      puts "Console: Logged in as " + "#{self.user.username}".colorize({:background => :red})

      PROMPT.select("Console: What do you want to do?") do |menu|
        menu.choice "1) Play Songs", -> {@user.play_songs}
        menu.choice "2) Create Playlist", -> {Playlist.create_playlist(@user)}
        menu.choice "3) Remove Playlist", -> {Playlist.remove_playlist(@user)}
        menu.choice "4) Browse Playlists", -> {Playlist.show_playlists(@user)}
        menu.choice "5) Add Song to Playlist", -> {Song.add_song(@user)}
        menu.choice "Exit", -> {exit}
      end
    end

    def self.clear_screen
      system(MACOS ? "clear" : "cls")
    end
end
