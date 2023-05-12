// eslint-disable-next-line no-unused-vars
import { expect, describe, it, jest } from '@jest/globals';
import './jest_extensions';

describe('Query 04', () => {
  it('should return the correct results', async () => {
    await expect('../query04.sql')
      .toReturnRecords([
        'expected_results/query04.csv',
        'expected_results/query04_alt.csv',
      ]);
  });
});