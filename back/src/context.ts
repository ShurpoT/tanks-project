import type { Pool } from "mysql2/promise";
import { pool } from "./database";

export interface IContext {
    pool: Pool;
}

export const context: IContext = {
    pool,
};
