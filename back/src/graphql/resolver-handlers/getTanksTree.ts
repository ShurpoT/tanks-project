import { getTankData } from "../utils";

import type { IContext } from "~context";
import type { TankRow, UnlockRow, TankModuleRow } from "~types";
import type { QueryTanksTreeArgs, Tank } from "~types/__generated__";

export const getTanksTree = async (_parent: unknown, args: QueryTanksTreeArgs, ctx: IContext): Promise<Tank[]> => {
    const { nationId } = args;

    const [tanks] = await ctx.pool.query<TankRow[]>(
        `
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
            JOIN tank_nations n ON t.nation_id = n.id
            JOIN tank_types tp ON t.type_id = tp.id
            LEFT JOIN tank_tiers tr ON t.tier_id = tr.id

            WHERE n.id = ?
        `,
        [nationId]
    );

    const [unlocks] = await ctx.pool.query<UnlockRow[]>(`
            SELECT 
                from_module_id,
                to_tank_id
            FROM module_unlocks_tank
        `);

    const [tankModules] = await ctx.pool.query<TankModuleRow[]>(`
            SELECT 
                tank_id, 
                module_id
            FROM tank_modules
        `);

    const moduleToUnlocksMap: Record<number, number[]> = {};
    for (const row of unlocks) {
        if (!moduleToUnlocksMap[row.from_module_id]) {
            moduleToUnlocksMap[row.from_module_id] = [];
        }
        moduleToUnlocksMap[row.from_module_id].push(row.to_tank_id);
    }

    const tankToUnlockedTanksMap: Record<number, number[]> = {};
    for (const { tank_id, module_id } of tankModules) {
        const unlockedTanks = moduleToUnlocksMap[module_id];
        if (unlockedTanks?.length) {
            if (!tankToUnlockedTanksMap[tank_id]) {
                tankToUnlockedTanksMap[tank_id] = [];
            }
            tankToUnlockedTanksMap[tank_id].push(...unlockedTanks);
        }
    }

    const tankMap: Record<number, TankRow> = {};
    tanks.forEach((t) => {
        tankMap[t.id] = t;
    });

    const unlockedTankIds: Set<number> = new Set<number>(unlocks.map((u) => u.to_tank_id));
    const rootTanks: TankRow[] = tanks.filter((t) => !unlockedTankIds.has(t.id));

    const resultTree = rootTanks.map((rootTank) => buildTreeNode(rootTank, tankMap, tankToUnlockedTanksMap));

    return resultTree;
};

function buildTreeNode(tank: TankRow, tankMap: Record<number, TankRow>, unlockMap: Record<number, number[]>) {
    const unlockedTanks = unlockMap[tank.id] || [];

    const children = unlockedTanks
        .map((toTankId: number) => {
            const childTank = tankMap[toTankId];
            return childTank ? buildTreeNode(childTank, tankMap, unlockMap) : null;
        })
        .filter(Boolean);

    const node: Tank = getTankData(tank);

    if (children.length) {
        node.childTanks = children;
    }

    return node;
}
