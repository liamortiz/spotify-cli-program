class Playlist < ActiveRecord::Base
    belongs_to :user
    has_many :records
    has_many :songs, through: :records

    def self.show_playlists(user)
      # Shows user playlist and gives option to remove song or play
      choices = {}
      user.playlists.each_with_index do |playlist, index|
        choices["#{index + 1}) #{playlist.name} - #{playlist.songs.size} songs"] = playlist
      end
      playlist = user.prompt_select("Choose a playlist to view songs.", choices)
      song = Song.get_song_from_playlist(playlist, user)

      choice = user.prompt_select("What do you want to do?", ["1) Play", "2) Remove"])

      if choice == "1) Play"
        song.play
      else
        record = Record.find_by({:song_id => song.id, :playlist_id => playlist.id})
        record.destroy
        PROMPT.warn("Console: Song removed from playlist.")
        sleep 2
      end
    end

    def self.create_playlist(user)
      name = PROMPT.ask("Console: What is the playlist name?")
      # Check if a playlist exists with that name
      if user.playlists.find_by({:name => name})
        PROMPT.error("Console: You already have a playlist with that name, try again.")
      else
        PROMPT.warn("Console: Playlist #{name} created!")
        sleep 2
        self.create({:name => name, :user_id => user.id})
      end
    end

    def self.remove_playlist(user)
      # Removes the playlist from user along with joinner table and songs
      choices = {}
      user.playlists.map.with_index(1) do |playlist, index|
        choices["#{index}) #{playlist.name} - #{playlist.songs.size} songs."] = playlist
      end
      playlist = user.prompt_select("Choose the playlist.", choices)
      PROMPT.warn("Console: The playlist #{playlist.name} was removed!")
      playlist.destroy
      sleep 2
    end

    def self.get_playlist(user)
      choices = {}
      user.playlists.each_with_index do |playlist, index|
        choices["#{index + 1}) #{playlist.name}"] = playlist
      end
      user.prompt_select("Select the playlist to populate.", choices)
    end
end
