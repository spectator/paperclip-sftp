require "test_helper"

class IntegrationTest < Minitest::Should::TestCase

  setup do
    @file = fixture_file("ruby.png")
  end

  should "create attachment and its files" do
    dummy = Dummy.create!(avatar: @file)

    assert File.file?(dummy.avatar.path), "File was not uploaded"
  end

  should "delete attachment and its files" do
    dummy = Dummy.create!(avatar: @file)

    avatar = dummy.avatar.path
    dummy.destroy
    assert !File.file?(avatar), "File was not deleted"
  end

  teardown do
    @file.close
    cleanup
  end

end
