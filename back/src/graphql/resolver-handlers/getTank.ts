import { getTankData } from "../utils";

import type { IContext } from "~context";
import type { TankRow } from "~types";
import type { Tank, QueryTankArgs, TankIdentifierInput } from "~types/__generated__";

interface ISqlWhereClause {
    str: string;
    value: (string | number)[];
}

export const getTank = async (_parent: unknown, args: QueryTankArgs, ctx: IContext): Promise<Tank | null> => {
    const { str, value }: ISqlWhereClause = newFunction(args.identifier);

    const whereClause: string = str.length > 0 ? `WHERE ${str}` : "";

    const query = `
                    SELECT
                        t.*
                    FROM tanks t
                    ${whereClause}
                `;

    const [tank] = await ctx.pool.query<TankRow[]>(query, value);

    if (tank.length === 0) return null;

    return getTankData(tank[0]);
};

function newFunction({ id, uniqueCode, name, nation }: TankIdentifierInput): ISqlWhereClause {
    let str: string = "";
    let value: (string | number)[] = [];

    if (id) {
        str = "id = ?";
        value.push(id);
    } else if (uniqueCode) {
        str = "unique_code = ?";
        value.push(uniqueCode);
    } else if (name) {
        str = "LOWER(name) = ?";
        value.push(name.toLowerCase());
    } else if (nation) {
        str = "nation_id = ? AND tier_id = ? ";
        value.push(nation.nationId);
        value.push(nation.tierId);
    }

    return { str, value };
}
