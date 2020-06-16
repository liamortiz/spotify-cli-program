require_relative '../config/environment'

# Check what OS the user is on, aimed to be Windows or MacOS
MACOS = !!(/darwin/ =~ RUBY_PLATFORM)
puts "DEBUG: The user is on a #{(MACOS ? "Mac." : "Windows computer.")}"

Spotify.authenticate


controller_instance = Controller.new()
userChoice = controller_instance.greetings()

until !userChoice.nil?
    sleep 3
    userChoice = controller_instance.greetings()
end

binding.pry
