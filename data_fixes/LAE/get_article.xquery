xquery version "3.1";
declare variable $input as document-node()* := doc("file:/Users/heberleinr/Downloads/LAE.xml");

<xml>
{for $a in $input//article
return
$a}
</xml>