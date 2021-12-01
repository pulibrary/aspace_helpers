# aspace_helpers
Methods, post-ASpace transformation tools, and reports to support common SC activities around ArchivesSpace.

## deploying code

### dependencies
  * ruby
  * bundler
    install by running `gem install bundler`

### deploying

  1. push a change to git
  
  1. get the latest capistrano on your local machine
     ```
     bundle install
     ```
  1. run capistrano on your local machine
     1. to install the default branch run
        ```
        cap staging deploy
        ```
     1. to deploy a different branch run
        ```
        BRANCH=<name> cap staging deploy
        ```
     NB: You may need to run this with `bundle exec`
     
     NB: You may also need to run `bundle install --path vendor/bundle` first
   1. cd to current on server (lib-jobs-stagin1 or lib-jobs-prod1)
      1. `bundle install --path vendor/bundle`
      
      NB: if it gets into a weird state (can't find a gem):
      `bundle config set --local path 'vendor/cache'`
   1. cd out and back into current as needed to get the latest current
   1. run your script and see it go! E.g.:
      ```
      bundle exec ruby my_script_name >> my_script.log 2>&1 &
      tail -300f my_script.log
      ```
