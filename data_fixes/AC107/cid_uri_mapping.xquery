xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";

declare variable $EAD as document-node()+ := collection("/Users/heberleinr/Documents/aspace_helpers/data_fixes/AC107/EADs?recurse=yes;select=*.xml")/doc(document-uri(.));

for $c in $EAD//ead:c
return
$c/@id || '^' || $c/ead:did/ead:unitid[@type='aspace_uri'] || codepoints-to-string(10)

