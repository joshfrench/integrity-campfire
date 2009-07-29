require File.dirname(__FILE__) + "/helper"

context "The Campfire notifier" do
  setup do
    setup_database

    @config = { "account" => "integrity",
      "use_ssl" => false,
      "room"    => "ci",
      "user"    => "foo",
      "pass"    => "bar",
      "announce_success" => true }
    @notifier = Integrity::Notifier::Campfire
    @room = stub(:speak => nil, :paste => nil, :leave => nil)
  end

  def notifier
    "Campfire"
  end

  test "it registers itself" do
    assert_equal @notifier, Integrity::Notifier.available["Campfire"]
  end

  test "configuration form" do
    assert_form_have_option "account", @config["account"]
    assert_form_have_option "use_ssl", @config["use_ssl"]
    assert_form_have_option "room",    @config["room"]
    assert_form_have_option "user",    @config["user"]
    assert_form_have_option "pass",    @config["pass"]
    assert_form_have_option "announce_success", @config["announce_success"]
  end

  test "ssl" do
    @config["use_ssl"] = true

    Tinder::Campfire.expects(:new).with(@config["account"], { :ssl => true }).
      returns(stub(:login => true, :find_room_by_name => @room))

    @notifier.notify_of_build(Integrity::Build.gen, @config)
  end

  test "successful build" do
    build = Integrity::Build.gen(:successful)

    @notifier.any_instance.stubs(:room).at_least_once.returns(@room)
    @room.expects(:speak).with { |value| value.include?(build.commit.identifier) }
    @room.expects(:paste).never

    @notifier.notify_of_build(build, @config)
  end

  test "don't announce successes" do
    build = Integrity::Build.gen(:successful)

    @config['announce_success'] = false
    @notifier.any_instance.stubs(:room).at_least_once.returns(@room)
    @room.expects(:speak).never

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
