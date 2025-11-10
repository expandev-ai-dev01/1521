import sql from 'mssql';
import { config } from '@/config';

export enum ExpectedReturn {
  None = 'None',
  Single = 'Single',
  Multi = 'Multi',
}

export interface IRecordSet<T = any> {
  recordset: T[];
  rowsAffected: number[];
}

let pool: sql.ConnectionPool | null = null;

export const getPool = async (): Promise<sql.ConnectionPool> => {
  if (!pool) {
    pool = await sql.connect({
      server: config.database.server,
      port: config.database.port,
      user: config.database.user,
      password: config.database.password,
      database: config.database.database,
      options: config.database.options,
      pool: config.database.pool,
    });
  }
  return pool;
};

export const dbRequest = async (
  routine: string,
  parameters: { [key: string]: any },
  expectedReturn: ExpectedReturn,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> => {
  try {
    const currentPool = await getPool();
    const request = transaction ? new sql.Request(transaction) : new sql.Request(currentPool);

    Object.keys(parameters).forEach((key) => {
      request.input(key, parameters[key]);
    });

    const result = await request.execute(routine);

    switch (expectedReturn) {
      case ExpectedReturn.None:
        return null;

      case ExpectedReturn.Single:
        return result.recordset[0] || null;

      case ExpectedReturn.Multi:
        if (resultSetNames && resultSetNames.length > 0) {
          const namedResults: { [key: string]: IRecordSet } = {};
          resultSetNames.forEach((name, index) => {
            namedResults[name] = {
              recordset: result.recordsets[index] || [],
              rowsAffected: result.rowsAffected,
            };
          });
          return namedResults;
        }
        return result.recordsets.map((recordset: any[]) => ({
          recordset,
          rowsAffected: result.rowsAffected,
        }));

      default:
        throw new Error('Invalid ExpectedReturn type');
    }
  } catch (error: any) {
    console.error('Database request error:', {
      routine,
      parameters,
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
};

export const beginTransaction = async (): Promise<sql.Transaction> => {
  const currentPool = await getPool();
  const transaction = new sql.Transaction(currentPool);
  await transaction.begin();
  return transaction;
};

export const commitTransaction = async (transaction: sql.Transaction): Promise<void> => {
  await transaction.commit();
};

export const rollbackTransaction = async (transaction: sql.Transaction): Promise<void> => {
  await transaction.rollback();
};

export default {
  getPool,
  dbRequest,
  beginTransaction,
  commitTransaction,
  rollbackTransaction,
  ExpectedReturn,
};
