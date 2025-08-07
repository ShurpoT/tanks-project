import type { Tank, TankNation, TankType } from "~types/__generated__";
import type { RowDataPacket } from "mysql2";

export type TankRow = RowDataPacket & Tank;
export type TankNationRow = RowDataPacket & TankNation;
export type TankTypeRow = RowDataPacket & TankType;

export interface UnlockRow extends RowDataPacket {
    from_module_id: number;
    to_tank_id: number;
}

export interface TankModuleRow extends RowDataPacket {
    tank_id: number;
    module_id: number;
}
