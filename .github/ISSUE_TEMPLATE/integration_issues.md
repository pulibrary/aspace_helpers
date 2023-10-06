This template is for reporting issues with the ASpace-Alma integration, including exporting from ASpace, importing to Alma, or sending ASpace items to ReCAP.

See [this chart](https://github.com/pulibrary/lib_jobs/tree/main/docs/aspace2alma) for an overview of the integration steps.

The script is called `get_MARCxml_with_items.rb` and is scheduled to run nightly.

### Things to check

- [ ] check the datestamp of the `MARC_out.xml` file on lib-jobs-prod2

      (did the export run?)
- [ ] check `log_err.txt` and `log_out.txt` on lib-jobs-prod2

      (did the export finish without errors?
      log_err will have error messages, if any; log_out will have the progress        of the export with start and end times.)
- [ ] check the datestamp of the `MARC_out.xml` file and/or log files on lib-
      sftp-prod1

      (did the file get transferred from lib-jobs to lib-sftp?)
- [ ] check the datestamp of the `ASpace to Alma With Items` import profile

      Admin > Monitor Jobs > `ASpace to Alma With Items`

### If something goes wrong

Disable the `ASpace to Alma With Items` import profile to suspend further imports to Alma while troubleshooting. (You may need the Alma team to do this.)
 

