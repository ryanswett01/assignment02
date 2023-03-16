import { expect, describe, it, jest } from '@jest/globals';
import './jest_extensions';


describe('Query 01', () => {
  it('should return the correct results', async () => {
    await expect('../query01.sql')
      .toReturnRecords(
      	['expected_results/query01.csv'],
      	{ orderBy: 'estimated_pop_800m desc, geog desc' }
      	);
  });
});

