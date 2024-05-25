import fs from 'node:fs';
import * as csv from 'csv';

// Read json data from standard in
const data = JSON.parse(fs.readFileSync(0, 'utf8'));

// Write csv data to standard out
csv.stringify(data, (err, output) => {
  if (err) throw err;
  process.stdout.write(output);
});