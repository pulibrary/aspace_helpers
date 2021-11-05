# aspace_helpers
Methods, post-ASpace transformation tools, and reports to support common SC activities around ArchivesSpace.

## deploying code

### dependncies
  * ruby
  * bundler
    install by running `gem install bundler`

### deploying

  1. get the lates capistrano
     ```
     bundle install
     ```
  1. run capisytano
     1. to install the default branch run
        ```
        cap staging deploy
        ```
     1. to deploy a different branch run
        ```
        BRANCH=<name> cap staging deploy
        ```
