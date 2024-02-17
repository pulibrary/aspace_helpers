#get agent record from uri
#make sure the agent record doesn't already have structured dates
#dates_of_existence = empty

#if both columns of the spreadsheet are populated:
# "structured_date_range"=>{"begin_date_standardized"=>"1899",
#     "end_date_standardized"=>"1961",

#if the first column of the spreadsheet is populated but the second is blank:
# "structured_date_single"=>{"date_expression"=>"b. 1864", 
#     "date_standardized"=>"1864", 
#     "date_role"=>"begin", 
#     "date_standardized_type"=>"standard", 
#     "jsonmodel_type"=>"structured_date_single"}

#if the second column of the spreadsheet is populated but the first is blank:
# "structured_date_single"=>{"date_expression"=>"died 1995",
#     "date_standardized"=>"1995",
#     "date_role"=>"end",

