xquery version "3.1";
declare namespace saxon="http://saxon.sf.net/";
declare copy-namespaces no-preserve, inherit;
declare option saxon:output "omit-xml-declaration=yes";

declare variable $eads as document-node()+ := collection("file:///Users/heberleinr/Documents/SVN_Working_Copies/trunk/eads?recurse=yes;select=*.xml");

for $ead in $eads[//archdesc/did/langmaterial[language[.="" and @langcode[not(.="")]]]]
return 
string-join($ead//archdesc/did/langmaterial[language[.="" and @langcode[not(.="")]]]/language/@langcode, ",") || "^" ||
($ead//unitid)[1] || "^" ||
($ead//unitid[@type="aspace_uri"])[1] ||
codepoints-to-string(10)

(:count($eads[//archdesc/did/langmaterial[language[.="" and @langcode[not(.="")]]]])
:)