require File.dirname(__FILE__) + "/helper"


class IntegrityCampfireTest < Test::Unit::TestCase
  include RR::Adapters::TestUnit
  include Integrity::Notifier::Test

  def setup
    setup_database
    @config = { "account" => "integrity",
      "use_ssl" => false,
      "room"    => "ci",
      "user"    => "foo",
      "pass"    => "bar",
      "announce_success" => true }
    @notifier = Integrity::Notifier::Campfire
    @campfire = Tinder::Campfire.new(@config['account'])
    @room = Tinder::Room.new(@campfire, 12345)
  end

  def notifier
    "Campfire"
  end

  def test_registration
    assert_equal Integrity::Notifier::Campfire, Integrity::Notifier.available["Campfire"]
  end

  def test_configuration_form
    assert provides_option?("account", @config["account"])
    assert provides_option?("use_ssl", @config["use_ssl"])
    assert provides_option?("room",    @config["room"])
    assert provides_option?("user",    @config["user"])
    assert provides_option?("pass",    @config["pass"])
    assert provides_option?("announce_success", 1)
  end

  def test_should_use_ssl_if_configured
    stub(@campfire) do |expect|
      expect.login(@config['user'], @config['pass']) { true }
      expect.find_room_by_name(@config['room']) { @room }
    end
    mock(Tinder::Campfire).new(@config['account'], {:ssl => true}) { @campfire }

    @config['use_ssl'] = true
    @notifier.notify_of_build(Integrity::Build.gen, @config)
  end

  def test_should_speak_successful_build
    stub.instance_of(@notifier).room { @room }

    dont_allow(@room).paste
    mock(@room).speak(satisfy {|msg| msg =~ /was successful/})

    @notifier.notify_of_build(Integrity::Build.gen, @config)
  end

  def test_should_paste_failed_build
    stub.instance_of(@notifier).room { @room }

    mock(@room).speak(satisfy {|msg| msg =~ /failed/})
    mock(@room).paste(satisfy {|msg| msg =~ /#{build.commit.message}/ })

    @notifier.notify_of_build(Integrity::Build.gen(:failed), @config)
  end

  def test_should_not_announce_successful_builds_when_disabled
    stub.instance_of(@notifier).room { @room }

    dont_allow(@room).speak
    dont_allow(@room).paste

    @config['announce_success'] = false
    @notifier.notify_of_build(Integrity::Build.gen, @config)
  end
end