require 'archivesspace/client'
require 'nokogiri'
require 'fileutils'

    def aspace_login
      #configure access
      @config = ArchivesSpace::Configuration.new({
                                                   base_uri: ENV.fetch('ASPACE_URL', nil),
        base_repo: "",
        username: ENV.fetch('ASPACE_USER', nil),
        password: ENV.fetch('ASPACE_PASSWORD', nil),
        #page_size: 50,
        throttle: 0,
        verify_ssl: false
                                                 })
      #log in
      @client = ArchivesSpace::Client.new(@config).login
    end
      aspace_login
      repos = (11..12).to_a
      repos.each do |repo|
        # make directories if they don't already exist
        dir =
          case repo
          when 3
              "mudd/publicpolicy"
          when 4
              "mudd/univarchives"
          when 5
              "mss"
          when 6
              "rarebooks"
          when 7
              "cotsen"
          when 8
              "lae"
          when 9
              "eng"
          when 10
              "selectors"
          when 11
              "ga"
          when 12
              "ea"
          end
          FileUtils.mkdir_p(dir)

        #get resource ids
        resource_ids = @client.get("/repositories/#{repo}/resources", {
                                     query: {
                                       all_ids: true
                                     }
                                   }).parsed
        #get eads from ids
        eads =
          resource_ids.map do |id|
            record = @client.get("/repositories/#{repo}/resource_descriptions/#{id}.xml")
            ead = Nokogiri::XML(record.body)
            #i shouldn't have to do this but I do
            ead.remove_namespaces!
            eadid = ead.at_xpath('//eadid/text()')
            #save file with eadid as file name
            file =  File.open("./#{dir}/#{eadid}.EAD.xml", "w")
            #add back a default namespace
            ead.child.add_namespace('ead', 'http://www.loc.gov/ead/ead')
            file << ead
            file.close
          end
      end
