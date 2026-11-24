import pg from "pg";

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // Render PostgreSQL commonly requires SSL for external connections.
  // Enable only in production; local PostgreSQL usually does not use SSL.
  ssl: process.env.NODE_ENV === "production"
    ? { rejectUnauthorized: false }
    : false
});
