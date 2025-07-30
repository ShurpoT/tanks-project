USE tank_project_db;

--
--
-- ТАБЛИЦА    ПОЛЬЗОВАТЕЛЕЙ
--
--

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(100) NOT NULL UNIQUE,
    role ENUM("user", "admin") NOT NULL DEFAULT "user",
    --
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    phone_number VARCHAR(100) UNIQUE DEFAULT NULL,
    -- 
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    -- 
    email_changed_at DATETIME,
    password_changed_at DATETIME,
    phone_changed_at DATETIME,
    -- 
    gold_amount INT DEFAULT 0,
    silver_amount INT DEFAULT 0,
    free_xp INT DEFAULT 0,
    bonds INT DEFAULT 0,
    premium_until DATETIME,
    --
    status ENUM(
        "active",
        "banned_temp",
        "banned_perm"
    ) DEFAULT "active",
    ban_reason VARCHAR(100),
    ban_until DATETIME,
    -- 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at DATETIME,
    -- 
    -- (достаточно для кода ISO 639-1 + регион, например en, ru, en-US, zh-CN).
    interface_lang VARCHAR(5),
    -- 
    -- Проверка длины nickname (должно быть не менее 3 символов)
    CHECK (CHAR_LENGTH(nickname) >= 3)
);

--
--
-- ТАБЛИЦА    ТАНКОВ

CREATE TABLE tanks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    unique_code VARCHAR(20) UNIQUE NOT NULL, -- Уникальный текстовый идентификатор (например, R01_MS-1)
    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    nation_id INT NOT NULL,
    type_id INT NOT NULL,
    tier_id INT NOT NULL,
    description TEXT NOT NULL,
    --
    is_premium BOOLEAN DEFAULT FALSE,
    -- стоимость исследования в опыте
    research_cost INT DEFAULT NULL,
    -- стоимость покупки в серебре
    credit_price INT DEFAULT NULL,
    -- стоимость покупки в золоте
    gold_price INT DEFAULT NULL,
    -- стоимость покупки в бонах
    bonds_price INT DEFAULT NULL,
    -- 
    -- 
    -- ссылки на картинки и 3D-модель
    image_2D_url VARCHAR(2048) NOT NULL, -- картинка для КЛИЕНТА
    image_2D_url_small VARCHAR(2048) NOT NULL, -- картинка для дерева в РЕДАКТОРЕ(дерево)
    image_3D_url VARCHAR(2048) NOT NULL, -- 3д картинка для дерева в РЕДАКТОРЕ (выбранный танк)
    icon_url VARCHAR(2048) NOT NULL, -- для КЛИЕНТА
    3d_model_url VARCHAR(2048) NOT NULL, -- 3Д модель для КЛИЕНТА
    -- 
    released_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (nation_id) REFERENCES tank_nations (id),
    FOREIGN KEY (type_id) REFERENCES tank_types (id),
    FOREIGN KEY (tier_id) REFERENCES tank_tiers (id)
);

-- 1. Таблица наций

CREATE TABLE tank_nations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name ENUM(
        "germany",
        "ussr",
        "usa",
        "china",
        "france",
        "uk",
        "japan",
        "czechoslovakia",
        "sweden",
        "poland",
        "italy"
    ) NOT NULL UNIQUE,
    display_name ENUM(
        "Germany",
        "U.S.S.R.",
        "U.S.A.",
        "China",
        "France",
        "U.K.",
        "Japan",
        "Czechoslovakia",
        "Sweden",
        "Poland",
        "Italy"
    ) NOT NULL UNIQUE,
    image_flag_url VARCHAR(2048) NOT NULL, -- картинка для КЛИЕНТА
    image_flag_small_url VARCHAR(2048) NOT NULL, -- картинка для КЛИЕНТА
    image_overlap_url VARCHAR(2048) NOT NULL, -- картинка для КЛИЕНТА
    image_ico_url VARCHAR(2048) NOT NULL -- картинка для КЛИЕНТА
);

