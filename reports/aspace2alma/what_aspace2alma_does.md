it logs errors to file
it keeps STDERR values synced so they're not going into the buffer
it writes the progress to file: time when it logged in, time when it finished, each time it completed processing a resource record, each time it completed processing a container record
it gets the Alma barcode report from sftp
it deletes MARC_out_old.xml from sftp
it renames MARC_out.xml MARC_out_old.xml on sftp
it deletes sc_active_barcodes_old.csv from sftp
it renames sc_active_barcodes.csv sc_active_barcodes_old.csv on sftp
it gets all resource records from ArchivesSpace serialized as MARC-xml
it retries when the connection hiccups
it opens a single new output file with the marx:collection wrapper element
it strips empty elements (blank text and no children or attributes)
it removes hard line breaks from note fields
it constructs a 001 from 099$a
it constructs a 003 "PULFA"
it constructs a 035 from "(PULFA)"+099$a
it constructs a 040 for each 040 with $a NjP $b eng $e dacs $c NjP
it constructs a 046 from 008 with $a i $c 008.content[7..10] $e 008.content[11..14]
it discards all but the first 520 [this may need reviewing in light of bilingual description]
it truncates the 520 at 7,999 characters
it does the following for each 6xx/7xx
    - splits $a at "--"
    - strips whitespace from each segment of the split
    - creates a new $a and populates it with the first segment
    - checks each subsequent segment:
        - if it starts with two digits, it creates a new $y for it
        - else it creates a new $x for it
    - if it has $0 that contains value "viaf", it recodes the field to $1
    - if it has ind2 set to "7" and $2 set to "viaf", it removes $2 and sets ind2 to "0"
    - it checks whether the last subfield (or second-to-last when $2 is the last) ends with punctuation (?-.) and adds "." if not
it removes
    - 852
    - 500
    - 524
    - 535
    - 540
    - 541
    - 544
    - 561
    - 583
it replaces the 856 with a new 856 with ind1 "4", ind2 "2", $z Search and Request, $u [kept from 865$u], $y Princeton University Library Finding Aids
it constructs a new 982 for each 500 that matches a location code and puts the code in $c
    - (sca)?(anxb|ea|ex|flm|flmp|gax|hsvc|hsvm|mss|mudd|prnc|rarebooks|rcpph|rcppf|rcppl|rcpxc|rcpxg|rcpxm|rcpxr|st|thx|wa|review|oo|sc|sls)
it checks each top_container record of the current resource
    - if its location code is a ReCAP location and it has a barcode and the barcode is not included in the Alma barcode report, it constructs a 949 with $a [barcode], $b [container type + container indicator], $c [container location code], $d ["(PULFA)"+099]
it appends the record to the output file
it excludes records with blank 856 and with call number /^(C0140|C1771|AC214|AC364|C0744.06|C0935)$/
it adds a delay of 0.25 before doing the next record to get around rate limiting
it sends the output file to sftp





