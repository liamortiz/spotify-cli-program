require_relative '../config/environment'

# Check what OS the user is on, aimed to be Windows or MacOS
MACOS = !!(/darwin/ =~ RUBY_PLATFORM)
puts "DEBUG: The user is on a #{(MACOS ? "Mac." : "Windows computer.")}"

Spotify.authenticate


controller_instance = Controller.new()
controller_instance.greetings()

binding.pry