-- 2. Таблица типов техники
CREATE TABLE tank_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name ENUM(
        "light",
        "medium",
        "heavy",
        "at-spg",
        "spg"
    ) NOT NULL UNIQUE,
    image_url VARCHAR(2048) NOT NULL, -- картинка для КЛИЕНТА
    image_ico_url VARCHAR(2048) NOT NULL -- картинка для КЛИЕНТА
);

-- 3. Таблица уровней (tank_tiers)
CREATE TABLE tank_tiers (
    id INT PRIMARY KEY CHECK (id BETWEEN 1 AND 10)
);

--
--
-- ТАБЛИЦА    МОДУЛЕЙ
CREATE TABLE modules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    nation_id INT NOT NULL,
    type_id INT NOT NULL,
    tier INT NOT NULL CHECK (tier BETWEEN 1 AND 10),
    research_cost INT DEFAULT 0,
    credit_price INT DEFAULT 0,
    weight INT DEFAULT 0,
    -- image_2D_url VARCHAR(2048) NOT NULL, -- картинка модуля
    FOREIGN KEY (nation_id) REFERENCES tank_nations (id),
    FOREIGN KEY (type_id) REFERENCES module_types (id)
);

CREATE TABLE module_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name ENUM(
        "gun",
        "turret",
        "hull",
        "engine",
        "radio",
        "track"
    ),
    image_url VARCHAR(2048) NOT NULL
);

--
--
-- ОРУДИЕ
CREATE TABLE module_guns (
    module_id INT PRIMARY KEY, -- FK к modules.id
    gun_mechanic ENUM(
        "standard", -- обычное орудие
        "magazine", -- барабан
        "cyclic_autoloader", -- барабан с дозарядкой
        "double_gun" -- двуствольное орудие
    ) NOT NULL,
    -- ОБЩИЕ
    dispersion DECIMAL(4, 2) NOT NULL, -- разброс
    aiming_time DECIMAL(4, 2) NOT NULL, -- сведение
    ammo_capacity INT DEFAULT 0, -- Емкость боезапаса
    -- caliber INT DEFAULT 0, -- калибр орудия
    caliber_id INT NOT NULL,
    -- 
    -- 
    -- Для standard
    reload_time DECIMAL(5, 2) DEFAULT NULL, -- стандартное время перезарядки
    -- 
    -- 
    -- Для magazine
    full_reload_time DECIMAL(5, 2) DEFAULT NULL, -- полная перезарядка барабана
    -- 
    -- 
    -- Для cyclic_autoloader
    autoreload_times JSON DEFAULT NULL, -- массив дозарядки [16.0, 14.0, ...]
    -- 
    -- 
    -- Общие для magazine / cyclic_autoloader
    magazine_size INT DEFAULT NULL, -- кол-во снарядов в магазине
    time_between_shots DECIMAL(5, 2) DEFAULT NULL, -- время между выстрелами в магазине
    -- 
    -- 
    -- Для double_gun
    dual_reload_times JSON DEFAULT NULL, -- массив зарядки [11.2, 11.2]
    salvo_reload DECIMAL(5, 2) DEFAULT NULL, -- подготовка залпа
    -- 
    -- 
    FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE,
    FOREIGN KEY (caliber_id) REFERENCES calibers (id)
);

--
--
-- СНАРЯДЫ
CREATE TABLE shells (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type_id INT NOT NULL,
    damage INT NOT NULL,
    penetration INT DEFAULT 0,
    velocity INT DEFAULT NULL, -- скорость полета снаряда (м/с)
    caliber_id INT NOT NULL,
    FOREIGN KEY (type_id) REFERENCES shell_types (id),
    FOREIGN KEY (caliber_id) REFERENCES calibers (id)
);

