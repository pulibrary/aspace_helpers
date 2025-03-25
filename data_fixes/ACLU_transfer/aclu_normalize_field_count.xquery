xquery version "3.0";
declare default element namespace "urn:schemas-microsoft-com:office:spreadsheet";
declare option saxon:output "omit-xml-declaration=yes";

declare variable $aclu as document-node()+ := doc("file:/Users/heberleinr/Downloads/test.xml");
for $row at $ind in subsequence($aclu//Table/Row, 2)
return
	if (count($row/Cell)=18)
	then insert node $row/Cell[12] after $row/Cell[11]
	else insert node element Cell {""} after $row/Cell[11]
