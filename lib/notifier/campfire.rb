require "integrity"
require "tinder"

module Integrity
  class Notifier
    class Campfire < Notifier::Base
      attr_reader :config

      def self.to_haml
        File.read File.dirname(__FILE__) / "config.haml"
      end

      def deliver!
        room.speak "#{short_message}. #{commit_url}"
        room.paste full_message if commit.failed?
        room.leave
      end

    private
      def room
        @room ||= begin
          options = {}
          options[:ssl] = config["use_ssl"] ? true : false
          campfire = Tinder::Campfire.new(config["account"], options)
          campfire.login(config["user"], config["pass"])
          campfire.find_room_by_name(config["room"])
        end
      end

      def short_message
        "Build #{commit.short_identifier} of #{commit.project.name} #{commit.successful? ? "was successful" : "failed"}"
      end

      def full_message
        <<-EOM
Commit Message: #{commit.message}
Commit Date: #{commit.committed_at}
Commit Author: #{commit.author.name}

#{stripped_commit_output}
EOM
      end
    end

    register Campfire
  end
end
