#!/usr/bin/env node

fs = require('fs')
ptags = require('./posttags.json')
parse = require('csv-parse')

csvData = []
counter = {};

fs.createReadStream('x.csv')
    .pipe(parse({delimiter: ','}))
    .on('data', function(row) {
        if(typeof(ptags[row[0]]) !== 'undefined')
        ptags[row[0]].forEach((tag) => {
            if(typeof(counter[tag]) === 'undefined')
                counter[tag] = {cnt: Number(row[1]), pst: 1}
            else {
                counter[tag].cnt += Number(row[1])
                counter[tag].pst++
            }
        })
    })
    .on('end', () => {
        Object.keys(counter).forEach((x) => {
            console.log(x,',',counter[x].cnt / counter[x].pst)
        })
    })
