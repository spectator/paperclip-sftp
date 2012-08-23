[![Dependency Status](https://gemnasium.com/spectator/paperclip-sftp.png?travis)](https://gemnasium.com/spectator/paperclip-sftp)

Paperclip SFTP
==============

Paperclip SFTP is Secure File Transfer Protocol storage for [Paperclip](https://github.com/thoughtbot/paperclip)

Installation
------------

```ruby
gem 'paperclip-sftp', '~> 1.0.0'
```

Usage
-----

```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar,
    storage: :sftp,
    sftp_options: {
      host: "sftp.example.com",
      user: "user",
      password: "password"
    }
end
```

You can define these options globally, enable this storage for specific environments, etc. Please see [Paperclip](https://github.com/thoughtbot/paperclip) github page for more details.

Running tests
-------------

All tests are live so in order to run them you need to setup local SFTP server. That will take at most 5 minutes on either MacOS or Linux. Connection is defined in `test/test_helper.rb` if you need to change it.

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
