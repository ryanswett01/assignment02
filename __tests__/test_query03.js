import { expect, describe, it, jest } from '@jest/globals';
import './jest_extensions';

jest.setTimeout(120000);


describe('Query 03', () => {
  it('should return the correct results', async () => {
    await expect('../query03.sql')
      .toReturnRecords(
      	[
          'expected_results/query03_short.csv',
          'expected_results/query03_short_alt.csv',
        ],
      	{ orderBy: 'distance desc, stop_name desc, parcel_address desc', limit: 5 },
      	);
  });

  it('should return the correct results in reverse', async () => {
    await expect('../query03.sql')
      .toReturnRecords(
      	[
          'expected_results/query03_short_reverse.csv',
          'expected_results/query03_short_reverse_alt.csv',
        ],
      	{ orderBy: 'distance asc, stop_name asc, parcel_address asc', limit: 5 },
  	  );
  });
});





