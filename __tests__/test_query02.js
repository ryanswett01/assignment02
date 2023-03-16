import { expect, describe, it, jest } from '@jest/globals';
import './jest_extensions';


describe('Query 02', () => {
  it('should return the correct results', async () => {
    await expect('../query02.sql')
      .toReturnRecords(
      	['expected_results/query02.csv'],
      	{ orderBy: 'estimated_pop_800m, geog'});
  });
});