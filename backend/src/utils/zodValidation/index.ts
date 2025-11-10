import { z } from 'zod';

export const zString = z.string().min(1);

export const zNullableString = (maxLength?: number) => {
  let schema = z.string();
  if (maxLength) {
    schema = schema.max(maxLength);
  }
  return schema.nullable();
};

export const zName = z.string().min(1).max(200);

export const zNullableDescription = z.string().max(500).nullable();

export const zFK = z.coerce.number().int().positive();

export const zNullableFK = z.coerce.number().int().positive().nullable();

export const zBit = z.coerce.number().int().min(0).max(1);

export const zDateString = z
  .string()
  .refine((val) => !isNaN(Date.parse(val)), { message: 'Invalid date format' });

export const zEmail = z.string().email();

export const zNumeric = (precision: number = 15, scale: number = 2) => {
  return z.coerce.number();
};

export const zPrice = z.coerce.number();

export default {
  zString,
  zNullableString,
  zName,
  zNullableDescription,
  zFK,
  zNullableFK,
  zBit,
  zDateString,
  zEmail,
  zNumeric,
  zPrice,
};
