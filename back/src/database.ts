import mysql from "mysql2";
import type { Pool } from "mysql2/promise";

import dotenv from "dotenv";

dotenv.config();

export const pool: Pool = mysql
    .createPool({
        host: process.env.MYSQL_HOST,
        port: Number(process.env.MYSQL_PORT),
        database: process.env.MYSQL_DATABASE,
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
    })
    .promise();
