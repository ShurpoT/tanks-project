export const typeDefs = `#graphql

    scalar DateTime 

    enum Nation {
        germany
        ussr
        usa
        china
        france
        uk
        japan
        czechoslovakia
        sweden
        poland
        italy
    }

    enum TypeName {
        light
        medium
        heavy
        at_spg
        spg
    }

    type TankNation {
        id:                 ID!
        name:               Nation!
        displayName:        String!
        
        imageFlagUrl:       String!
        imageFlagSmallUrl:  String!
        imageOverlapUrl:    String!
        imageIcoUrl:        String!
    }

    type TankType {
        id:                 ID!
        name:               TypeName!
        imageUrl:           String!
        imageIcoUrl:        String!
    }


    type Tank {
        id:                 ID!
        uniqueCode:         String!
        name:               String!
        displayName:        String!

        nationId:           ID!
        typeId:             ID!

        nation:             TankNation
        type:               TankType
        tier:               Int!

        description:        String!

        isPremium:          Boolean!
        researchCost:       Int 
        creditPrice:        Int 
        goldPrice:          Int
        bondsPrice:         Int
        
        image2DUrl:         String!
        image2DUrlSmall:    String!
        image3DUrl:         String!
        iconUrl:            String!
        model3DUrl:         String!
       
        releasedAt:         DateTime!
        updatedAt:          DateTime!

        ###
        ###
        ###

        childTanks:      [Tank]
        childModules:    [Module]
    }




    ### _______________       MODULE       ________________________


    enum ModuleTypeName {
        gun
        turret
        hull
        engine
        radio
        track
    }

    type ModuleType {
        id:                 ID!
        type:               ModuleTypeName!
        imageUrl:           String!
    }

    union ModuleDetails = Gun | Turret | Hull | Engine | Tracks | Radio


    type Module {
        id:                 ID!
        name:               String!
        nation:             Nation!
        type:               ModuleType!
        tier:               Int!
        researchCost:       Int!
        creditPrice:        Int!
        weight:             Int!

        details:            ModuleDetails!

        ###
        ###
        ###
        
        childModules:    [Module!]!
        unlocksTanks:       [Tank!]!


    }

    ### _______________       GUN       ___________________________
    

    enum GunMechanic {
        STANDARD
        MAGAZINE
        CYCLIC_AUTOLOADER
        DOUBLE_GUN
    }

    type Gun {
        gunMechanic:        GunMechanic!
        dispersion:         Float!
        aimingTime:         Float!
        ammoCapacity:       Int!
        caliber:            Int!

        reloadTime:         Float

        fullReloadTime:     Float

        autoreloadTimes:    [Float]

        magazineSize:       Int
        timeBetweenShots:   Float

        dualReloadTimes:    [Float]
        salvoReload:        Float


        shells: [Shell!]!
    }

    enum ShellTypeName {
        AP
        APCR
        HE
        HEAT
        HESH
    }

    type ShellType {
        id:                 ID!
        name:               ShellTypeName!
        imageUrl:           String!
    }

    type Shell {
        id:                 ID!
        name:               String!
        type:               ShellType!
        caliber:            Int!
        damage:             Int!
        penetration:        Int!
        velocity:           Int!
    }

    ### _______________       TURRET       _________________________

    type Turret {
        hitPoints:          Int!
        armorFront:         Int!
        armorSides:         Int!
        armorRear:          Int!
        traverseSpeed:      Float!
        viewRange:          Int!
    }

    ### _______________       HULL       ___________________________

    type Hull {
        armorFront:         Int!
        armorSides:         Int!
        armorRear:          Int!
    }

    ### _______________       ENGINE       __________________________

    type Engine {
        power:              Int!
        maxTopSpeed:        Float!
        maxTraverseSpeed:   Float!
        fireChancePercent:  Float!
    }

    ### _______________       TRACKS       __________________________

    type Tracks {
        loadLimit:          Float!
        traverseSpeed:      Float!
        repairTime:         Float!
    }

    ### _______________       RADIO       ___________________________

    type Radio {
        signalRange:        Int!
    }



    

    input TankIdentifierByNation {
            nationId:           ID!
            tierId:             Int!
    }
    
    input TankIdentifierInput {
        id:                 ID
        uniqueCode:         String
        name:               String
        nation:             TankIdentifierByNation
    }

    type Query {
        tanksList(nationIds: [ID!], typeIds: [ID!], tierIds: [Int!]): [Tank!]!
        tanksTree(nationId: ID!): [Tank]
        tank(identifier: TankIdentifierInput!): Tank

        modules: [Module!]!
        module(id: ID!): Module

        nations: [TankNation]!
    }

`;
