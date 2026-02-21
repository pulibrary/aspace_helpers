xquery version "3.1";
declare namespace serialize = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option serialize:item-separator "&#xa;";
declare option saxon:output "omit-xml-declaration=yes";
declare variable $input as document-node()* := doc("file:/Users/heberleinr/Documents/LAE/LAE_articles.xml");


for $article in $input//article
return
normalize-space(
$article//dd[@class="col-md-9 blacklight-figgy_title_ssi"] || '^' ||
("https://figgy.princeton.edu" || ($article//a[starts-with(@href, '/catalog')])[1]/data(@href)) || '^' ||
$article//dd[@class="col-md-9 blacklight-source_metadata_identifier_ssim"] || '^' ||
$article//dd[@class="col-md-9 blacklight-identifier_ssim"] || '^' ||
$article//dd[@class="col-md-9 blacklight-state_ssim"] || '^' ||
$article//dd[@class="col-md-9 blacklight-call_number_tsim"]
)