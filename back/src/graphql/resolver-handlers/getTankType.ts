import type { IContext } from "~context";
import { TankTypeRow } from "~types";
import type { Tank, TankType } from "~types/__generated__";

export const getTankType = async (parent: Tank, _: {}, ctx: IContext): Promise<TankType> => {
    const { typeId } = parent;

    const [type] = await ctx.pool.query<TankTypeRow[]>(
        `
            SELECT 
                tt.*
            FROM tank_types tt
            WHERE tt.id = ?
        `,
        [typeId]
    );

    return {
        id: type[0].id,
        name: type[0].name,
        imageUrl: type[0].image_url,
        imageIcoUrl: type[0].image_ico_url,
    };
};
