class Controller 
    attr_accessor :user
    attr_reader :prompt

    def initialize
        @prompt = TTY::Prompt.new 
    end

    def greetings 
        puts "Welcome to Spotify App"
        prompt.select("Do you have an account") do |menu|
            menu.choice "Register", -> {User.register_user}
            menu.choice "Login", -> {User.login_user}
        end
    end
end