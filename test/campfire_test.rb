require File.dirname(__FILE__) + '/helper'

context "The Campfire notifier" do
  setup do
    setup_database

    @config = { "account" => "integrity",
      "use_ssl" => false,
      "room"    => "ci",
      "user"    => "foo",
      "pass"    => "bar" }
    @notifier = Integrity::Notifier::Campfire
    @room = stub(:speak => nil, :paste => nil)
  end

  def notifier
    "Campfire"
  end

  test "configuration form" do
    assert_form_have_option "account", @config["account"]
    assert_form_have_option "use_ssl", @config["use_ssl"]
    assert_form_have_option "room",    @config["room"]
    assert_form_have_option "user",    @config["user"]
    assert_form_have_option "pass",    @config["pass"]
  end

  test "successful build" do
    build = Integrity::Build.gen(:successful)

    @notifier.any_instance.stubs(:room).at_least_once.returns(@room)
    @room.expects(:speak).with { |value| value.include?(build.commit.identifier) }
    @room.expects(:paste).never

    @notifier.notify_of_build(build, @config)
  end

  test "failed build" do
    build = Integrity::Build.gen(:failed)

    @notifier.any_instance.stubs(:room).at_least_once.returns(@room)
    @room.expects(:speak).with { |value| value.include?(build.commit.identifier) }
    @room.expects(:paste).with { |value|
      value.include?(build.commit.message) &&
        value.include?(build.output)
    }

    @notifier.notify_of_build(build, @config)
  end
end
