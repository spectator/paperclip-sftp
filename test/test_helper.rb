require "paperclip-sftp"
require "minitest/autorun"
require "minitest/should"
require "active_record"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

def define_schema
  ActiveRecord::Schema.define(:version => 1) do
    create_table :dummies do |t|
      t.string  :avatar_file_name, :avatar_content_type
      t.integer :avatar_file_size
    end
  end
end

silence_stream(STDOUT) do
  define_schema
end

def fixture_file(file)
  File.new(File.join(File.dirname(__FILE__), "fixtures", file), 'rb')
end

def cleanup
  FileUtils.rm_rf(File.expand_path(File.join(File.dirname(__FILE__), 'tmp')))
end

Paperclip.options[:log] = false
Paperclip.interpolates(:work_dir) do |attachment, style|
  File.expand_path(File.join(File.dirname(__FILE__), 'tmp'))
end

class Dummy < ActiveRecord::Base
  include Paperclip::Glue

  has_attached_file :avatar,
    path: ":work_dir/:class/:attachment/:id_partition/:style/:filename",
    storage: :sftp,
    sftp_options: {
      host: "localhost",
      user: "spectator",
      password: "password"
    }
end
