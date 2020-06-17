require_relative '../config/environment'

# Check what OS the user is on, aimed to be Windows or MacOS
MACOS = !!(/darwin/ =~ RUBY_PLATFORM)
PROMPT = TTY::Prompt.new(track_history: false)

Spotify.authenticate

# Register/Login
controller_instance = Controller.new()

Controller.clear_screen
while true
  controller_instance.run
  Controller.clear_screen
end


binding.pry
