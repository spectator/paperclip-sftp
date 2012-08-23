require "test_helper"

class UnitTest < MiniTest::Should::TestCase
  setup do
    @file = fixture_file("ruby.png")
  end

  context "with credentials provided as options" do
    should "persist credentials" do
      dummy = Dummy.new(avatar: @file)
      assert_equal :sftp, dummy.avatar.options[:storage]
      assert_equal "localhost", dummy.avatar.options[:sftp_options][:host]
      assert_equal "spectator", dummy.avatar.options[:sftp_options][:user]
      assert_equal "password", dummy.avatar.options[:sftp_options][:password]
    end
  end

  context "#exists?" do
    setup do
      @dummy = Dummy.create!(avatar: @file)
    end

    should "have file" do
      assert @dummy.avatar.exists?, "File doesn't exist in desired location"
    end

    should "not have file" do
      cleanup
      assert !@dummy.avatar.exists?, "File is still exists, but should not"
    end
  end

  context "#copy_to_local_file" do
    setup do
      @dummy = Dummy.create!(avatar: @file)
      @dest = File.expand_path(File.join(File.dirname(__FILE__), 'tmp', 'new_file.png'))
    end

    should "copy to local file" do
      @dummy.avatar.copy_to_local_file(:original, @dest)
      assert File.exist?(@dest), "File was not copied to desired location"
    end

    should "not copy file if #original_filename is nil" do
      @dummy.avatar.instance_write(:file_name, nil)
      assert !@dummy.avatar.exists?, "File shouldn't be found if avatar_file_name is empty"
    end

    should "not copy to local file if remote file doesn't exist" do
      @dummy.avatar.copy_to_local_file(:original, @dest)
      cleanup
      assert !File.exist?(@dest), "File shouldn't be found"
    end
  end

  context "#flush_writes" do
    should "write files to remote files" do
      dummy = Dummy.new(avatar: @file)
      dummy.avatar.flush_writes
      assert File.file?(dummy.avatar.path), "File was not written down"
    end
  end

  context "#flush_deletes" do
    should "delete files scheduled for deletion" do
      dummy = Dummy.create!(avatar: @file)
      avatar = dummy.avatar.path
      dummy.avatar.send :queue_all_for_delete
      dummy.avatar.flush_deletes
      assert !File.file?(avatar), "File was not deleted"
    end
  end

  teardown do
    @file.close
    cleanup
  end
end
