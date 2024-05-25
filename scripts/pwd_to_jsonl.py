import json

pwd_path = '/home/mjumbewu/Downloads/PWD_PARCELS.geojson'


def clean_attr_names(record):
    return {
        key.replace(' ', '_').lower(): value
        for key, value in record.items()
    }


# Read data from pwd file and write out as JSON-L
with open(pwd_path, 'r', encoding='utf-8') as pwd_file:
    pwd_data = json.load(pwd_file)
    for feature in pwd_data['features']:
        feature['properties']['geometry'] = json.dumps(feature['geometry'])
        print(json.dumps(clean_attr_names(feature['properties'])))
