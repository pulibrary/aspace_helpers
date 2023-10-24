xquery version "3.0";

declare variable $EAD as document-node()+ := collection("file:///Users/heberleinr/Documents/SVN_Working_Copies/trunk/eads?recurse=yes;select=*.xml")/doc(document-uri(.));

(:declare variable $EAD as document-node()+ := doc("file:///Users/heberleinr/Documents/SVN_Working_Copies/trunk/eads/mudd/publicpolicy/MC147.EAD.xml");
:)

(:find links starting with http, optional 's', 
followed by letters,
followed by dot,
followed by more letters,
followed by slash, 
followed by 4 or more letters or digits:)

(:this expression is using negative lookbehind with the Saxon 'j' flag 
to exclude the shorter viaf links:)

for $value in $EAD//(*/text()|@*)[matches(., '^https?://\p{L}+?(?<!viaf)\.\p{L}+?/(\p{L}|\d){4,}$', ';j')]
return
normalize-space( 
$value/data() || ',' || 
$value//ancestor::ead//eadid || ','|| 
$value/name() || ',' ||
$value//ancestor::c[1]/@id || ',' || 
$value//ancestor::c[1]/did/unitid[@type='aspace_uri'] || ',' || 
$value//parent::*/name() || ',' || 
$value//ancestor::*[2]/name() || ',' || 
$value//ancestor::*[3]/name() 

)
|| codepoints-to-string(10)


