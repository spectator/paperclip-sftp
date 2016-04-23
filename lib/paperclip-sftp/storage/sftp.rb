module Paperclip
  module Storage
    # SFTP (Secure File Transfer Protocol) storage for Paperclip.
    #
    module Sftp

      # SFTP storage expects a hash with following options:
      # :host, :user, :password, :port.
      #
      def self.extended(base)
        begin
          require "net/sftp"
        rescue LoadError => e
          e.message << "(You may need to install net-sftp gem)"
          raise e
        end unless defined?(Net::SFTP)

        base.instance_exec do
          @sftp_options = options[:sftp_options] || {}
        end
      end

      # Make SFTP connection, but use current one if exists.
      #
      def sftp
        @sftp ||= Net::SFTP.start(
          @sftp_options[:host],
          @sftp_options[:user],
          port: @sftp_options[:port],
          keys: [@sftp_options[:keys]]
        )
      end

      def exists?(style = default_style)
        if original_filename
          files = sftp.dir.entries(File.dirname(path(style))).map(&:name)
          files.include?(File.basename(path(style)))
        else
          false
        end
      rescue Net::SFTP::StatusException => e
        false
      end

      def copy_to_local_file(style, local_dest_path)
        log("copying #{path(style)} to local file #{local_dest_path}")
        sftp.download!(path(style), local_dest_path)
      rescue Net::SFTP::StatusException => e
        warn("#{e} - cannot copy #{path(style)} to local file #{local_dest_path}")
        false
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          mkdir_p(File.dirname(path(style)))
          log("uploading #{file.path} to #{path(style)}")
          sftp.upload!(file.path, path(style))
          sftp.setstat!(path(style), :permissions => 0644)
        end

        after_flush_writes # allows attachment to clean up temp files
        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          begin
            log("deleting file #{path}")
            sftp.remove(path).wait
          rescue Net::SFTP::StatusException => e
            # ignore file-not-found, let everything else pass
          end

          begin
            path = File.dirname(path)
            while sftp.dir.entries(path).delete_if { |e| e.name =~ /^\./ }.empty?
              sftp.rmdir(path).wait
              path = File.dirname(path)
            end
          rescue Net::SFTP::StatusException => e
            # stop trying to remove parent directories
          end
        end

        @queued_for_delete = []
      end

      private

      # Create directory structure.
      #
      def mkdir_p(remote_directory)
        log("mkdir_p for #{remote_directory}")
        root_directory = '/'
        remote_directory.split('/').each do |directory|
          next if directory.blank?
          unless sftp.dir.entries(root_directory).map(&:name).include?(directory)
            sftp.mkdir!("#{root_directory}#{directory}")
          end
          root_directory += "#{directory}/"
        end
      end

    end
  end
end
