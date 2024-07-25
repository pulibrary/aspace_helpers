xquery version "3.0";
import module namespace functx = "http://www.functx.com" at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
declare option saxon:output "omit-xml-declaration=yes";

(:This assumes some preliminary cleanup in the data file, 
especially removing the office/table/text/calcext namespaces and prefixes and expanding the number-columns-repeated columns:)

declare variable $aclu as document-node()+ := doc("file:/Users/heberleinr/Documents/aspace_helpers/data_fixes/ACLU_transfer/Transferred_to_Princeton-December2017.xml");
let $header-row := $aclu//table-row[1]
let $records :=
for $row at $ind in subsequence($aclu//table-row, 2)
	let $folders-string := $row/table-cell[17]/string()
	let $restrictions-string := $row/table-cell[19]/string()
	let $folders := for $folder in tokenize($folders-string, "\|") return <cell label="CatFolder">{$folder}</cell>
	let $restrictions := for $restriction in tokenize($restrictions-string, "\|") return $restriction
	for $folder at $pos in $folders
	let $restriction := $restrictions[position() = $pos]
	return
		<record row="{$ind+1}">{
			for $cell at $no in ($row/table-cell[position() = (1 to 16)])
			return
				<cell label="{$header-row/table-cell[position()=$no]/string()}">{
					$cell/string()
				}</cell>,
			$folder, 
			<cell label="{$header-row/table-cell[position()=18]/string()}">{
					$row/table-cell[position() = (18)]/string()
				}</cell>,
			<cell label="CatAccessFolder">{$restriction}</cell>
		}</record>
	
	return
	(
	string-join($header-row/table-cell, "^"),
	codepoints-to-string(10),
	for $record in $records 
	return
		(
		string-join($record/cell, "^"),
		codepoints-to-string(10)
		)
	)