CREATE TABLE shell_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name ENUM(
        "ap", -- Бронебойные
        "apcr", -- Подкалиберные
        "he", -- Кумулятивные
        "heat", -- Фугасные
        "hesh" -- Хеш-Фугасные
    ) NOT NULL,
    image_url VARCHAR(2048) NOT NULL
);

CREATE TABLE calibers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    caliber INT NOT NULL UNIQUE -- Например, 105
);

--
--
-- ТАБЛИЦА gun_shells (привязка снарядов к пушке + порядок)
CREATE TABLE gun_shells (
    gun_id INT, -- module_id из module_guns
    shell_id INT, -- из shells
    PRIMARY KEY (gun_id, shell_id),
    FOREIGN KEY (gun_id) REFERENCES module_guns (module_id),
    FOREIGN KEY (shell_id) REFERENCES shells (id)
);

--
--
-- БАШНЯ
CREATE TABLE module_turrets (
    module_id INT PRIMARY KEY,
    hit_points INT DEFAULT 1, -- hit points
    armor_front INT,
    armor_sides INT,
    armor_rear INT,
    traverse_speed DECIMAL(4, 2) DEFAULT 1, -- degrees/s
    view_range INT DEFAULT 1, -- meters
    FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
);
--
--
-- КОРПУС
CREATE TABLE module_hulls (
    module_id INT PRIMARY KEY,
    armor_front INT,
    armor_sides INT,
    armor_rear INT,
    FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
);

--
--
-- ДВИГАТЕЛЬ
CREATE TABLE module_engines (
    module_id INT PRIMARY KEY,
    power INT, -- hp
    max_top_speed DECIMAL(5, 2) DEFAULT 1, -- km/h
    max_traverse_speed DECIMAL(5, 2) DEFAULT 1, -- km/h
    fire_chance_percent DECIMAL(4, 2) DEFAULT 1, -- %
    FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
);

--
--
-- ХОДОВАЯ / ГУСЕНИЦЫ
CREATE TABLE module_tracks (
    module_id INT PRIMARY KEY,
    load_limit DECIMAL(5, 2), -- tons
    traverse_speed DECIMAL(4, 2) DEFAULT 1, -- deg/s
    repair_time DECIMAL(5, 2) DEFAULT 1, -- seconds
    FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
);

--
--
-- РАЦИЯ
CREATE TABLE module_radios (
    module_id INT PRIMARY KEY,
    signal_range INT DEFAULT 0,
    FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
);

--
--
-- ТАБЛИЦА tank_modules(таблица связи «танк ↔ модули»)
-- Эта таблица говорит: у этого танка есть вот такой модуль, он в слоте «пушка» / «башня» и т.д.
-- is_default = TRUE — значит установлен по умолчанию (новый танк).
CREATE TABLE tank_modules (
    tank_id INT NOT NULL,
    module_id INT NOT NULL,
    module_slot ENUM(
        "gun",
        "turret",
        "hull",
        "engine",
        "track",
        "radio"
    ) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (tank_id, module_id),
    FOREIGN KEY (tank_id) REFERENCES tanks (id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
);

--
-- ТАБЛИЦА module_unlocks(таблица, которая описывает, какие модули открывают другие)
-- Это граф модулей. Например, Пушка 1 открывает Пушку 2 и т.д.
-- Один модуль может вести к нескольким.
CREATE TABLE module_unlocks (
    from_module_id INT NOT NULL,
    to_module_id INT NOT NULL,
    -- research_cost INT NOT NULL, -- зачем? это есть в таблице modules
    PRIMARY KEY (from_module_id, to_module_id),
    FOREIGN KEY (from_module_id) REFERENCES modules (id) ON DELETE CASCADE,
    FOREIGN KEY (to_module_id) REFERENCES modules (id) ON DELETE CASCADE
);

--
-- ТАБЛИЦА module_unlocks_tank(отдельная таблица, если модуль открывает танк)
-- Здесь модули (например, последняя пушка или гусеница) открывают следующий танк.
CREATE TABLE module_unlocks_tank (
    from_module_id INT NOT NULL,
    to_tank_id INT NOT NULL,
    -- research_cost INT NOT NULL, -- зачем? это есть в таблице tanks
    PRIMARY KEY (from_module_id, to_tank_id),
    FOREIGN KEY (from_module_id) REFERENCES modules (id) ON DELETE CASCADE,
    FOREIGN KEY (to_tank_id) REFERENCES tanks (id) ON DELETE CASCADE
);

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
-- ОБОРУДОВАНИЕ
CREATE TABLE equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type_id INT NOT NULL,
    tier INT NOT NULL CHECK (tier BETWEEN 1 AND 3),
    price_gold INT DEFAULT 0,
    price_credits INT DEFAULT 0,
    price_bonds INT DEFAULT 0,
    bonus_json JSON NOT NULL, -- { "reload": -0.1, "view_range": +20 } и т.п.
    UNIQUE (name),
    FOREIGN KEY (type_id) REFERENCES equipment_types (id)
);

