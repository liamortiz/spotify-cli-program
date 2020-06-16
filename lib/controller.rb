class Controller
    attr_accessor :user, :prompt

    def initialize
        @prompt = TTY::Prompt.new
    end

    def run
      if !user
        main_menu
      else
        logged_in
      end
    end

    def main_menu
        puts "Console: Welcome to the Spotify CLI App"
        @user = prompt.select("Console: Login/Register") do |menu|
            menu.choice "Register", -> {User.register_user}
            menu.choice "Login", -> {User.login_user}
        end
        true
    end

    def logged_in
      puts "Welcome, #{self.user.username}"
      prompt.select("Console: What do you want to do?") do |menu|
        menu.choice "1) Listen to a song", -> {@user.listen}
        menu.choice "2) Search for a song", -> {@user.find_song}
        menu.choice "3) Exit", -> {puts "Goodbye"}

      end
    end
end
