require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

resource_uris = %w[/repositories/8/resources/4071
                   /repositories/8/resources/4113
                   /repositories/8/resources/4024
                   /repositories/8/resources/4025
                   /repositories/8/resources/4026
                   /repositories/8/resources/4028
                   /repositories/8/resources/4029
                   /repositories/8/resources/4030
                   /repositories/8/resources/4031
                   /repositories/8/resources/4032
                   /repositories/8/resources/4033
                   /repositories/8/resources/4034
                   /repositories/8/resources/4035
                   /repositories/8/resources/4037
                   /repositories/8/resources/4038
                   /repositories/8/resources/4039
                   /repositories/8/resources/4040
                   /repositories/8/resources/4041
                   /repositories/8/resources/4042
                   /repositories/8/resources/4043
                   /repositories/8/resources/4044
                   /repositories/8/resources/4045
                   /repositories/8/resources/4046
                   /repositories/8/resources/4047
                   /repositories/8/resources/4048
                   /repositories/8/resources/4049
                   /repositories/8/resources/4051
                   /repositories/8/resources/4052
                   /repositories/8/resources/4053
                   /repositories/8/resources/4054
                   /repositories/8/resources/4055
                   /repositories/8/resources/4056
                   /repositories/8/resources/4057
                   /repositories/8/resources/4058
                   /repositories/8/resources/4059
                   /repositories/8/resources/4060
                   /repositories/8/resources/4061
                   /repositories/8/resources/4062
                   /repositories/8/resources/4063
                   /repositories/8/resources/4067
                   /repositories/8/resources/4069
                   /repositories/8/resources/4070
                   /repositories/8/resources/4072
                   /repositories/8/resources/4073
                   /repositories/8/resources/4075
                   /repositories/8/resources/4076
                   /repositories/8/resources/4077
                   /repositories/8/resources/4078
                   /repositories/8/resources/4079
                   /repositories/8/resources/4080
                   /repositories/8/resources/4081
                   /repositories/8/resources/4083
                   /repositories/8/resources/4088
                   /repositories/8/resources/4089
                   /repositories/8/resources/4090
                   /repositories/8/resources/4093
                   /repositories/8/resources/4095
                   /repositories/8/resources/4096
                   /repositories/8/resources/4098
                   /repositories/8/resources/4100
                   /repositories/8/resources/4101
                   /repositories/8/resources/4102
                   /repositories/8/resources/4103
                   /repositories/8/resources/4104
                   /repositories/8/resources/4105
                   /repositories/8/resources/4106
                   /repositories/8/resources/4107
                   /repositories/8/resources/4109
                   /repositories/8/resources/4110
                   /repositories/8/resources/4111
                   /repositories/8/resources/4112
                   /repositories/8/resources/4114
                   /repositories/8/resources/4116
                   /repositories/8/resources/4119
                   /repositories/8/resources/4120]

resource_uris.each do |uri|
  resource = @client.get(uri).parsed
  accessrestricts = resource['notes'].select { |note| note["type"] == "accessrestrict" }
  accessrestricts.each do |accessrestrict|
    accessrestrict['rights_restriction']['local_access_restriction_type'][0] = "Open"
  end
  post = @client.post(uri, resource)
    puts post.body
end

end_time = "Process ended: #{Time.now}"
puts end_time