CREATE TABLE equipment_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipment_type ENUM(
        "firepower",
        "survivability",
        "mobility",
        "concealment",
        "spotting",
        "misc"
    ) NOT NULL,
);

--
-- СКЛАД ОБОРУДОВАНИЯ ИГРОКА
-- Хранит, сколько и какого оборудования у игрока на складе
CREATE TABLE equipment_inventory (
    user_id INT NOT NULL,
    equipment_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (user_id, equipment_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES equipment (id) ON DELETE CASCADE
);

--
--
-- Слоты оборудования на танке пользователя
-- user_tanks отражает факт, что конкретный пользователь владеет конкретным танком, и в этом контексте устанавливается оборудование.
-- Если ты используешь связку (user_id, tank_id) в user_tanks как PK, то это естественный FK для user_tank_equipment.
CREATE TABLE user_tank_equipment (
    user_id INT NOT NULL,
    tank_id INT NOT NULL,
    slot_index INT NOT NULL CHECK (slot_index BETWEEN 1 AND 3),
    equipment_id INT NOT NULL,
    PRIMARY KEY (user_id, tank_id, slot_index),
    FOREIGN KEY (user_id, tank_id) REFERENCES user_tanks (user_id, tank_id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_id) REFERENCES equipment (id) ON DELETE CASCADE
);
--

--
-- ЭКИПАЖ
CREATE TABLE crew_member (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    appearance JSON DEFAULT NULL,
    nation_id INT NOT NULL,
    tank_type_id INT NOT NULL,
    specialization_id INT NOT NULL,
    FOREIGN KEY (nation_id) REFERENCES tank_nations (id),
    FOREIGN KEY (tank_type_id) REFERENCES tank_types (id),
    FOREIGN KEY (specialization_id) REFERENCES crew_specializations (id)
);

-- 5. Таблица специализаций (по желанию, если нужна нормализация)
CREATE TABLE crew_specializations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name ENUM(
        "commander",
        "gunner",
        "driver",
        "radio_operator",
        "loader"
    ) NOT NULL UNIQUE
);

--
-- Экземпляры экипажа у игроков
CREATE TABLE user_crew (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    crew_member_id INT NOT NULL,
    level INT NOT NULL DEFAULT 1 CHECK (level BETWEEN 1 AND 100),
    experience INT NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (crew_member_id) REFERENCES crew_member (id) ON DELETE CASCADE
);

--
-- Требуемые слоты экипажа для танков
CREATE TABLE tank_crew_slots (
    tank_id INT NOT NULL,
    slot_index TINYINT NOT NULL CHECK (slot_index BETWEEN 1 AND 10),
    specialization_id INT NOT NULL,
    PRIMARY KEY (tank_id, slot_index),
    FOREIGN KEY (tank_id) REFERENCES tanks (id) ON DELETE CASCADE,
    FOREIGN KEY (specialization_id) REFERENCES crew_specializations (id)
);

