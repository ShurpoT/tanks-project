import type { TankRow } from "~types";

export const getTankData = (tank: TankRow) => ({
    id: tank.id,
    uniqueCode: tank.unique_code,
    name: tank.name,
    displayName: tank.display_name,
    nationId: tank.nation_id,
    typeId: tank.type_id,
    tier: tank.tier_id,
    description: tank.description,
    isPremium: tank.is_premium,
    researchCost: tank.research_cost,
    creditPrice: tank.credit_price,
    goldPrice: tank.gold_price,
    bondsPrice: tank.bonds_price,
    image2DUrl: tank.image_2D_url,
    image2DUrlSmall: tank.image_2D_url_small,
    image3DUrl: tank.image_3D_url,
    iconUrl: tank.icon_url,
    model3DUrl: tank["3d_model_url"],
    releasedAt: tank.released_at,
    updatedAt: tank.updated_at,
});
