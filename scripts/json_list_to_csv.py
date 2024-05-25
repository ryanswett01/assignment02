import csv
import json
import sys

# Read json data from standard input
data = json.load(sys.stdin)

# Write csv data to standard output
writer = csv.writer(sys.stdout)
writer.writerows(data)
