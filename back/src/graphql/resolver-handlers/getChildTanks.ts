import { getTankData } from "../utils";

import type { IContext } from "~context";
import type { TankRow, UnlockRow, TankModuleRow } from "~types";
import type { Tank } from "~types/__generated__";

export const getChildTanks = async (parent: Tank, _: {}, ctx: IContext): Promise<Tank[] | null> => {
    const tankId: number = parent.id;

    const [tanks] = await ctx.pool.query<TankRow[]>(`
        SELECT 
            t.*,
            t.id AS id,
            n.id AS nation_id,
            tp.id AS type_id,
            tr.id AS tier_id
        FROM tanks t
        JOIN tank_nations n ON t.nation_id = n.id
        JOIN tank_types tp ON t.type_id = tp.id
        LEFT JOIN tank_tiers tr ON t.tier_id = tr.id
    `);

    const [unlocks] = await ctx.pool.query<UnlockRow[]>(`
        SELECT from_module_id, to_tank_id
        FROM module_unlocks_tank
    `);

    const [tankModules] = await ctx.pool.query<TankModuleRow[]>(`
        SELECT tank_id, module_id
        FROM tank_modules
    `);

    const moduleToUnlocksMap: Record<number, number[]> = {};
    for (const row of unlocks) {
        moduleToUnlocksMap[row.from_module_id] ??= [];
        moduleToUnlocksMap[row.from_module_id].push(row.to_tank_id);
    }

    const tankToUnlockedTanksMap: Record<number, number[]> = {};
    for (const { tank_id, module_id } of tankModules) {
        const unlocked = moduleToUnlocksMap[module_id];
        if (unlocked?.length) {
            tankToUnlockedTanksMap[tank_id] ??= [];
            tankToUnlockedTanksMap[tank_id].push(...unlocked);
        }
    }

    const tankMap: Record<number, TankRow> = {};
    tanks.forEach((t: TankRow) => {
        tankMap[t.id] = t;
    });

    const childIds: number[] = tankToUnlockedTanksMap[tankId] || [];
    const children = childIds
        .map((id: number) => {
            const t = tankMap[id];

            if (!t) return {} as Tank;

            return getTankData(t);
        })
        .filter(Boolean);

    return children.length ? children : null;
};
