require 'net/sftp'

filename = "MARC_out.xml"
$stderr.reopen("log_err.txt", "w")

def remove_file(path)
    Net::SFTP.start(ENV.fetch('SFTP_HOST', nil), ENV.fetch('SFTP_USERNAME', nil), { password: ENV.fetch('SFTP_PASSWORD', nil) }) do |sftp|
        sftp.stat(path) do |response|
            sftp.remove!(path) if response.ok?
        end
    end
end

remove_file("/alma/aspace/#{filename}")
