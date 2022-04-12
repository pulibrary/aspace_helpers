# aspace_helpers
Methods, post-ASpace transformation tools, and reports to support common SC activities around ArchivesSpace. For a detailed introduction to working with this repository, see [this workshop](https://github.com/pulibrary/ruby-for-archivesspace/tree/main/sessions/session2-aspace-intro).

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
     1. `bundle install --path vendor/bundle`
     
     1. to install the default branch run
        ```
        bundle exec cap staging deploy
        ```
        to deploy a different branch run
        ```
        BRANCH=<name> bundle exec cap staging deploy
        ```

###  running a script on the server
     
   1. server (`lib-jobs-staging1` or `lib-jobs-prod1`): as `deploy` user:
      1. `cd /opt/aspace_helpers/current`
      1. `bundle install --path vendor/bundle`
      
      NB: if it gets into a weird state (can't find a gem):
      `bundle config set --local path 'vendor/cache'`
   1. cd out and back into current as needed to get the latest current
   1. run your script and see it go! E.g.:
      ```
      bundle exec ruby my_script_name >> my_script.log 2>&1 &
      tail -300f my_script.log
      ```
