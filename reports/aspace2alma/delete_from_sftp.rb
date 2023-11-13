require 'net/sftp'

filename = "MARC_out.xml"
$stderr.reopen("log_err.txt", "w")

def remove_file(path)
    Net::SFTP.start(ENV['SFTP_HOST'], ENV['SFTP_USERNAME'], { password: ENV['SFTP_PASSWORD'] }) do |sftp|
        sftp.stat(path) do |response|
            sftp.remove!(path) if response.ok?
        end
    end
end

remove_file("/alma/aspace/#{filename}")
