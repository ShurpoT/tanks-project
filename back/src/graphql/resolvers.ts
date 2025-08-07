import { DateTimeResolver } from "graphql-scalars";

import type { IContext } from "~context";
import type { Resolvers } from "~types/__generated__";

import { getTanksList, getTanksTree, getTankNation, getTankType, getChildTanks, getTank } from "./resolver-handlers";

export const resolvers: Resolvers<IContext> = {
    DateTime: DateTimeResolver,

    Query: {
        /**
         * Возвращает список танков.
         *
         * @returns Список танков
         */
        tanksList: getTanksList,

        /**
         * Возвращает дерево танков.
         * @deprecated Используется `childTanks` вместо этого.
         *
         * @param {ID} nationId  id конкретной нации.
         *
         * @returns Дерево танков
         */
        tanksTree: getTanksTree,

        /**
         * Возвращает танк по ID.
         *
         * @param {TankIdentifierInput} args - Объект с полем `identifier`, содержащим один из вариантов: id, unique_code, name или объект { nation_id, tier_id }.
         * @returns {Tank | null} Данные танка или null
         */
        tank: getTank,

        /**
         * Возвращает все модули.
         */
        // modules: async (parent, args, context) => {},

        /**
         * Получить модуль по ID.
         *
         * @param args - Объект с полем `id` - идентификатор модуля
         *
         * @returns Данные модуля
         *
         */
        // module: async (parent, args, context) => {
        // },
    },

    Tank: {
        /**
         * Возвращает информацию о нации танка.
         *
         * @returns Нация
         */
        nation: getTankNation,

        /**
         * Возвращает информацию о типе танка.
         *
         * @returns {TankType} Тип танка
         */
        type: getTankType,

        /**
         * Возвращает все танки следующего уровня для конкретного танка.
         *
         * Структура — в виде дерева.
         *
         * @returns {Tank[] | null} Массив танков или null
         */
        childTanks: getChildTanks,

        /**
         * Возвращает все модули конкретного танка.
         *
         * Структура — в виде дерева.
         *
         * @returns Массив модулей
         */
        // childModules: async (tank, args, context) => {
        //     return [];
        // },
    },

    Module: {
        // type: async (module, args, context) => {
        //     // возвращает ModuleType
        // },
        // details: async (module, args, context) => {
        //     // возвращает объект типа Gun или Turret или Hull или и т.д.
        // },
        // childModules: async (module, args, context) => {
        //     // возвращает [Module]
        // },
        // нужно, чтобы знать следущие танки в дереве модулей конкретного танка
        // unlocksTanks: async (module, args, context) => {
        //     // возвращает [Tank]
        // },
    },
};
