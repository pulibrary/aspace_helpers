require 'net/sftp'

filename = "MARC_out.xml"

def remove_file(path)
    Net::SFTP.start(ENV['SFTP_HOST'], ENV['SFTP_USERNAME'], { password: ENV['SFTP_PASSWORD'] }) do |sftp|
        sftp.stat(path) do |response|
            sftp.remove!(path) if response.ok?
        end
    end
end