--
-- Назначение экипажа: где находится
CREATE TABLE crew_assignment (
    user_crew_id INT PRIMARY KEY,
    tank_id INT DEFAULT NULL,
    status ENUM(
        "in_tank",
        "in_barracks",
        "dismissed"
    ) NOT NULL DEFAULT "in_barracks",
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_crew_id) REFERENCES user_crew (id) ON DELETE CASCADE,
    FOREIGN KEY (tank_id) REFERENCES user_tanks (id) ON DELETE SET NULL
);

--
-- Справочник навыков/перков
CREATE TABLE skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    unlock_at INT NOT NULL CHECK (unlock_at BETWEEN 1 AND 100), -- уровень прокачки для активации
    allowed_roles JSON NOT NULL -- массив специальностей, которым доступен перк
);

--
-- Перки у конкретного экипажа (экземпляра)
CREATE TABLE crew_skills (
    user_crew_id INT NOT NULL,
    skill_id INT NOT NULL,
    progress INT NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    active BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (user_crew_id, skill_id),
    FOREIGN KEY (user_crew_id) REFERENCES user_crew (id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills (id) ON DELETE CASCADE
);

--
--
-- 3. НАЛИЧИЕ ТАНКОВ У ПОЛЬЗОВАТЕЛЕЙ
--
CREATE TABLE user_tanks (
    user_id INT NOT NULL,
    tank_id INT NOT NULL,
    acquired_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, tank_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (tank_id) REFERENCES tanks (id) ON DELETE CASCADE
);

-- Связи модулей, оборудования и экипажа для конкретного танка пользователя:
-- user_tank_modules, user_tank_equipment, crew_assignment

--
-- 4. СТАТИСТИКА НА ТАНКАХ ИГРОКА
CREATE TABLE user_tank_stats (
    user_id INT NOT NULL,
    tank_id INT NOT NULL,
    mode ENUM(
        "random",
        "ranked",
        "assault",
        "global_map"
    ) NOT NULL,
    battles INT NOT NULL DEFAULT 0, -- кол-во боев
    wins INT NOT NULL DEFAULT 0, -- кол-во побед
    losses INT NOT NULL DEFAULT 0, -- кол-во поражений
    draws INT NOT NULL DEFAULT 0, -- ничья
    survivals INT NOT NULL DEFAULT 0, -- кол-во боев в который игрок выжил
    shots INT NOT NULL DEFAULT 0, -- кол-во выстрелов
    hits INT NOT NULL DEFAULT 0, -- кол-во попаданий
    spotted INT NOT NULL DEFAULT 0, -- кол-во обноружений техники противника
    total_damage INT NOT NULL DEFAULT 0, -- кол-во нанесенного урона игроком 
    max_damage INT NOT NULL DEFAULT 0, -- максимальный урон за бой
    total_assist INT NOT NULL DEFAULT 0, -- кол-во ассиста всего  
    max_assist INT NOT NULL DEFAULT 0, -- максимальный ассист за бой
    total_blocked INT NOT NULL DEFAULT 0, -- кол-во заблокированного урона
    max_blocked INT NOT NULL DEFAULT 0, -- максимальное кол-во заблокированного урона за бой
    kills INT NOT NULL DEFAULT 0, -- кол-во фрагов 
    max_kills INT NOT NULL DEFAULT 0, -- максимальное кол-во фрагов  за бой
    total_xp INT NOT NULL DEFAULT 0, -- кол-во опыта
    max_xp INT NOT NULL DEFAULT 0, -- максимальное кол-во опыта за бой 
    efficiency_rating DECIMAL(8, 2) DEFAULT NULL, -- РЕЙТИНГ ПОЛЬЗОВАТЕЛЯ
    PRIMARY KEY (user_id, tank_id, mode),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (tank_id) REFERENCES tanks (id) ON DELETE CASCADE
);

--
-- Общая статистика игрока (кэш)
-- Общую статистику можно кэшировать и обновлять при изменении user_tank_stats.
CREATE TABLE user_stats (
    user_id INT PRIMARY KEY,
    total_battles INT NOT NULL DEFAULT 0,
    total_wins INT NOT NULL DEFAULT 0,
    total_losses INT NOT NULL DEFAULT 0,
    total_draws INT NOT NULL DEFAULT 0,
    total_damage INT NOT NULL DEFAULT 0,
    total_xp INT NOT NULL DEFAULT 0,
    overall_rating DECIMAL(8, 2) DEFAULT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

--
-- Таблица справочник медалей
CREATE TABLE medals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(2048)
);

--
-- Связь медалей с танками пользователя
CREATE TABLE user_tank_medals (
    user_id INT NOT NULL,
    tank_id INT NOT NULL,
    medal_id INT NOT NULL,
    awarded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    count INT NOT NULL DEFAULT 1,
    PRIMARY KEY (user_id, tank_id, medal_id),
    FOREIGN KEY (user_id, tank_id) REFERENCES user_tanks (user_id, tank_id) ON DELETE CASCADE,
    FOREIGN KEY (medal_id) REFERENCES medals (id) ON DELETE CASCADE
);

--
-- Общие медали пользователя (по всем танкам)
-- Можно обновлять user_medals через триггер или в приложении после изменения user_tank_medals.
CREATE TABLE user_medals (
    user_id INT NOT NULL,
    medal_id INT NOT NULL,
    total_count INT NOT NULL DEFAULT 0,
    last_awarded_at DATETIME DEFAULT NULL,
    PRIMARY KEY (user_id, medal_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (medal_id) REFERENCES medals (id) ON DELETE CASCADE
);
--
-- 5. КЛАНЫ
-- Основная информация о клане
CREATE TABLE clans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tag VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    rating INT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    stronghold_level INT NOT NULL DEFAULT 0,
    stronghold_elo_6 INT NOT NULL DEFAULT 0,
    stronghold_elo_8 INT NOT NULL DEFAULT 0,
    stronghold_elo_10 INT NOT NULL DEFAULT 0
);

-- Члены клана и их текущие звания
CREATE TABLE clan_members (
    user_id INT NOT NULL,
    clan_id INT NOT NULL,
    rank ENUM(
        'commander',
        'vice_commander',
        'staff_officer',
        'unit_commander',
        'intel_officer',
        'supply_officer',
        'personnel_officer',
        'junior_officer',
        'soldier',
        'recruit',
        'reservist'
    ) NOT NULL,
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, clan_id),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (clan_id) REFERENCES clans (id) ON DELETE CASCADE
);

-- История входов/выходов из клана
CREATE TABLE clan_members_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    clan_id INT NOT NULL,
    action ENUM('joined', 'left', 'kicked') NOT NULL,
    initiator_id INT DEFAULT NULL,
    action_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (clan_id) REFERENCES clans (id) ON DELETE CASCADE,
    FOREIGN KEY (initiator_id) REFERENCES users (id) ON DELETE SET NULL
);

-- История изменений званий в клане
CREATE TABLE clan_ranks_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    clan_id INT NOT NULL,
    old_rank VARCHAR(50) NOT NULL,
    new_rank VARCHAR(50) NOT NULL,
    initiator_id INT DEFAULT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (clan_id) REFERENCES clans (id) ON DELETE CASCADE,
    FOREIGN KEY (initiator_id) REFERENCES users (id) ON DELETE SET NULL
);

-- Казна клана
CREATE TABLE clan_treasury (
    clan_id INT PRIMARY KEY,
    gold_amount INT NOT NULL DEFAULT 0,
    bonds_amount INT NOT NULL DEFAULT 0,
    FOREIGN KEY (clan_id) REFERENCES clans (id) ON DELETE CASCADE
);