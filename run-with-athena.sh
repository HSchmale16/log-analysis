#!/usr/bin/env bash

function get_status_string() {
    echo $1 | jq .QueryExecution.Status.State | tr -d '"'
}

function get_output_location() {
    echo $1 | jq .QueryExecution.ResultConfiguration.OutputLocation | tr -d '"'
}

read -r -d '' QUERY_STR <<'EOF'
SELECT
	the_url.S
	, REPLACE(CAST(as_of_when.S AS VARCHAR), '-', '/')
	, today_count.N
FROM hitcountsv6
WHERE the_url.S LIKE '/20%.html'
-- SELECT 
--     the_url,
--     REPLACE(CAST(as_of_when AS VARCHAR), '-', '/'),
--     today_count
-- FROM "attributes_as_top_level_columns"
-- WHERE the_url LIKE '/20%.html' 
-- ORDER BY as_of_when DESC, today_count DESC
EOF

exec_id_json=$(aws athena start-query-execution \
    --query-string "$QUERY_STR" \
    --work-group primary \
    --query-execution-context Database=default \
    --result-configuration "OutputLocation=s3://codebuild-hjs-artifacts/athena/$(date +%Y/%m/%d)")
exec_id=$(echo $exec_id_json | jq '.QueryExecutionId' | tr -d '"')

while true
do
    json=$(aws athena get-query-execution --query-execution-id $exec_id)
    status_str=$(get_status_string "$json")
    echo $status_str
    if [ "$status_str" == 'SUCCEEDED' ]
    then
        output_loc=$(get_output_location "$json")
        break
    fi
    sleep 0.2
done

aws s3 cp $output_loc athenaResults.csv

#cat <(tr -d '"' < athenaResults.csv) old.csv > athenaResults2.csv
sed '1d' athenaResults.csv > articleViews.csv
./make_plots.R
