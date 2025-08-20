import type { IContext } from "~context";
import type { TankNationRow } from "~types";
import type { TankNation } from "~types/__generated__";
import { getTankNationData } from "../utils";

export const getNations = async (_parent: unknown, args: unknown, ctx: IContext): Promise<TankNation[]> => {
    const query = `
                SELECT 
                    *
                FROM tank_nations 
    `;

    const [nations] = await ctx.pool.query<TankNationRow[]>(query);

    return nations.map((nation: TankNationRow) => getTankNationData(nation));
};
