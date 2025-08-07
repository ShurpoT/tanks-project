import type { IContext } from "~context";
import type { TankNationRow } from "~types";
import type { Tank, TankNation } from "~types/__generated__";

export const getTankNation = async (parent: Tank, _: {}, ctx: IContext): Promise<TankNation> => {
    const { nationId } = parent;

    const [nation] = await ctx.pool.query<TankNationRow[]>(
        `
            SELECT 
                n.*
            FROM tank_nations n
            WHERE n.id = ?
        `,
        [nationId]
    );

    return {
        id: nation[0].id,
        name: nation[0].name,
        displayName: nation[0].display_name,
        imageFlagUrl: nation[0].image_flag_url,
        imageFlagSmallUrl: nation[0].image_flag_small_url,
        imageOverlapUrl: nation[0].image_overlap_url,
        imageIcoUrl: nation[0].image_ico_url,
    };
};
