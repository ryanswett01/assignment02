import fs from 'fs';

const pwdPath = '/home/mjumbewu/Downloads/PWD_PARCELS.geojson';

function cleanAttrNames(record) {
  const newRecord = {};
  for (const key in record) {
    const newKey = key.replace(/ /g, '_').toLowerCase();
    newRecord[newKey] = record[key];
  }
  return newRecord;
}

// Read data from pwd file and write out as JSON-L
const pwdData = JSON.parse(fs.readFileSync(pwdPath, 'utf8'));
for (const feature of pwdData.features) {
  feature.properties.geometry = JSON.stringify(feature.geometry);
  console.log(JSON.stringify(cleanAttrNames(feature.properties)));
}