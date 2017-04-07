#!/usr/bin/env node
/** pivotTagHits.js
 *  Henry J Schmale
 *
 * Usage:
 * ./pivotTagHits.js <JSON-TAG-FILE> <ARTICLE-VIEWS-CSV>
 */

 function printUsage(){
     console.log('./pivotTagHits.js <JSON-TAG-FILE> <ARTICLE-VIEWS-CSV>')
 }

 if(process.argv !== 4){
     console.log("missing args");
     printUsage();
 }

fs = require('fs')
ptags = require(process.argv[2])
parse = require('csv-parse')

csvData = []
counter = {};

fs.createReadStream('./' + process.argv[3])
    .pipe(parse({delimiter: ','}))
    .on('data', function(row) {
        if(typeof(ptags[row[0]]) !== 'undefined')
        ptags[row[0]].forEach((tag) => {
            if(typeof(counter[tag]) === 'undefined')
                counter[tag] = {cnt: Number(row[1]), pst: 1}
            else {
                // increment the count of hits on that tag
                counter[tag].cnt += Number(row[1])
                // increment the number of posts with that tag
                counter[tag].pst++
            }
        })
    })
    .on('end', () => {
        Object.keys(counter).forEach((x) => {
            // csvf = %{tag},%{taghitcount},%{postcount}
            console.log(x, ',', counter[x].cnt, ',', counter[x].pst)
        })
    }).on('error', function(err) {
        console.log('fs.createReadStreamError', err)
    })
