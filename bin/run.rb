require_relative '../config/environment'

# Check what OS the user is on, aimed to be Windows or MacOS
MACOS = !!(/darwin/ =~ RUBY_PLATFORM)

Spotify.authenticate

# Register/Login
controller_instance = Controller.new()

Controller.clear_screen
while controller_instance.run
  sleep 1
  Controller.clear_screen
end


binding.pry
