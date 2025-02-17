# aspace_helpers
Methods, post-ASpace transformation tools, and reports to support common SC activities around ArchivesSpace. For a detailed introduction to working with this repository, see [this workshop](https://github.com/pulibrary/ruby-for-archivesspace/tree/main/sessions/session2-aspace-intro).

The ArchivesSpace API documentation can be found here: https://archivesspace.github.io/archivesspace/api/?shell#get-a-list-of-preferences-for-a-repository-and-optionally-a-user

The general data model and system architecture are described here: https://archivesspace.org/application/original-system-overview

Dependencies: `aspace_helpers` depends on the archivesspace-client gem: https://github.com/lyrasis/archivesspace-client

## deploying code

### dependencies
  * ruby
  * bundler
    install by running `gem install bundler`

### deploying

  1. locally: push a change to git
  
  1. locally: get the latest capistrano on your local machine
     ```
     bundle install
     ```
  1. locally: run capistrano
     1. `bundle install`
     
     1. to install the default branch run
        ```
        bundle exec cap staging deploy
        ```
        to deploy a different branch run
        ```
        BRANCH=<name> bundle exec cap staging deploy
        ```

###  running a script on the server
     
   1. server (`lib-jobs-staging2` or `lib-jobs-prod2`): as `deploy` user:
      1. `cd /opt/aspace_helpers/current`
      1. `bundle install`
      
   1. cd out and back into current as needed to get the latest current
   1. run your script and see it go! E.g.:
      ```
      bundle exec ruby my_script_name >> my_script.log 2>&1 &
      tail -300f my_script.log
      ```

### Authenticating through environment variables

aspace_helpers uses 4 environment variables to connect to Aspace:

1. ASPACE_USER
1. ASPACE_PASSWORD
1. ASPACE_URL (uses the production aspace in prod environments, and the staging aspace in staging environments)
1. ASPACE_STAGING_URL (only set in staging and dev environments)

To test that your environment has the correct environment variables set,
you can run:

```
$ bundle exec ruby test_connection.rb
Successfully authenticated to aspace-staging.princeton.edu
```

You can also pass those environment variables over the command line as needed:
```
$ ASPACE_USER=wrong_user ASPACE_URL=http://example.com bundle exec ruby test_connection.rb
API client login failed as user [wrong_user], check username and password are correct
```

### Tests
#### RSpec
- To run RSpec, from the root of your application, run `bundle exec rspec`
- To run a single test file, include the path to the file, e.g. `bundle exec rspec spec/reports/get_MARCxml_spec.rb`

#### Rubocop
- To run Rubocop, from the root of your application, run `bundle exec rubocop`
- To auto-correct less-risky errors, run `bundle exec rubocop -a`
- To auto-correct more risky errors (need to be double-checked by a human), run `bundle exec rubocop -A`

### Troubleshooting
- To troubleshoot the sftp connection:
  - shh onto lib-jobs-prod2
  - become the `deploy` user
  - `cd /opt/aspace_helpers/current/reports/aspace2alma`
  - create a test file to upload ("test.txt" or similar)
  - open an IRB session
  - `require_relative "get_MARCxml"`
  - `alma_sftp("test.txt")`
  - will return `nil`
  - ssh onto lib-sftp-prod1
  - navigate to `/alma/aspace`
  - test.txt should be there

