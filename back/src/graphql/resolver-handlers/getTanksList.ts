import type { IContext } from "~context";
import type { QueryTanksListArgs, Tank } from "~types/__generated__";
import { getTankData } from "../utils";

import type { TankRow } from "~types";

interface SqlWhereClause {
    conditions: string[];
    values: number[];
}

export const getTanksList = async (_parent: unknown, args: QueryTanksListArgs, ctx: IContext): Promise<Tank[]> => {
    const { conditions, values }: SqlWhereClause = newFunction(args);

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

    const query = `
                        SELECT
                            t.*,
                            n.id                      AS  nation_id,
                            n.name                    AS  nation_name,
                            n.display_name            AS  nation_display_name,
                            n.image_flag_url          AS  nation_image_flag_url,
                            n.image_flag_small_url    AS  nation_image_flag_small_url,
                            n.image_overlap_url       AS  nation_image_overlap_url,
                            n.image_ico_url           AS  nation_image_ico_url,

                            tp.id                     AS  type_id,
                            tp.name                   AS  type_name,
                            tp.image_url              AS  type_image_url,
                            tp.image_ico_url          AS  type_image_ico_url,

                            tr.id                     AS  tier_id
                          
                        FROM tanks t
                        LEFT JOIN tank_nations n ON t.nation_id = n.id
                        LEFT JOIN tank_types tp ON t.type_id = tp.id
                        LEFT JOIN tank_tiers tr ON t.tier_id = tr.id
                        ${whereClause}
                    `;

    const [rows] = await ctx.pool.query<TankRow[]>(query, values);

    return rows.map((row: TankRow) => getTankData(row));
};

function newFunction({ nationIds, typeIds, tierIds }: QueryTanksListArgs): SqlWhereClause {
    const conditions: string[] = [];
    const values: number[] = [];

    if (nationIds && nationIds.length > 0) {
        conditions.push(`nation_id IN (${nationIds.map(() => "?").join(",")})`);
        values.push(...nationIds);
    }

    if (typeIds && typeIds.length > 0) {
        conditions.push(`type_id IN (${typeIds.map(() => "?").join(",")})`);
        values.push(...typeIds);
    }

    if (tierIds && tierIds.length > 0) {
        conditions.push(`tier_id IN (${tierIds.map(() => "?").join(",")})`);
        values.push(...tierIds);
    }

    return { conditions, values };
}
