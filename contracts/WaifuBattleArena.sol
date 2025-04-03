// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract WaifuBattleArena {
    address public owner;

    // Multiplier constants for role and personality combinations
    uint256[5][5] public rolePersonalityMultipliers = [
        [120, 105, 110, 100, 115], // Attacker: Aggressive, Calm, Cunning, Loyal, Chaotic
        [100, 125, 105, 110, 100], // Defender
        [105, 100, 130, 105, 110], // Support
        [100, 110, 105, 135, 100], // Healer
        [115, 105, 110, 100, 140]  // Tactician
    ];

    // Multiplier constants for item types across tiers
    uint256[5][4] public itemTypeTierMultipliers = [
        [110, 120, 130, 140, 150], // Weapon: Tier 1-5
        [105, 115, 125, 135, 145], // Armor
        [100, 110, 120, 130, 140], // Utility
        [115, 125, 135, 145, 155]  // Consumable
    ];

    // Multiplier constants for quest completion based on roles
    uint256[5][5] public questRoleMultipliers = [
        [130, 100, 105, 110, 115], // Attacker: Quest 0-4
        [100, 135, 105, 110, 115], // Defender
        [105, 100, 140, 110, 115], // Support
        [110, 105, 100, 145, 115], // Healer
        [115, 110, 105, 100, 150]  // Tactician
    ];

    // Synergy multipliers for personality and role combinations
    uint256[5][5] public personalityRoleSynergy = [
        [150, 110, 105, 100, 115], // Aggressive: Attacker, Defender, Support, Healer, Tactician
        [100, 145, 110, 105, 100], // Calm
        [105, 100, 140, 110, 115], // Cunning
        [110, 105, 100, 155, 100], // Loyal
        [115, 110, 105, 100, 160]  // Chaotic
    ];

    // Expanded struct for waifu attributes and stats
    struct Waifu {
        uint256 id;
        address owner;
        uint8 role;
        uint8 tier;
        uint8 personality;
        uint256 attack;
        uint256 defense;
        uint256 speed;
        uint256 hp;
        uint256 stamina;
        uint256 exp;
        uint256[3] skills;
        uint256[3] traits;
        uint256[3] cooldowns;
        uint256[3] modifiers;
        uint256[5] questProgress;
        uint256[] items;
        bool isFused;
        uint256 lastBattleTimestamp;
        uint256 trainingCount;
        uint256[5] roleSynergyBonus;
        uint256 personalityBoost;
        uint256[5] battleHistory; // Tracks scores from the last 5 battles
        uint256[4] itemTypeBoosts; // Boosts specific to each item type
        uint256 lastRestTimestamp; // Timestamp of the last rest
    }

    // Struct for waifu skills
    struct Skill {
        uint256 level;
        uint256 power;
        uint256 baseCooldown;
        uint8 modifierType;
    }

    // Struct for waifu traits
    struct Trait {
        uint256 level;
        uint256 effect;
    }

    // Struct for items
    struct Item {
        uint256 id;
        uint8 itemType;
        uint8 tier;
        uint8 enchantment;
        uint256 value;
        uint8 rarity;
    }

    // Struct for battle data
    struct Battle {
        uint256[] waifuIds;
        uint8 mode;
        uint8 formation;
        uint256[5][] phaseScores;
        uint8[5] phaseTypes;
        uint256 winnerId;
        uint256 battleStartTime;
    }

    // Struct for guild data
    struct Guild {
        uint256 id;
        address leader;
        address[] officers;
        address[] members;
        uint256 attackPool;
        uint256 defensePool;
        uint256 speedPool;
        uint8 rank;
        uint256 missionProgress;
        uint256 eventProgress;
        uint256 tournamentScore;
        uint256[] alliances;
        mapping(uint256 => uint8) diplomacy;
        uint256 lastEventTimestamp;
    }

    // Struct for Super Saiyan mode
    struct SuperSaiyan {
        bool isActive;
        uint8 mode;
        uint256 powerBoost;
        uint256 duration;
        uint256 cooldown;
    }

    // Struct for Mecha Boss data
    struct MechaBoss {
        uint256 guildId;
        uint256 attack;
        uint256 defense;
        uint256 speed;
        uint256 hp;
        uint256 summonCost;
        uint256 lastBattle;
        bool isActive;
    }

    // Struct for marketplace listings
    struct Listing {
        uint256 id;
        uint8 listingType;
        uint256 assetId;
        uint256 price;
        address seller;
        address highestBidder;
        uint256 highestBid;
        uint256 deadline;
    }

    // Mappings for storing game data
    mapping(uint256 => Waifu) public waifus;
    mapping(uint256 => mapping(uint8 => Skill)) public waifuSkills;
    mapping(uint256 => mapping(uint8 => Trait)) public waifuTraits;
    mapping(uint256 => Item) public items;
    mapping(uint256 => Battle) public battles;
    mapping(uint256 => Guild) public guilds;
    mapping(uint256 => SuperSaiyan) public waifuSuperSaiyans;
    mapping(uint256 => MechaBoss) public guildMechaBosses;
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256) public rewards;
    uint256 public waifuCount;
    uint256 public itemCount;
    uint256 public battleCount;
    uint256 public guildCount;
    uint256 public mechaBossCount;
    uint256 public listingCount;

    // Events for tracking game state changes
    event WaifuCreated(uint256 indexed id, address owner, uint8 role, uint8 tier, uint8 personality, uint256 timestamp);
    event WaifuTrainedAttack(uint256 indexed id, uint256 expBefore, uint256 expAfter, uint256 attackBefore, uint256 attackAfter, uint256 trainingCount, uint256 timestamp);
    event WaifuTrainedDefense(uint256 indexed id, uint256 expBefore, uint256 expAfter, uint256 defenseBefore, uint256 defenseAfter, uint256 trainingCount, uint256 timestamp);
    event WaifuTrainedSpeed(uint256 indexed id, uint256 expBefore, uint256 expAfter, uint256 speedBefore, uint256 speedAfter, uint256 trainingCount, uint256 timestamp);
    event WaifuTrainedHp(uint256 indexed id, uint256 expBefore, uint256 expAfter, uint256 hpBefore, uint256 hpAfter, uint256 trainingCount, uint256 timestamp);
    event WaifuTrainedStamina(uint256 indexed id, uint256 expBefore, uint256 expAfter, uint256 staminaBefore, uint256 staminaAfter, uint256 trainingCount, uint256 timestamp);
    event WaifuSkillUpgraded(uint256 indexed id, uint8 skillIndex, uint256 levelBefore, uint256 levelAfter, uint256 powerBefore, uint256 powerAfter, uint256 timestamp);
    event WaifuTraitUpgraded(uint256 indexed id, uint8 traitIndex, uint256 levelBefore, uint256 levelAfter, uint256 effectBefore, uint256 effectAfter, uint256 timestamp);
    event WaifuEvolved(uint256 indexed id, uint8 newTier, uint256 timestamp);
    event WaifuRested(uint256 indexed id, uint256 stamina, uint256 cooldownReduction);
    event WaifuFused(uint256 indexed newId, uint256 waifu1Id, uint256 waifu2Id, uint256 timestamp);
    event ModifierApplied(uint256 indexed waifuId, uint8 modifierType, uint256 duration, uint256 timestamp);
    event QuestProgressed(uint256 indexed waifuId, uint8 questType, uint256 progress, uint256 timestamp);
    event QuestCompleted(uint256 indexed waifuId, uint8 questType, uint256 reward);
    event ItemCrafted(uint256 indexed id, uint8 itemType, uint8 tier, uint8 rarity, uint256 value);
    event ItemEnchanted(uint256 indexed id, uint8 enchantmentLevel, uint256 valueBefore, uint256 valueAfter, uint256 timestamp);
    event ItemEquipped(uint256 indexed waifuId, uint256 itemId, uint256 statBoost);
    event ItemUnequipped(uint256 indexed waifuId, uint256 itemId, uint256 statReduction);
    event BattleStarted(uint256 indexed battleId, uint256[] waifuIds, uint8 mode, uint8 formation, uint256 startTime);
    event BattlePhaseScored(uint256 indexed battleId, uint8 phase, uint256[5] scores, uint256 timestamp);
    event PhaseModifierApplied(uint256 indexed battleId, uint256 waifuId, uint8 phase, uint8 modifierType, uint256 value, uint256 timestamp);
    event BattleEnded(uint256 indexed battleId, uint256 winnerId, uint256 reward);
    event GuildCreated(uint256 indexed id, address leader, uint256 timestamp);
    event GuildOfficerAdded(uint256 indexed guildId, address officer, uint256 timestamp);
    event GuildMemberAdded(uint256 indexed guildId, address member, uint256 timestamp);
    event GuildResourcesAdded(uint256 indexed guildId, uint8 resourceType, uint256 amount, uint256 totalPool);
    event GuildMissionProgressed(uint256 indexed guildId, uint256 progress, uint256 timestamp);
    event GuildEventProgressed(uint256 indexed guildId, uint256 progress, uint256 timestamp);
    event GuildTournamentProgressed(uint256 indexed guildId, uint256 score, uint256 timestamp);
    event GuildAllianceFormed(uint256 indexed guildId1, uint256 guildId2, uint256 timestamp);
    event GuildDiplomacyUpdated(uint256 indexed guildId1, uint256 guildId2, uint8 status, uint256 timestamp);
    event GuildRankUpgraded(uint256 indexed guildId, uint8 newRank, uint256 timestamp);
    event GuildBuffApplied(uint256 indexed guildId, uint8 buffType, uint256 amount, uint256 timestamp);
    event GuildBattle(uint256 indexed guild1Id, uint256 guild2Id, uint256 winnerId, uint256 timestamp);
    event SuperSaiyanActivated(uint256 indexed waifuId, uint8 mode, uint256 powerBoost, uint256 duration, uint256 timestamp);
    event SuperSaiyanDeactivated(uint256 indexed waifuId, uint256 timestamp);
    event MechaBossSummoned(uint256 indexed guildId, uint256 mechaId, uint256 attack, uint256 defense, uint256 speed, uint256 timestamp);
    event MechaBossBattle(uint256 indexed mechaId1, uint256 indexed mechaId2, uint256 winnerId, uint256 timestamp);
    event ListingCreated(uint256 indexed listingId, uint8 listingType, uint256 assetId, uint256 price, uint256 deadline);
    event ListingBid(uint256 indexed listingId, address bidder, uint256 bid, uint256 timestamp);
    event ListingPurchased(uint256 indexed listingId, address buyer, uint256 timestamp);
    event RewardClaimed(address indexed player, uint256 amount, uint256 timestamp);

    // Modifier to restrict access to waifu owners
    modifier onlyOwner(uint256 waifuId) {
        require(waifus[waifuId].owner == msg.sender, "You are not the owner of this waifu - access denied");
        _;
    }

    // Modifier to restrict access to guild leaders
    modifier onlyGuildLeader(uint256 guildId) {
        require(guilds[guildId].leader == msg.sender, "You are not the guild leader - operation restricted");
        _;
    }

    // Modifier to restrict access to the contract owner.
    modifier onlyContractOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    // Constructor to initialize counters and set owner
    constructor() {
        owner = msg.sender;
        waifuCount = 0;
        itemCount = 0;
        battleCount = 0;
        guildCount = 0;
        mechaBossCount = 0;
        listingCount = 0;
    }

    // Function to create a new waifu with specified role, tier, and personality
    function createWaifu(uint8 role, uint8 tier, uint8 personality) public payable {
        require(role < 5, "Invalid role specified - must be between 0 and 4");
        require(tier < 5, "Invalid tier specified - must be between 0 and 4");
        require(personality < 5, "Invalid personality specified - must be between 0 and 4");
        uint256 cost = 0.1 ether * (tier + 1) + (role == 4 ? 0.05 ether : 0.02 ether) + (personality == 4 ? 0.03 ether : 0);
        require(msg.value >= cost, "Insufficient ETH sent for waifu creation - check cost requirements");
        uint256 id = waifuCount++;
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, id)));

        waifus[id] = Waifu({
            id: id,
            owner: msg.sender,
            role: role,
            tier: tier,
            personality: personality,
            attack: 50 + (rand % 50) + (role == 0 ? 25 : 0) + (personality == 0 ? 15 : 0),
            defense: 30 + (rand % 30) + (role == 1 ? 20 : 0) + (personality == 1 ? 10 : 0),
            speed: 20 + (rand % 40) + (role == 2 ? 15 : 0) + (personality == 2 ? 12 : 0),
            hp: 100 + (rand % 30) + (role == 3 ? 30 : 0) + (personality == 3 ? 20 : 0),
            stamina: 50 + (rand % 20) + (role == 4 ? 25 : 0) + (personality == 4 ? 15 : 0),
            exp: 0,
            skills: [uint256(1), 1, 1],
            traits: [uint256(1), 1, 1],
            cooldowns: [uint256(0), 0, 0],
            modifiers: [uint256(0), 0, 0],
            questProgress: [uint256(0), 0, 0, 0, 0],
            items: new uint256[](0),
            isFused: false,
            lastBattleTimestamp: 0,
            trainingCount: 0,
            roleSynergyBonus: [uint256(0), 0, 0, 0, 0],
            personalityBoost: personality == 0 ? 10 : personality == 1 ? 8 : personality == 2 ? 12 : personality == 3 ? 15 : 20,
            battleHistory: [uint256(0), 0, 0, 0, 0],
            itemTypeBoosts: [uint256(0), 0, 0, 0],
            lastRestTimestamp: 0
        });

        waifuSkills[id][0] = Skill(1, 10 + (role == 0 ? 20 : 5), 2, role == 0 ? 1 : 0);
        waifuSkills[id][1] = Skill(1, 8 + (role == 1 ? 15 : 3), 3, role == 1 ? 2 : 0);
        waifuSkills[id][2] = Skill(1, 6 + (role == 2 ? 12 : 2), 4, role == 2 ? 3 : 0);
        waifuTraits[id][0] = Trait(1, role == 0 ? 10 : 5);
        waifuTraits[id][1] = Trait(1, role == 1 ? 8 : 4);
        waifuTraits[id][2] = Trait(1, role == 2 ? 6 : 3);

        emit WaifuCreated(id, msg.sender, role, tier, personality, block.timestamp);
    }

    // Training function for attackers, increases attack stat and experience
    function trainAttacker(uint256 waifuId) public payable onlyOwner(waifuId) {
        require(msg.value >= 0.02 ether, "Insufficient ETH payment for attacker training - minimum 0.02 ether required");
        Waifu storage w = waifus[waifuId];
        require(w.role == 0, "This waifu is not an attacker role - training aborted");

        uint256 expBefore = w.exp;
        uint256 attackBefore = w.attack;
        uint256 expGain = 15;
        if (w.tier == 0) expGain += 0;
        else if (w.tier == 1) expGain += 3;
        else if (w.tier == 2) expGain += 6;
        else if (w.tier == 3) expGain += 9;
        else if (w.tier == 4) expGain += 12;
        if (w.personality == 0) expGain += 10;
        w.exp += expGain;

        uint256 attackBoost = 10;
        if (w.skills[0] == 1) attackBoost += 2;
        else if (w.skills[0] == 2) attackBoost += 4;
        else if (w.skills[0] == 3) attackBoost += 6;
        else if (w.skills[0] == 4) attackBoost += 8;
        attackBoost += w.traits[0] * 3;
        attackBoost = (attackBoost * rolePersonalityMultipliers[0][w.personality]) / 100;
        w.attack += attackBoost;

        uint256 staminaLoss = 5;
        if (w.personality == 3) staminaLoss -= 2;
        w.stamina -= staminaLoss;
        w.cooldowns[0] += 1;
        if (w.modifiers[0] > 0) w.hp -= 5;
        if (w.personality == 4) w.hp -= 3;

        w.trainingCount += 1;
        w.lastBattleTimestamp = block.timestamp;
        w.personalityBoost = w.personality == 0 ? 15 : 5;

        progressQuest(w, 0);
        emit WaifuTrainedAttack(waifuId, expBefore, w.exp, attackBefore, w.attack, w.trainingCount, block.timestamp);
        checkEvolution(waifuId);
    }

    // Training function for defenders, increases defense stat and experience
    function trainDefender(uint256 waifuId) public payable onlyOwner(waifuId) {
        require(msg.value >= 0.025 ether, "Insufficient ETH payment for defender training - minimum 0.025 ether required");
        Waifu storage w = waifus[waifuId];
        require(w.role == 1, "This waifu is not a defender role - training aborted");

        uint256 expBefore = w.exp;
        uint256 defenseBefore = w.defense;
        uint256 expGain = 12;
        if (w.tier == 0) expGain += 0;
        else if (w.tier == 1) expGain += 2;
        else if (w.tier == 2) expGain += 4;
        else if (w.tier == 3) expGain += 6;
        else if (w.tier == 4) expGain += 8;
        if (w.personality == 1) expGain += 8;
        w.exp += expGain;

        uint256 defenseBoost = 8;
        if (w.skills[1] == 1) defenseBoost += 3;
        else if (w.skills[1] == 2) defenseBoost += 6;
        else if (w.skills[1] == 3) defenseBoost += 9;
        else if (w.skills[1] == 4) defenseBoost += 12;
        defenseBoost += w.traits[1] * 2;
        defenseBoost = (defenseBoost * rolePersonalityMultipliers[1][w.personality]) / 100;
        w.defense += defenseBoost;

        w.hp += 10 + (w.modifiers[1] > 0 ? 5 : 0);
        w.cooldowns[1] += 2;
        if (w.personality == 4) w.speed -= 2;

        w.trainingCount += 1;
        w.lastBattleTimestamp = block.timestamp;
        w.personalityBoost = w.personality == 1 ? 12 : 4;

        progressQuest(w, 1);
        emit WaifuTrainedDefense(waifuId, expBefore, w.exp, defenseBefore, w.defense, w.trainingCount, block.timestamp);
        checkEvolution(waifuId);
    }

    // Training function for supports, increases speed stat and experience
    function trainSupport(uint256 waifuId) public payable onlyOwner(waifuId) {
        require(msg.value >= 0.015 ether, "Insufficient ETH payment for support training - minimum 0.015 ether required");
        Waifu storage w = waifus[waifuId];
        require(w.role == 2, "This waifu is not a support role - training aborted");

        uint256 expBefore = w.exp;
        uint256 speedBefore = w.speed;
        uint256 expGain = 10;
        if (w.tier == 0) expGain += 0;
        else if (w.tier == 1) expGain += 1;
        else if (w.tier == 2) expGain += 2;
        else if (w.tier == 3) expGain += 3;
        else if (w.tier == 4) expGain += 4;
        if (w.personality == 2) expGain += 7;
        w.exp += expGain;

        uint256 speedBoost = 7;
        if (w.skills[2] == 1) speedBoost += 2;
        else if (w.skills[2] == 2) speedBoost += 4;
        else if (w.skills[2] == 3) speedBoost += 6;
        else if (w.skills[2] == 4) speedBoost += 8;
        speedBoost += w.traits[2] * 1;
        speedBoost = (speedBoost * rolePersonalityMultipliers[2][w.personality]) / 100;
        w.speed += speedBoost;

        w.stamina += 5;
        w.cooldowns[2] += 1;
        if (w.personality == 4) w.attack -= 2;

        w.trainingCount += 1;
        w.lastBattleTimestamp = block.timestamp;
        w.personalityBoost = w.personality == 2 ? 10 : 3;

        progressQuest(w, 2);
        emit WaifuTrainedSpeed(waifuId, expBefore, w.exp, speedBefore, w.speed, w.trainingCount, block.timestamp);
        checkEvolution(waifuId);
    }

    // Training function for healers, increases HP stat and experience
    function trainHealer(uint256 waifuId) public payable onlyOwner(waifuId) {
        require(msg.value >= 0.03 ether, "Insufficient ETH payment for healer training - minimum 0.03 ether required");
        Waifu storage w = waifus[waifuId];
        require(w.role == 3, "This waifu is not a healer role - training aborted");

        uint256 expBefore = w.exp;
        uint256 hpBefore = w.hp;
        uint256 expGain = 18;
        if (w.tier == 0) expGain += 0;
        else if (w.tier == 1) expGain += 4;
        else if (w.tier == 2) expGain += 8;
        else if (w.tier == 3) expGain += 12;
        else if (w.tier == 4) expGain += 16;
        if (w.personality == 3) expGain += 10;
        w.exp += expGain;

        uint256 hpBoost = 15;
        if (w.tier == 0) hpBoost += 0;
        else if (w.tier == 1) hpBoost += 5;
        else if (w.tier == 2) hpBoost += 10;
        else if (w.tier == 3) hpBoost += 15;
        else if (w.tier == 4) hpBoost += 20;
        hpBoost += w.traits[0] * 2 + (w.modifiers[1] > 0 ? 10 : 0);
        hpBoost = (hpBoost * rolePersonalityMultipliers[3][w.personality]) / 100;
        w.hp += hpBoost;

        w.defense += 5;
        w.cooldowns[0] += 3;
        if (w.personality == 4) w.stamina -= 3;

        w.trainingCount += 1;
        w.lastBattleTimestamp = block.timestamp;
        w.personalityBoost = w.personality == 3 ? 15 : 5;

        progressQuest(w, 3);
        emit WaifuTrainedHp(waifuId, expBefore, w.exp, hpBefore, w.hp, w.trainingCount, block.timestamp);
        checkEvolution(waifuId);
    }

    // Training function for tacticians, increases stamina stat and experience
    function trainTactician(uint256 waifuId) public payable onlyOwner(waifuId) {
        require(msg.value >= 0.02 ether, "Insufficient ETH payment for tactician training - minimum 0.02 ether required");
        Waifu storage w = waifus[waifuId];
        require(w.role == 4, "This waifu is not a tactician role - training aborted");

        uint256 expBefore = w.exp;
        uint256 staminaBefore = w.stamina;
        uint256 expGain = 14;
        if (w.tier == 0) expGain += 0;
        else if (w.tier == 1) expGain += 3;
        else if (w.tier == 2) expGain += 6;
        else if (w.tier == 3) expGain += 9;
        else if (w.tier == 4) expGain += 12;
        if (w.personality == 4) expGain += 8;
        w.exp += expGain;

        uint256 staminaBoost = 10;
        if (w.skills[1] == 1) staminaBoost += 2;
        else if (w.skills[1] == 2) staminaBoost += 4;
        else if (w.skills[1] == 3) staminaBoost += 6;
        else if (w.skills[1] == 4) staminaBoost += 8;
        staminaBoost += w.traits[2] * 3;
        staminaBoost = (staminaBoost * rolePersonalityMultipliers[4][w.personality]) / 100;
        w.stamina += staminaBoost;

        w.speed += 4;
        w.cooldowns[1] += 2;
        if (w.modifiers[0] > 0) w.hp -= 3;
        if (w.personality == 0) w.defense -= 2;

        w.trainingCount += 1;
        w.lastBattleTimestamp = block.timestamp;
        w.personalityBoost = w.personality == 4 ? 12 : 4;

        progressQuest(w, 4);
        emit WaifuTrainedStamina(waifuId, expBefore, w.exp, staminaBefore, w.stamina, w.trainingCount, block.timestamp);
        checkEvolution(waifuId);
    }

    // Function to upgrade an attacker's skill
    function upgradeAttackerSkill(uint256 waifuId, uint8 skillIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 0, "This waifu is not an attacker - skill upgrade aborted");
        require(skillIndex < 3, "Invalid skill index specified - must be 0, 1, or 2");
        require(msg.value >= 0.03 ether, "Insufficient ETH payment for attacker skill upgrade - minimum 0.03 ether required");
        Waifu storage w = waifus[waifuId];
        Skill storage s = waifuSkills[waifuId][skillIndex];
        require(s.level < 5, "Skill has reached maximum level - upgrade not possible");

        uint256 levelBefore = s.level;
        uint256 powerBefore = s.power;
        s.level += 1;
        uint256 powerIncrease = 10;
        if (skillIndex == 0) powerIncrease += 15;
        else if (skillIndex == 1) powerIncrease += 10;
        else powerIncrease += 5;
        if (w.personality == 0) powerIncrease += 5;
        powerIncrease = (powerIncrease * rolePersonalityMultipliers[0][w.personality]) / 100;
        s.power += powerIncrease;

        w.skills[skillIndex] = s.level;
        w.cooldowns[skillIndex] += 1;
        if (skillIndex == 0) w.modifiers[0] = 3;

        w.trainingCount += 1;
        emit WaifuSkillUpgraded(waifuId, skillIndex, levelBefore, s.level, powerBefore, s.power, block.timestamp);
        emit ModifierApplied(waifuId, 0, 3, block.timestamp);
    }

    // Function to upgrade a defender's skill
    function upgradeDefenderSkill(uint256 waifuId, uint8 skillIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 1, "This waifu is not a defender - skill upgrade aborted");
        require(skillIndex < 3, "Invalid skill index specified - must be 0, 1, or 2");
        require(msg.value >= 0.035 ether, "Insufficient ETH payment for defender skill upgrade - minimum 0.035 ether required");
        Waifu storage w = waifus[waifuId];
        Skill storage s = waifuSkills[waifuId][skillIndex];
        require(s.level < 5, "Skill has reached maximum level - upgrade not possible");

        uint256 levelBefore = s.level;
        uint256 powerBefore = s.power;
        s.level += 1;
        uint256 powerIncrease = 8;
        if (skillIndex == 0) powerIncrease += 8;
        else if (skillIndex == 1) powerIncrease += 12;
        else powerIncrease += 4;
        if (w.personality == 1) powerIncrease += 4;
        powerIncrease = (powerIncrease * rolePersonalityMultipliers[1][w.personality]) / 100;
        s.power += powerIncrease;

        w.skills[skillIndex] = s.level;
        w.cooldowns[skillIndex] += 2;
        if (skillIndex == 1) w.modifiers[1] = 4;

        w.trainingCount += 1;
        emit WaifuSkillUpgraded(waifuId, skillIndex, levelBefore, s.level, powerBefore, s.power, block.timestamp);
        emit ModifierApplied(waifuId, 1, 4, block.timestamp);
    }

    // Function to upgrade a support's skill
    function upgradeSupportSkill(uint256 waifuId, uint8 skillIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 2, "This waifu is not a support - skill upgrade aborted");
        require(skillIndex < 3, "Invalid skill index specified - must be 0, 1, or 2");
        require(msg.value >= 0.04 ether, "Insufficient ETH payment for support skill upgrade - minimum 0.04 ether required");
        Waifu storage w = waifus[waifuId];
        Skill storage s = waifuSkills[waifuId][skillIndex];
        require(s.level < 5, "Skill has reached maximum level - upgrade not possible");

        uint256 levelBefore = s.level;
        uint256 powerBefore = s.power;
        s.level += 1;
        uint256 powerIncrease = 6;
        if (skillIndex == 0) powerIncrease += 5;
        else if (skillIndex == 1) powerIncrease += 10;
        else powerIncrease += 15;
        if (w.personality == 2) powerIncrease += 5;
        powerIncrease = (powerIncrease * rolePersonalityMultipliers[2][w.personality]) / 100;
        s.power += powerIncrease;

        w.skills[skillIndex] = s.level;
        w.cooldowns[skillIndex] += 1;
        if (skillIndex == 2) w.modifiers[2] = 2;

        w.trainingCount += 1;
        emit WaifuSkillUpgraded(waifuId, skillIndex, levelBefore, s.level, powerBefore, s.power, block.timestamp);
        emit ModifierApplied(waifuId, 2, 2, block.timestamp);
    }

    // Function to upgrade a healer's skill
    function upgradeHealerSkill(uint256 waifuId, uint8 skillIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 3, "This waifu is not a healer - skill upgrade aborted");
        require(skillIndex < 3, "Invalid skill index specified - must be 0, 1, or 2");
        require(msg.value >= 0.045 ether, "Insufficient ETH payment for healer skill upgrade - minimum 0.045 ether required");
        Waifu storage w = waifus[waifuId];
        Skill storage s = waifuSkills[waifuId][skillIndex];
        require(s.level < 5, "Skill has reached maximum level - upgrade not possible");

        uint256 levelBefore = s.level;
        uint256 powerBefore = s.power;
        s.level += 1;
        uint256 powerIncrease = 7;
        if (skillIndex == 0) powerIncrease += 12;
        else if (skillIndex == 1) powerIncrease += 4;
        else powerIncrease += 8;
        if (w.personality == 3) powerIncrease += 6;
        powerIncrease = (powerIncrease * rolePersonalityMultipliers[3][w.personality]) / 100;
        s.power += powerIncrease;

        w.skills[skillIndex] = s.level;
        w.cooldowns[skillIndex] += 3;
        if (skillIndex == 0) w.modifiers[1] = 5;

        w.trainingCount += 1;
        emit WaifuSkillUpgraded(waifuId, skillIndex, levelBefore, s.level, powerBefore, s.power, block.timestamp);
        emit ModifierApplied(waifuId, 1, 5, block.timestamp);
    }

    // Function to upgrade a tactician's skill
    function upgradeTacticianSkill(uint256 waifuId, uint8 skillIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 4, "This waifu is not a tactician - skill upgrade aborted");
        require(skillIndex < 3, "Invalid skill index specified - must be 0, 1, or 2");
        require(msg.value >= 0.05 ether, "Insufficient ETH payment for tactician skill upgrade - minimum 0.05 ether required");
        Waifu storage w = waifus[waifuId];
        Skill storage s = waifuSkills[waifuId][skillIndex];
        require(s.level < 5, "Skill has reached maximum level - upgrade not possible");

        uint256 levelBefore = s.level;
        uint256 powerBefore = s.power;
        s.level += 1;
        uint256 powerIncrease = 9;
        if (skillIndex == 0) powerIncrease += 10;
        else if (skillIndex == 1) powerIncrease += 15;
        else powerIncrease += 6;
        if (w.personality == 4) powerIncrease += 7;
        powerIncrease = (powerIncrease * rolePersonalityMultipliers[4][w.personality]) / 100;
        s.power += powerIncrease;

        w.skills[skillIndex] = s.level;
        w.cooldowns[skillIndex] += 2;
        if (skillIndex == 1) w.modifiers[0] = 3;

        w.trainingCount += 1;
        emit WaifuSkillUpgraded(waifuId, skillIndex, levelBefore, s.level, powerBefore, s.power, block.timestamp);
        emit ModifierApplied(waifuId, 0, 3, block.timestamp);
    }

    // Function to upgrade an attacker's trait
    function upgradeAttackerTrait(uint256 waifuId, uint8 traitIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 0, "This waifu is not an attacker - trait upgrade aborted");
        require(traitIndex < 3, "Invalid trait index specified - must be 0, 1, or 2");
        require(msg.value >= 0.04 ether, "Insufficient ETH payment for attacker trait upgrade - minimum 0.04 ether required");
        Waifu storage w = waifus[waifuId];
        Trait storage t = waifuTraits[waifuId][traitIndex];
        require(t.level < 5, "Trait has reached maximum level - upgrade not possible");

        uint256 levelBefore = t.level;
        uint256 effectBefore = t.effect;
        t.level += 1;
        uint256 effectIncrease = 5;
        if (traitIndex == 0) effectIncrease += 10;
        else if (traitIndex == 1) effectIncrease += 7;
        else effectIncrease += 3;
        if (w.personality == 0) effectIncrease += 3;
        effectIncrease = (effectIncrease * rolePersonalityMultipliers[0][w.personality]) / 100;
        t.effect += effectIncrease;

        w.traits[traitIndex] = t.level;
        w.trainingCount += 1;
        emit WaifuTraitUpgraded(waifuId, traitIndex, levelBefore, t.level, effectBefore, t.effect, block.timestamp);
    }

    // Function to upgrade a defender's trait
    function upgradeDefenderTrait(uint256 waifuId, uint8 traitIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 1, "This waifu is not a defender - trait upgrade aborted");
        require(traitIndex < 3, "Invalid trait index specified - must be 0, 1, or 2");
        require(msg.value >= 0.045 ether, "Insufficient ETH payment for defender trait upgrade - minimum 0.045 ether required");
        Waifu storage w = waifus[waifuId];
        Trait storage t = waifuTraits[waifuId][traitIndex];
        require(t.level < 5, "Trait has reached maximum level - upgrade not possible");

        uint256 levelBefore = t.level;
        uint256 effectBefore = t.effect;
        t.level += 1;
        uint256 effectIncrease = 4;
        if (traitIndex == 0) effectIncrease += 6;
        else if (traitIndex == 1) effectIncrease += 8;
        else effectIncrease += 2;
        if (w.personality == 1) effectIncrease += 2;
        effectIncrease = (effectIncrease * rolePersonalityMultipliers[1][w.personality]) / 100;
        t.effect += effectIncrease;

        w.traits[traitIndex] = t.level;
        w.trainingCount += 1;
        emit WaifuTraitUpgraded(waifuId, traitIndex, levelBefore, t.level, effectBefore, t.effect, block.timestamp);
    }

    // Function to upgrade a support's trait
    function upgradeSupportTrait(uint256 waifuId, uint8 traitIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 2, "This waifu is not a support - trait upgrade aborted");
        require(traitIndex < 3, "Invalid trait index specified - must be 0, 1, or 2");
        require(msg.value >= 0.03 ether, "Insufficient ETH payment for support trait upgrade - minimum 0.03 ether required");
        Waifu storage w = waifus[waifuId];
        Trait storage t = waifuTraits[waifuId][traitIndex];
        require(t.level < 5, "Trait has reached maximum level - upgrade not possible");

        uint256 levelBefore = t.level;
        uint256 effectBefore = t.effect;
        t.level += 1;
        uint256 effectIncrease = 3;
        if (traitIndex == 0) effectIncrease += 2;
        else if (traitIndex == 1) effectIncrease += 5;
        else effectIncrease += 7;
        if (w.personality == 2) effectIncrease += 3;
        effectIncrease = (effectIncrease * rolePersonalityMultipliers[2][w.personality]) / 100;
        t.effect += effectIncrease;

        w.traits[traitIndex] = t.level;
        w.trainingCount += 1;
        emit WaifuTraitUpgraded(waifuId, traitIndex, levelBefore, t.level, effectBefore, t.effect, block.timestamp);
    }

    // Function to upgrade a healer's trait
    function upgradeHealerTrait(uint256 waifuId, uint8 traitIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 3, "This waifu is not a healer - trait upgrade aborted");
        require(traitIndex < 3, "Invalid trait index specified - must be 0, 1, or 2");
        require(msg.value >= 0.05 ether, "Insufficient ETH payment for healer trait upgrade - minimum 0.05 ether required");
        Waifu storage w = waifus[waifuId];
        Trait storage t = waifuTraits[waifuId][traitIndex];
        require(t.level < 5, "Trait has reached maximum level - upgrade not possible");

        uint256 levelBefore = t.level;
        uint256 effectBefore = t.effect;
        t.level += 1;
        uint256 effectIncrease = 6;
        if (traitIndex == 0) effectIncrease += 9;
        else if (traitIndex == 1) effectIncrease += 3;
        else effectIncrease += 6;
        if (w.personality == 3) effectIncrease += 4;
        effectIncrease = (effectIncrease * rolePersonalityMultipliers[3][w.personality]) / 100;
        t.effect += effectIncrease;

        w.traits[traitIndex] = t.level;
        w.trainingCount += 1;
        emit WaifuTraitUpgraded(waifuId, traitIndex, levelBefore, t.level, effectBefore, t.effect, block.timestamp);
    }

    // Function to upgrade a tactician's trait
    function upgradeTacticianTrait(uint256 waifuId, uint8 traitIndex) public payable onlyOwner(waifuId) {
        require(waifus[waifuId].role == 4, "This waifu is not a tactician - trait upgrade aborted");
        require(traitIndex < 3, "Invalid trait index specified - must be 0, 1, or 2");
        require(msg.value >= 0.055 ether, "Insufficient ETH payment for tactician trait upgrade - minimum 0.055 ether required");
        Waifu storage w = waifus[waifuId];
        Trait storage t = waifuTraits[waifuId][traitIndex];
        require(t.level < 5, "Trait has reached maximum level - upgrade not possible");

        uint256 levelBefore = t.level;
        uint256 effectBefore = t.effect;
        t.level += 1;
        uint256 effectIncrease = 5;
        if (traitIndex == 0) effectIncrease += 8;
        else if (traitIndex == 1) effectIncrease += 10;
        else effectIncrease += 4;
        if (w.personality == 4) effectIncrease += 5;
        effectIncrease = (effectIncrease * rolePersonalityMultipliers[4][w.personality]) / 100;
        t.effect += effectIncrease;

        w.traits[traitIndex] = t.level;
        w.trainingCount += 1;
        emit WaifuTraitUpgraded(waifuId, traitIndex, levelBefore, t.level, effectBefore, t.effect, block.timestamp);
    }

    // Function to rest a waifu, restoring stamina and reducing cooldowns
    function restWaifu(uint256 waifuId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        uint256 maxStamina = 50 + (w.role == 4 ? 25 : 0) + (w.tier * 10) + (w.traits[2] * 2) + (w.personality == 3 ? 10 : 0);
        require(w.stamina < maxStamina, "Waifu stamina is already full - rest not needed");

        w.stamina = maxStamina;
        uint256 cooldownReduction = 0;
        if (w.cooldowns[0] > 0) { w.cooldowns[0] -= 1; cooldownReduction += 1; }
        if (w.cooldowns[1] > 0) { w.cooldowns[1] -= 1; cooldownReduction += 1; }
        if (w.cooldowns[2] > 0) { w.cooldowns[2] -= 1; cooldownReduction += 1; }
        if (w.modifiers[0] > 0) w.modifiers[0] -= 1;
        if (w.modifiers[1] > 0) w.modifiers[1] -= 1;
        if (w.modifiers[2] > 0) w.modifiers[2] -= 1;

        if (w.personality == 0) w.attack += 5;
        w.lastRestTimestamp = block.timestamp;
        emit WaifuRested(waifuId, w.stamina, cooldownReduction);
    }

    // Function to fuse two waifus into a new, stronger waifu
    function fuseWaifus(uint256 waifu1Id, uint256 waifu2Id) public payable onlyOwner(waifu1Id) onlyOwner(waifu2Id) {
        require(msg.value >= 0.2 ether, "Insufficient ETH payment for waifu fusion - minimum 0.2 ether required");
        Waifu storage w1 = waifus[waifu1Id];
        Waifu storage w2 = waifus[waifu2Id];
        require(!w1.isFused && !w2.isFused, "One or both waifus are already fused - fusion aborted");
        require(w1.role == w2.role, "Waifus must have the same role for fusion");

        uint256 id = waifuCount++;
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, id)));
        uint8 personality = w1.personality == w2.personality ? w1.personality : uint8(rand % 5);

        waifus[id] = Waifu({
            id: id,
            owner: msg.sender,
            role: w1.role,
            tier: (w1.tier + w2.tier) / 2 + 1 > 4 ? 4 : (w1.tier + w2.tier) / 2 + 1,
            personality: personality,
            attack: (w1.attack + w2.attack) / 2 + (rand % 20) + (personality == 0 ? 10 : 0),
            defense: (w1.defense + w2.defense) / 2 + (rand % 15) + (personality == 1 ? 8 : 0),
            speed: (w1.speed + w2.speed) / 2 + (rand % 10) + (personality == 2 ? 7 : 0),
            hp: (w1.hp + w2.hp) / 2 + (rand % 25) + (personality == 3 ? 12 : 0),
            stamina: (w1.stamina + w2.stamina) / 2 + (rand % 15) + (personality == 4 ? 10 : 0),
            exp: 0,
            skills: [uint256((w1.skills[0] + w2.skills[0]) / 2), (w1.skills[1] + w2.skills[1]) / 2, (w1.skills[2] + w2.skills[2]) / 2],
            traits: [uint256((w1.traits[0] + w2.traits[0]) / 2), (w1.traits[1] + w2.traits[1]) / 2, (w1.traits[2] + w2.traits[2]) / 2],
            cooldowns: [uint256(0), 0, 0],
            modifiers: [uint256(0), 0, 0],
            questProgress: [uint256(0), 0, 0, 0, 0],
            items: new uint256[](0),
            isFused: true,
            lastBattleTimestamp: block.timestamp,
            trainingCount: 0,
            roleSynergyBonus: [uint256(0), 0, 0, 0, 0],
            personalityBoost: personality == 0 ? 10 : personality == 1 ? 8 : personality == 2 ? 12 : personality == 3 ? 15 : 20,
            battleHistory: [uint256(0), 0, 0, 0, 0],
            itemTypeBoosts: [uint256(0), 0, 0, 0],
            lastRestTimestamp: block.timestamp
        });

        waifuSkills[id][0] = Skill(waifus[id].skills[0], (waifuSkills[waifu1Id][0].power + waifuSkills[waifu2Id][0].power) / 2, 2, w1.role == 0 ? 1 : 0);
        waifuSkills[id][1] = Skill(waifus[id].skills[1], (waifuSkills[waifu1Id][1].power + waifuSkills[waifu2Id][1].power) / 2, 3, w1.role == 1 ? 2 : 0);
        waifuSkills[id][2] = Skill(waifus[id].skills[2], (waifuSkills[waifu1Id][2].power + waifuSkills[waifu2Id][2].power) / 2, 4, w1.role == 2 ? 3 : 0);
        waifuTraits[id][0] = Trait(waifus[id].traits[0], (waifuTraits[waifu1Id][0].effect + waifuTraits[waifu2Id][0].effect) / 2);
        waifuTraits[id][1] = Trait(waifus[id].traits[1], (waifuTraits[waifu1Id][1].effect + waifuTraits[waifu2Id][1].effect) / 2);
        waifuTraits[id][2] = Trait(waifus[id].traits[2], (waifuTraits[waifu1Id][2].effect + waifuTraits[waifu2Id][2].effect) / 2);

        delete waifus[waifu1Id];
        delete waifus[waifu2Id];
        emit WaifuFused(id, waifu1Id, waifu2Id, block.timestamp);
    }

    // Function to craft a new item with specified type, tier, and rarity
    function craftItem(uint8 itemType, uint8 tier, uint8 rarity) public payable {
        require(itemType < 4, "Invalid item type specified - must be between 0 and 3");
        require(tier > 0 && tier <= 5, "Invalid tier specified - must be between 1 and 5");
        require(rarity < 5, "Invalid rarity specified - must be between 0 and 4");
        uint256 price = 0.05 ether * (rarity + 1) * tier + (itemType == 3 ? 0.02 ether : 0.01 ether);
        require(msg.value >= price, "Insufficient ETH sent for item crafting - check cost requirements");

        uint256 id = itemCount++;
        uint256 value = 0;
        if (tier == 1) value = 10 + (rarity * 5) + (itemType * 3);
        else if (tier == 2) value = 20 + (rarity * 10) + (itemType * 5);
        else if (tier == 3) value = 35 + (rarity * 15) + (itemType * 7);
        else if (tier == 4) value = 50 + (rarity * 20) + (itemType * 10);
        else value = 70 + (rarity * 25) + (itemType * 15);

        items[id] = Item(id, itemType, tier, 0, value, rarity);
        emit ItemCrafted(id, itemType, tier, rarity, value);
    }

    // Function to enchant an item, increasing its value
    function enchantItem(uint256 itemId, uint8 enchantmentLevel) public payable {
        require(enchantmentLevel > 0 && enchantmentLevel <= 5, "Invalid enchantment level specified - must be between 1 and 5");
        Item storage i = items[itemId];
        require(i.enchantment == 0, "Item is already enchanted - enchantment aborted");
        uint256 cost = 0.1 ether * enchantmentLevel * i.tier;
        require(msg.value >= cost, "Insufficient ETH sent for item enchantment - check cost requirements");

        uint256 valueBefore = i.value;
        i.enchantment = enchantmentLevel;
        uint256 valueIncrease = 0;
        if (i.itemType == 0) valueIncrease = enchantmentLevel * 10;
        else if (i.itemType == 1) valueIncrease = enchantmentLevel * 8;
        else if (i.itemType == 2) valueIncrease = enchantmentLevel * 6;
        else valueIncrease = enchantmentLevel * 5;
        i.value += valueIncrease;

        emit ItemEnchanted(itemId, enchantmentLevel, valueBefore, i.value, block.timestamp);
    }

    // Function to equip an item to a waifu, boosting relevant stats
    function equipItem(uint256 waifuId, uint256 itemId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        Item storage i = items[itemId];
        w.items.push(itemId);
        uint256 statBoost = 0;
        uint256 multiplier = itemTypeTierMultipliers[i.itemType][i.tier - 1];

        if (i.itemType == 0) {
            statBoost = (i.value * multiplier) / 100 + w.traits[0] * (i.tier + i.enchantment) + (w.personality == 0 ? 10 : 0);
            w.attack += statBoost;
            w.itemTypeBoosts[0] += statBoost / 2;
        } else if (i.itemType == 1) {
            statBoost = (i.value * multiplier) / 100 + w.traits[1] * (i.tier + i.enchantment) + (w.personality == 1 ? 8 : 0);
            w.defense += statBoost;
            w.itemTypeBoosts[1] += statBoost / 2;
        } else if (i.itemType == 2) {
            statBoost = (i.value * multiplier) / 100 + w.traits[2] * (i.tier + i.enchantment) + (w.personality == 2 ? 6 : 0);
            w.speed += statBoost;
            w.itemTypeBoosts[2] += statBoost / 2;
        } else {
            statBoost = (i.value * multiplier) / 100 + (i.tier * 10) + (i.enchantment * 5) + (w.personality == 3 ? 12 : 0);
            w.hp += statBoost;
            w.itemTypeBoosts[3] += statBoost / 2;
        }

        if (w.personality == 2) w.speed += i.enchantment * 2 + w.itemTypeBoosts[2] / 10;
        if (w.personality == 4) w.stamina += i.tier * 3 + w.itemTypeBoosts[3] / 15;
        emit ItemEquipped(waifuId, itemId, statBoost);
    }

    // Function to unequip an item from a waifu, reducing relevant stats
    function unequipItem(uint256 waifuId, uint256 itemId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        Item storage i = items[itemId];
        uint256 statReduction = 0;
        uint256 multiplier = itemTypeTierMultipliers[i.itemType][i.tier - 1];

        for (uint256 j = 0; j < w.items.length; j++) {
            if (w.items[j] == itemId) {
                if (i.itemType == 0) {
                    statReduction = (i.value * multiplier) / 100 + w.traits[0] * (i.tier + i.enchantment) + (w.personality == 0 ? 10 : 0);
                    w.attack -= statReduction;
                    w.itemTypeBoosts[0] -= statReduction / 2;
                } else if (i.itemType == 1) {
                    statReduction = (i.value * multiplier) / 100 + w.traits[1] * (i.tier + i.enchantment) + (w.personality == 1 ? 8 : 0);
                    w.defense -= statReduction;
                    w.itemTypeBoosts[1] -= statReduction / 2;
                } else if (i.itemType == 2) {
                    statReduction = (i.value * multiplier) / 100 + w.traits[2] * (i.tier + i.enchantment) + (w.personality == 2 ? 6 : 0);
                    w.speed -= statReduction;
                    w.itemTypeBoosts[2] -= statReduction / 2;
                } else {
                    statReduction = (i.value * multiplier) / 100 + (i.tier * 10) + (i.enchantment * 5) + (w.personality == 3 ? 12 : 0);
                    w.hp -= statReduction;
                    w.itemTypeBoosts[3] -= statReduction / 2;
                }

                if (w.personality == 2) w.speed -= i.enchantment * 2 + w.itemTypeBoosts[2] / 10;
                if (w.personality == 4) w.stamina -= i.tier * 3 + w.itemTypeBoosts[3] / 15;
                w.items[j] = w.items[w.items.length - 1];
                w.items.pop();
                emit ItemUnequipped(waifuId, itemId, statReduction);
                break;
            }
        }
    }

    // Function to initiate a 1v1 battle with attacker focus
    function battleAttacker(uint256 waifu1Id, uint256 waifu2Id, uint8 formation) public onlyOwner(waifu1Id) {
        require(formation < 3, "Invalid formation specified - must be 0, 1, or 2");
        fightBattle1v1(waifu1Id, waifu2Id, 0, formation);
    }

    // Function to initiate a 1v1 battle with defender focus
    function battleDefender(uint256 waifu1Id, uint256 waifu2Id, uint8 formation) public onlyOwner(waifu1Id) {
        require(formation < 3, "Invalid formation specified - must be 0, 1, or 2");
        fightBattle1v1(waifu1Id, waifu2Id, 1, formation);
    }

    // Function to initiate a 1v1 battle with support focus
    function battleSupport(uint256 waifu1Id, uint256 waifu2Id, uint8 formation) public onlyOwner(waifu1Id) {
        require(formation < 3, "Invalid formation specified - must be 0, 1, or 2");
        fightBattle1v1(waifu1Id, waifu2Id, 2, formation);
    }

    // Function to initiate a 1v1 battle with healer focus
    function battleHealer(uint256 waifu1Id, uint256 waifu2Id, uint8 formation) public onlyOwner(waifu1Id) {
        require(formation < 3, "Invalid formation specified - must be 0, 1, or 2");
        fightBattle1v1(waifu1Id, waifu2Id, 3, formation);
    }

    // Function to initiate a 1v1 battle with tactician focus
    function battleTactician(uint256 waifu1Id, uint256 waifu2Id, uint8 formation) public onlyOwner(waifu1Id) {
        require(formation < 3, "Invalid formation specified - must be 0, 1, or 2");
        fightBattle1v1(waifu1Id, waifu2Id, 4, formation);
    }

    // Internal function to handle 1v1 battle logic
    function fightBattle1v1(uint256 waifu1Id, uint256 waifu2Id, uint8 mode, uint8 formation) internal {
        require(waifu1Id != waifu2Id, "Waifu cannot battle itself - select a different opponent");
        uint256 battleId = battleCount++;
        uint256[] memory ids = new uint256[](2);
        ids[0] = waifu1Id;
        ids[1] = waifu2Id;

        Battle storage b = battles[battleId];
        b.waifuIds = ids;
        b.mode = mode;
        b.formation = formation;
        b.phaseScores = new uint256[5][](2);
        b.phaseTypes = generateDynamicPhases();
        b.battleStartTime = block.timestamp;

        Waifu storage w1 = waifus[waifu1Id];
        Waifu storage w2 = waifus[waifu2Id];
        uint256 synergyBonus1 = calculateSynergyBonus(w1, w2);
        uint256 synergyBonus2 = calculateSynergyBonus(w2, w1);
        uint256 formationBonus1 = formation == 0 ? 15 : formation == 1 ? 5 : 10;
        uint256 formationBonus2 = formation == 0 ? 15 : formation == 1 ? 5 : 10;

        for (uint8 i = 0; i < 5; i++) {
            if (b.phaseTypes[i] == 0) {
                b.phaseScores[i] = [
                    w1.cooldowns[0] > 0 ? w1.attack * 2 : w1.attack * 4 + waifuSkills[waifu1Id][0].power * w1.traits[0] + synergyBonus1 + formationBonus1,
                    w2.cooldowns[0] > 0 ? w2.attack * 2 : w2.attack * 4 + waifuSkills[waifu2Id][0].power * w2.traits[0] + synergyBonus2 + formationBonus2
                ];
                if (w1.role == 0) applyModifiersAttacker(w1, w2, 0);
                else if (w1.role == 1) applyModifiersDefender(w1, w2, 0);
                else if (w1.role == 2) applyModifiersSupport(w1, w2, 0);
                else if (w1.role == 3) applyModifiersHealer(w1, w2, 0);
                else applyModifiersTactician(w1, w2, 0);
                emit PhaseModifierApplied(battleId, w1.id, i, w1.modifiers[0] > 0 ? 0 : 1, w1.modifiers[0], block.timestamp);
                if (w2.role == 0) applyModifiersAttacker(w2, w1, 0);
                else if (w2.role == 1) applyModifiersDefender(w2, w1, 0);
                else if (w2.role == 2) applyModifiersSupport(w2, w1, 0);
                else if (w2.role == 3) applyModifiersHealer(w2, w1, 0);
                else applyModifiersTactician(w2, w1, 0);
                emit PhaseModifierApplied(battleId, w2.id, i, w2.modifiers[0] > 0 ? 0 : 1, w2.modifiers[0], block.timestamp);
            } else if (b.phaseTypes[i] == 1) {
                b.phaseScores[i] = [
                    w1.cooldowns[1] > 0 ? w1.defense * 3 : w1.defense * 5 + waifuSkills[waifu1Id][1].power * w1.traits[1] + synergyBonus1 + formationBonus1,
                    w2.cooldowns[1] > 0 ? w2.defense * 3 : w2.defense * 5 + waifuSkills[waifu2Id][1].power * w2.traits[1] + synergyBonus2 + formationBonus2
                ];
                if (w1.role == 0) applyModifiersAttacker(w1, w2, 1);
                else if (w1.role == 1) applyModifiersDefender(w1, w2, 1);
                else if (w1.role == 2) applyModifiersSupport(w1, w2, 1);
                else if (w1.role == 3) applyModifiersHealer(w1, w2, 1);
                else applyModifiersTactician(w1, w2, 1);
                emit PhaseModifierApplied(battleId, w1.id, i, w1.modifiers[1] > 0 ? 1 : 0, w1.modifiers[1], block.timestamp);
                if (w2.role == 0) applyModifiersAttacker(w2, w1, 1);
                else if (w2.role == 1) applyModifiersDefender(w2, w1, 1);
                else if (w2.role == 2) applyModifiersSupport(w2, w1, 1);
                else if (w2.role == 3) applyModifiersHealer(w2, w1, 1);
                else applyModifiersTactician(w2, w1, 1);
                emit PhaseModifierApplied(battleId, w2.id, i, w2.modifiers[1] > 0 ? 1 : 0, w2.modifiers[1], block.timestamp);
            } else if (b.phaseTypes[i] == 2) {
                b.phaseScores[i] = [
                    w1.cooldowns[2] > 0 || w1.modifiers[2] > 0 ? w1.speed * 2 : w1.speed * 3 + waifuSkills[waifu1Id][2].power * w1.traits[2] + synergyBonus1 + formationBonus1,
                    w2.cooldowns[2] > 0 || w2.modifiers[2] > 0 ? w2.speed * 2 : w2.speed * 3 + waifuSkills[waifu2Id][2].power * w2.traits[2] + synergyBonus2 + formationBonus2
                ];
                if (w1.role == 0) applyModifiersAttacker(w1, w2, 2);
                else if (w1.role == 1) applyModifiersDefender(w1, w2, 2);
                else if (w1.role == 2) applyModifiersSupport(w1, w2, 2);
                else if (w1.role == 3) applyModifiersHealer(w1, w2, 2);
                else applyModifiersTactician(w1, w2, 2);
                emit PhaseModifierApplied(battleId, w1.id, i, w1.modifiers[2] > 0 ? 2 : 0, w1.modifiers[2], block.timestamp);
                if (w2.role == 0) applyModifiersAttacker(w2, w1, 2);
                else if (w2.role == 1) applyModifiersDefender(w2, w1, 2);
                else if (w2.role == 2) applyModifiersSupport(w2, w1, 2);
                else if (w2.role == 3) applyModifiersHealer(w2, w1, 2);
                else applyModifiersTactician(w2, w1, 2);
                emit PhaseModifierApplied(battleId, w2.id, i, w2.modifiers[2] > 0 ? 2 : 0, w2.modifiers[2], block.timestamp);
            } else if (b.phaseTypes[i] == 3) {
                b.phaseScores[i] = [
                    w1.hp * 2 + w1.stamina * w1.traits[0] + synergyBonus1 + formationBonus1,
                    w2.hp * 2 + w2.stamina * w2.traits[0] + synergyBonus2 + formationBonus2
                ];
            } else {
                uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, battleId, i))) % 3;
                b.phaseScores[i] = [
                    rand == 0 ? w1.attack * 3 : rand == 1 ? w1.defense * 3 : w1.speed * 3 + synergyBonus1 + formationBonus1,
                    rand == 0 ? w2.attack * 3 : rand == 1 ? w2.defense * 3 : w2.speed * 3 + synergyBonus2 + formationBonus2
                ];
                if (rand == 0) w1.modifiers[0] = 3;
                else if (rand == 1) w1.modifiers[1] = 4;
                else w1.modifiers[2] = 2;
                emit ModifierApplied(w1.id, uint8(rand), rand == 0 ? 3 : rand == 1 ? 4 : 2, block.timestamp);
                emit PhaseModifierApplied(battleId, w1.id, i, uint8(rand), w1.modifiers[rand], block.timestamp);
            }
            if (w1.personality == 4) b.phaseScores[i][0] += uint256(keccak256(abi.encodePacked(battleId, i))) % 20;
            if (w2.personality == 4) b.phaseScores[i][1] += uint256(keccak256(abi.encodePacked(battleId, i))) % 20;
            w1.battleHistory[i] = b.phaseScores[i][0];
            w2.battleHistory[i] = b.phaseScores[i][1];
            emit BattlePhaseScored(battleId, i, b.phaseScores[i], block.timestamp);
            progressQuest(w1, i % 5);
            progressQuest(w2, i % 5);
        }

        uint256 totalScore1 = calculateTotalScore(b.phaseScores, 0, w1);
        uint256 totalScore2 = calculateTotalScore(b.phaseScores, 1, w2);
        b.winnerId = totalScore1 > totalScore2 ? waifu1Id : waifu2Id;
        rewards[waifus[b.winnerId].owner] += 0.05 ether + (mode == 4 ? 0.03 ether : 0) + (formation == 2 ? 0.02 ether : 0);

        w1.lastBattleTimestamp = block.timestamp;
        w2.lastBattleTimestamp = block.timestamp;

        emit BattleStarted(battleId, ids, mode, formation, b.battleStartTime);
        emit BattleEnded(battleId, b.winnerId, 0.05 ether + (mode == 4 ? 0.03 ether : 0) + (formation == 2 ? 0.02 ether : 0));
    }

    // Function to initiate a 3v3 team battle
    function battle3v3(uint256[3] memory waifuIds1, uint256[3] memory waifuIds2, uint8 formation) public onlyOwner(waifuIds1[0]) {
        require(formation < 3, "Invalid formation specified - must be 0, 1, or 2");
        uint256 battleId = battleCount++;
        uint256[] memory ids = new uint256[](6);
        ids[0] = waifuIds1[0];
        ids[1] = waifuIds1[1];
        ids[2] = waifuIds1[2];
        ids[3] = waifuIds2[0];
        ids[4] = waifuIds2[1];
        ids[5] = waifuIds2[2];

        battles[battleId] = Battle(ids, 5, formation, new uint256[5][](6), generateDynamicPhases(), 0, block.timestamp);
        calculateTeamBattle(battleId);
        emit BattleStarted(battleId, ids, 5, formation, battles[battleId].battleStartTime);
    }

        // Function to initiate a 10-player battle royale
    function battleRoyale(uint256[10] memory waifuIds, uint8 formation) public {
        require(formation < 3, "Invalid formation specified - must be 0, 1, or 2");
        uint256 battleId = battleCount++;
        uint256[] memory ids = new uint256[](10);
        for (uint256 i = 0; i < 10; i++) {
            ids[i] = waifuIds[i];
        }

        battles[battleId] = Battle(ids, 6, formation, new uint256[5][](10), generateDynamicPhases(), 0, block.timestamp);
        calculateTeamBattle(battleId);
        emit BattleStarted(battleId, ids, 6, formation, battles[battleId].battleStartTime);
    }

    // Function to create a new guild
    function createGuild() public payable {
        require(msg.value >= 0.5 ether, "Insufficient ETH payment for guild creation - minimum 0.5 ether required");
        uint256 id = guildCount++;
        address[] memory officers = new address[](0);
        address[] memory members = new address[](1);
        uint256[] memory alliances = new uint256[](0);
        members[0] = msg.sender;

        Guild storage g = guilds[id];
        g.id = id;
        g.leader = msg.sender;
        g.officers = officers;
        g.members = members;
        g.attackPool = msg.value / 3;
        g.defensePool = msg.value / 3;
        g.speedPool = msg.value / 3;
        g.rank = 0;
        g.missionProgress = 0;
        g.eventProgress = 0;
        g.tournamentScore = 0;
        g.alliances = alliances;
        g.lastEventTimestamp = block.timestamp;

        emit GuildCreated(id, msg.sender, block.timestamp);
    }

    // Function to add an officer to a guild
    function addGuildOfficer(uint256 guildId, address officer) public onlyGuildLeader(guildId) {
        Guild storage g = guilds[guildId];
        require(g.officers.length < 5 + g.rank, "Maximum officer limit reached for this guild rank");
        g.officers.push(officer);
        emit GuildOfficerAdded(guildId, officer, block.timestamp);
    }

    // Function to add a member to a guild
    function addGuildMember(uint256 guildId, address member) public onlyGuildLeader(guildId) {
        Guild storage g = guilds[guildId];
        require(g.members.length < 20 + (g.rank * 5), "Maximum member limit reached for this guild rank");
        g.members.push(member);
        emit GuildMemberAdded(guildId, member, block.timestamp);
    }

    // Function to form an alliance between two guilds
    function formGuildAlliance(uint256 guildId1, uint256 guildId2) public onlyGuildLeader(guildId1) {
        Guild storage g1 = guilds[guildId1];
        Guild storage g2 = guilds[guildId2];
        require(guildId1 != guildId2, "Guild cannot form alliance with itself");
        require(g1.alliances.length < 3 + g1.rank, "Maximum alliances reached for guild 1");
        require(g2.alliances.length < 3 + g2.rank, "Maximum alliances reached for guild 2");

        g1.alliances.push(guildId2);
        g2.alliances.push(guildId1);
        g1.attackPool += g2.attackPool / 10;
        g1.defensePool += g2.defensePool / 10;
        g1.speedPool += g2.speedPool / 10;
        g2.attackPool += g1.attackPool / 10;
        g2.defensePool += g1.defensePool / 10;
        g2.speedPool += g1.speedPool / 10;
        g1.diplomacy[guildId2] = 1;
        g2.diplomacy[guildId1] = 1;

        emit GuildAllianceFormed(guildId1, guildId2, block.timestamp);
        emit GuildDiplomacyUpdated(guildId1, guildId2, 1, block.timestamp);
        emit GuildDiplomacyUpdated(guildId2, guildId1, 1, block.timestamp);
    }

    // Function to update diplomacy status between two guilds
    function updateGuildDiplomacy(uint256 guildId1, uint256 guildId2, uint8 status) public onlyGuildLeader(guildId1) {
        require(status <= 3, "Invalid diplomacy status specified - must be between 0 and 3");
        Guild storage g1 = guilds[guildId1];
        Guild storage g2 = guilds[guildId2];
        require(guildId1 != guildId2, "Guild cannot set diplomacy with itself");

        g1.diplomacy[guildId2] = status;
        g2.diplomacy[guildId1] = status;
        if (status == 2) {
            g1.attackPool += g2.attackPool / 20;
            g2.attackPool += g1.attackPool / 20;
        } else if (status == 3) {
            g1.speedPool += g2.speedPool / 15;
            g2.speedPool += g1.speedPool / 15;
        }

        emit GuildDiplomacyUpdated(guildId1, guildId2, status, block.timestamp);
        emit GuildDiplomacyUpdated(guildId2, guildId1, status, block.timestamp);
    }

    // Function to add attack resources to a guild pool
    function addGuildAttack(uint256 guildId, uint256 amount) public payable onlyGuildLeader(guildId) {
        require(msg.value >= 0.1 ether, "Insufficient ETH payment for guild attack pool - minimum 0.1 ether required");
        Guild storage g = guilds[guildId];
        uint256 boost = 0;
        if (g.diplomacy[0] == 1) boost += amount / 20;
        else if (g.diplomacy[0] == 2) boost += amount / 15;
        else if (g.diplomacy[0] == 3) boost += amount / 10;
        if (g.diplomacy[1] == 1) boost += amount / 20;
        else if (g.diplomacy[1] == 2) boost += amount / 15;
        else if (g.diplomacy[1] == 3) boost += amount / 10;
        if (g.diplomacy[2] == 1) boost += amount / 20;
        else if (g.diplomacy[2] == 2) boost += amount / 15;
        else if (g.diplomacy[2] == 3) boost += amount / 10;
        g.attackPool += amount + boost;
        emit GuildResourcesAdded(guildId, 0, amount, g.attackPool);
    }

    // Function to add defense resources to a guild pool
    function addGuildDefense(uint256 guildId, uint256 amount) public payable onlyGuildLeader(guildId) {
        require(msg.value >= 0.1 ether, "Insufficient ETH payment for guild defense pool - minimum 0.1 ether required");
        Guild storage g = guilds[guildId];
        uint256 boost = 0;
        if (g.diplomacy[0] == 1) boost += amount / 20;
        else if (g.diplomacy[0] == 2) boost += amount / 15;
        else if (g.diplomacy[0] == 3) boost += amount / 10;
        if (g.diplomacy[1] == 1) boost += amount / 20;
        else if (g.diplomacy[1] == 2) boost += amount / 15;
        else if (g.diplomacy[1] == 3) boost += amount / 10;
        if (g.diplomacy[2] == 1) boost += amount / 20;
        else if (g.diplomacy[2] == 2) boost += amount / 15;
        else if (g.diplomacy[2] == 3) boost += amount / 10;
        g.defensePool += amount + boost;
        emit GuildResourcesAdded(guildId, 1, amount, g.defensePool);
    }

    // Function to add speed resources to a guild pool
    function addGuildSpeed(uint256 guildId, uint256 amount) public payable onlyGuildLeader(guildId) {
        require(msg.value >= 0.1 ether, "Insufficient ETH payment for guild speed pool - minimum 0.1 ether required");
        Guild storage g = guilds[guildId];
        uint256 boost = 0;
        if (g.diplomacy[0] == 1) boost += amount / 20;
        else if (g.diplomacy[0] == 2) boost += amount / 15;
        else if (g.diplomacy[0] == 3) boost += amount / 10;
        if (g.diplomacy[1] == 1) boost += amount / 20;
        else if (g.diplomacy[1] == 2) boost += amount / 15;
        else if (g.diplomacy[1] == 3) boost += amount / 10;
        if (g.diplomacy[2] == 1) boost += amount / 20;
        else if (g.diplomacy[2] == 2) boost += amount / 15;
        else if (g.diplomacy[2] == 3) boost += amount / 10;
        g.speedPool += amount + boost;
        emit GuildResourcesAdded(guildId, 2, amount, g.speedPool);
    }

    // Function to progress a guild's mission
    function progressGuildMission(uint256 guildId) public onlyGuildLeader(guildId) {
        Guild storage g = guilds[guildId];
        require(g.missionProgress < 1000 * (g.rank + 1), "Guild mission already completed for this rank");
        uint256 progress = 0;
        if (g.attackPool > 1000) progress += g.attackPool / 100;
        if (g.defensePool > 1000) progress += g.defensePool / 100;
        if (g.speedPool > 1000) progress += g.speedPool / 100;
        if (g.alliances.length > 0) progress += g.alliances.length * 50;
        g.missionProgress += progress;

        emit GuildMissionProgressed(guildId, g.missionProgress, block.timestamp);
        if (g.missionProgress >= 1000 * (g.rank + 1) && g.rank < 4) {
            g.rank += 1;
            g.missionProgress = 0;
            emit GuildRankUpgraded(guildId, g.rank, block.timestamp);
        }
    }

    // Function to progress a guild's event
    function progressGuildEvent(uint256 guildId) public onlyGuildLeader(guildId) {
        Guild storage g = guilds[guildId];
        require(block.timestamp > g.lastEventTimestamp + 1 days, "Guild event still on cooldown - wait 24 hours");
        g.eventProgress += g.members.length * 10 + g.officers.length * 20 + g.attackPool / 200 + g.defensePool / 200 + g.speedPool / 200;
        g.lastEventTimestamp = block.timestamp;
        emit GuildEventProgressed(guildId, g.eventProgress, block.timestamp);
    }

    // Function to progress a guild's tournament by battling another guild
    function progressGuildTournament(uint256 guildId1, uint256 guildId2) public onlyGuildLeader(guildId1) {
        Guild storage g1 = guilds[guildId1];
        Guild storage g2 = guilds[guildId2];
        require(guildId1 != guildId2, "Guild cannot battle itself in tournament");

        uint256 score1 = g1.attackPool + g1.defensePool + g1.speedPool + g1.members.length * 50 + g1.officers.length * 100;
        uint256 score2 = g2.attackPool + g2.defensePool + g2.speedPool + g2.members.length * 50 + g2.officers.length * 100;
        if (g1.diplomacy[guildId2] == 3) score1 += score1 / 10;
        if (g2.diplomacy[guildId1] == 3) score2 += score2 / 10;

        if (score1 > score2) {
            g1.tournamentScore += 100 + (g1.rank * 50);
            rewards[g1.leader] += 0.5 ether;
            emit GuildBattle(guildId1, guildId2, guildId1, block.timestamp);
        } else {
            g2.tournamentScore += 100 + (g2.rank * 50);
            rewards[g2.leader] += 0.5 ether;
            emit GuildBattle(guildId1, guildId2, guildId2, block.timestamp);
        }
        emit GuildTournamentProgressed(guildId1, g1.tournamentScore, block.timestamp);
        emit GuildTournamentProgressed(guildId2, g2.tournamentScore, block.timestamp);
    }

    // Function to activate Super Saiyan mode for an aggressive waifu
    function activateAggressiveSaiyan(uint256 waifuId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        SuperSaiyan storage ss = waifuSuperSaiyans[waifuId];
        require(w.personality == 0, "Waifu must have aggressive personality for this mode");
        require(!ss.isActive, "Super Saiyan mode already active");
        require(block.timestamp > ss.cooldown, "Super Saiyan mode still on cooldown");

        ss.isActive = true;
        ss.mode = 1;
        ss.powerBoost = w.attack * 2 + w.tier * 50 + w.traits[0] * 10 + (w.trainingCount / 5);
        ss.duration = block.timestamp + 1 hours;
        ss.cooldown = ss.duration + 1 days;
        w.attack += ss.powerBoost;
        emit SuperSaiyanActivated(waifuId, 1, ss.powerBoost, ss.duration, block.timestamp);
    }

    // Function to activate Super Saiyan mode for a calm waifu
    function activateCalmSaiyan(uint256 waifuId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        SuperSaiyan storage ss = waifuSuperSaiyans[waifuId];
        require(w.personality == 1, "Waifu must have calm personality for this mode");
        require(!ss.isActive, "Super Saiyan mode already active");
        require(block.timestamp > ss.cooldown, "Super Saiyan mode still on cooldown");

        ss.isActive = true;
        ss.mode = 2;
        ss.powerBoost = w.defense * 2 + w.tier * 40 + w.traits[1] * 8 + (w.trainingCount / 5);
        ss.duration = block.timestamp + 2 hours;
        ss.cooldown = ss.duration + 1 days;
        w.defense += ss.powerBoost;
        emit SuperSaiyanActivated(waifuId, 2, ss.powerBoost, ss.duration, block.timestamp);
    }

    // Function to activate Super Saiyan mode for a cunning waifu
    function activateCunningSaiyan(uint256 waifuId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        SuperSaiyan storage ss = waifuSuperSaiyans[waifuId];
        require(w.personality == 2, "Waifu must have cunning personality for this mode");
        require(!ss.isActive, "Super Saiyan mode already active");
        require(block.timestamp > ss.cooldown, "Super Saiyan mode still on cooldown");

        ss.isActive = true;
        ss.mode = 3;
        ss.powerBoost = w.speed * 2 + w.tier * 30 + w.traits[2] * 6 + (w.trainingCount / 5);
        ss.duration = block.timestamp + 45 minutes;
        ss.cooldown = ss.duration + 1 days;
        w.speed += ss.powerBoost;
        emit SuperSaiyanActivated(waifuId, 3, ss.powerBoost, ss.duration, block.timestamp);
    }

    // Function to activate Super Saiyan mode for a loyal waifu
    function activateLoyalSaiyan(uint256 waifuId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        SuperSaiyan storage ss = waifuSuperSaiyans[waifuId];
        require(w.personality == 3, "Waifu must have loyal personality for this mode");
        require(!ss.isActive, "Super Saiyan mode already active");
        require(block.timestamp > ss.cooldown, "Super Saiyan mode still on cooldown");

        ss.isActive = true;
        ss.mode = 4;
        ss.powerBoost = w.hp * 2 + w.tier * 60 + w.traits[0] * 12 + (w.trainingCount / 5);
        ss.duration = block.timestamp + 90 minutes;
        ss.cooldown = ss.duration + 1 days;
        w.hp += ss.powerBoost;
        emit SuperSaiyanActivated(waifuId, 4, ss.powerBoost, ss.duration, block.timestamp);
    }

    // Function to activate Super Saiyan mode for a chaotic waifu
    function activateChaoticSaiyan(uint256 waifuId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        SuperSaiyan storage ss = waifuSuperSaiyans[waifuId];
        require(w.personality == 4, "Waifu must have chaotic personality for this mode");
        require(!ss.isActive, "Super Saiyan mode already active");
        require(block.timestamp > ss.cooldown, "Super Saiyan mode still on cooldown");

        ss.isActive = true;
        ss.mode = 5;
        ss.powerBoost = w.stamina * 2 + w.tier * 45 + w.traits[2] * 9 + (w.trainingCount / 5);
        ss.duration = block.timestamp + 1 hours;
        ss.cooldown = ss.duration + 1 days;
        w.stamina += ss.powerBoost;
        emit SuperSaiyanActivated(waifuId, 5, ss.powerBoost, ss.duration, block.timestamp);
    }

    // Function to deactivate Super Saiyan mode
    function deactivateSuperSaiyan(uint256 waifuId) public onlyOwner(waifuId) {
        Waifu storage w = waifus[waifuId];
        SuperSaiyan storage ss = waifuSuperSaiyans[waifuId];
        require(ss.isActive, "Super Saiyan mode not active");
        require(block.timestamp >= ss.duration, "Super Saiyan mode duration not yet expired");

        ss.isActive = false;
        if (ss.mode == 1) w.attack -= ss.powerBoost;
        else if (ss.mode == 2) w.defense -= ss.powerBoost;
        else if (ss.mode == 3) w.speed -= ss.powerBoost;
        else if (ss.mode == 4) w.hp -= ss.powerBoost;
        else if (ss.mode == 5) w.stamina -= ss.powerBoost;
        emit SuperSaiyanDeactivated(waifuId, block.timestamp);
    }

    // Function to summon a Mecha Boss for a guild
    function summonMechaBoss(uint256 guildId) public payable onlyGuildLeader(guildId) {
        Guild storage g = guilds[guildId];
        require(msg.value >= 1 ether, "Insufficient ETH payment for mecha boss summon - minimum 1 ether required");
        uint256 id = mechaBossCount++;

        guildMechaBosses[id] = MechaBoss({
            guildId: guildId,
            attack: g.attackPool / 2 + g.rank * 100 + (g.tournamentScore / 10),
            defense: g.defensePool / 2 + g.rank * 80 + (g.tournamentScore / 15),
            speed: g.speedPool / 2 + g.rank * 60 + (g.tournamentScore / 20),
            hp: g.attackPool + g.defensePool + g.rank * 200,
            summonCost: msg.value,
            lastBattle: block.timestamp,
            isActive: true
        });

        g.attackPool /= 2;
        g.defensePool /= 2;
        g.speedPool /= 2;
        emit MechaBossSummoned(guildId, id, guildMechaBosses[id].attack, guildMechaBosses[id].defense, guildMechaBosses[id].speed, block.timestamp);
    }

    // Function to battle two Mecha Bosses
    function battleMechaBoss(uint256 mechaId1, uint256 mechaId2) public {
        MechaBoss storage m1 = guildMechaBosses[mechaId1];
        MechaBoss storage m2 = guildMechaBosses[mechaId2];
        require(m1.isActive && m2.isActive, "One or both mecha bosses are not active");
        require(m1.guildId != m2.guildId, "Mecha bosses from the same guild cannot battle");

        uint256 score1 = m1.attack * 2 + m1.defense * 3 + m1.speed * 4 + m1.hp / 10;
        uint256 score2 = m2.attack * 2 + m2.defense * 3 + m2.speed * 4 + m2.hp / 10;
        uint256 winnerId = score1 > score2 ? mechaId1 : mechaId2;

        if (winnerId == mechaId1) {
            m2.isActive = false;
            rewards[guilds[m1.guildId].leader] += m2.summonCost / 2;
            guilds[m1.guildId].tournamentScore += 200;
        } else {
            m1.isActive = false;
            rewards[guilds[m2.guildId].leader] += m1.summonCost / 2;
            guilds[m2.guildId].tournamentScore += 200;
        }

        m1.lastBattle = block.timestamp;
        m2.lastBattle = block.timestamp;
        emit MechaBossBattle(mechaId1, mechaId2, winnerId, block.timestamp);
    }

    // Function to create a marketplace listing for a waifu
    function createWaifuListing(uint256 waifuId, uint256 price, uint256 duration) public onlyOwner(waifuId) {
        require(price > 0, "Price must be greater than 0");
        uint256 listingId = listingCount++;
        listings[listingId] = Listing({
            id: listingId,
            listingType: 0,
            assetId: waifuId,
            price: price,
            seller: msg.sender,
            highestBidder: address(0),
            highestBid: 0,
            deadline: block.timestamp + duration
        });
        emit ListingCreated(listingId, 0, waifuId, price, listings[listingId].deadline);
    }

    // Function to create a marketplace listing for an item
    function createItemListing(uint256 itemId, uint256 price, uint256 duration) public {
        uint256 listingId = listingCount++;
        listings[listingId] = Listing({
            id: listingId,
            listingType: 1,
            assetId: itemId,
            price: price,
            seller: msg.sender,
            highestBidder: address(0),
            highestBid: 0,
            deadline: block.timestamp + duration
        });
        emit ListingCreated(listingId, 1, itemId, price, listings[listingId].deadline);
    }

    // Function to place a bid on a marketplace listing
    function bidOnListing(uint256 listingId) public payable {
        Listing storage l = listings[listingId];
        require(block.timestamp < l.deadline, "Listing has expired - bidding closed");
        require(msg.value > l.highestBid, "Bid must exceed current highest bid");
        require(msg.value >= l.price / 10, "Bid must be at least 10% of listing price");

        if (l.highestBidder != address(0)) {
            payable(l.highestBidder).transfer(l.highestBid);
        }
        l.highestBidder = msg.sender;
        l.highestBid = msg.value;
        emit ListingBid(listingId, msg.sender, msg.value, block.timestamp);
    }

    // Function to purchase a marketplace listing outright
    function buyListing(uint256 listingId) public payable {
        Listing storage l = listings[listingId];
        require(block.timestamp < l.deadline, "Listing has expired - purchase not possible");
        require(msg.value >= l.price, "Insufficient ETH sent - must meet or exceed listing price");

        if (l.highestBidder != address(0)) {
            payable(l.highestBidder).transfer(l.highestBid);
        }
        payable(l.seller).transfer(msg.value);

        if (l.listingType == 0) {
            waifus[l.assetId].owner = msg.sender;
        } else {
            items[l.assetId] = items[l.assetId];
        }
        delete listings[listingId];
        emit ListingPurchased(listingId, msg.sender, block.timestamp);
    }

    // Function to claim accumulated rewards
    function claimRewards() public {
        uint256 amount = rewards[msg.sender];
        require(amount > 0, "No rewards available to claim");
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RewardClaimed(msg.sender, amount, block.timestamp);
    }

    // Function to withdraw all contract balance
    function withdraw() public onlyContractOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available to withdraw");
        payable(owner).transfer(balance);
    }

    // Internal function to apply modifiers for attackers during battle
    function applyModifiersAttacker(Waifu storage w, Waifu storage opponent, uint8 skillIndex) internal {
        Skill storage s = waifuSkills[w.id][skillIndex];
        if (s.modifierType == 1 && w.cooldowns[skillIndex] == 0) {
            opponent.modifiers[0] = 3 + (w.personality == 0 ? 1 : 0);
            emit ModifierApplied(opponent.id, 0, opponent.modifiers[0], block.timestamp);
        }
        if (w.modifiers[0] > 0) w.hp -= 5 + (w.personality == 4 ? 2 : 0);
        if (w.modifiers[1] > 0) w.hp += 10;
        if (w.modifiers[0] > 0) w.modifiers[0]--;
        if (w.modifiers[1] > 0) w.modifiers[1]--;
        if (w.modifiers[2] > 0) w.modifiers[2]--;
        w.cooldowns[skillIndex] = w.cooldowns[skillIndex] > 0 ? w.cooldowns[skillIndex] - 1 : s.baseCooldown;
    }

    // Internal function to apply modifiers for defenders during battle
    function applyModifiersDefender(Waifu storage w, Waifu storage opponent, uint8 skillIndex) internal {
        Skill storage s = waifuSkills[w.id][skillIndex];
        if (s.modifierType == 2 && w.cooldowns[skillIndex] == 0) {
            w.modifiers[1] = 4 + (w.personality == 1 ? 1 : 0);
            emit ModifierApplied(w.id, 1, w.modifiers[1], block.timestamp);
        }
        if (w.modifiers[0] > 0) w.hp -= 5;
        if (w.modifiers[1] > 0) w.hp += 10 + (w.personality == 1 ? 3 : 0);
        if (w.modifiers[0] > 0) w.modifiers[0]--;
        if (w.modifiers[1] > 0) w.modifiers[1]--;
        if (w.modifiers[2] > 0) w.modifiers[2]--;
        w.cooldowns[skillIndex] = w.cooldowns[skillIndex] > 0 ? w.cooldowns[skillIndex] - 1 : s.baseCooldown;
    }

    // Internal function to apply modifiers for supports during battle
    function applyModifiersSupport(Waifu storage w, Waifu storage opponent, uint8 skillIndex) internal {
        Skill storage s = waifuSkills[w.id][skillIndex];
        if (s.modifierType == 3 && w.cooldowns[skillIndex] == 0) {
            opponent.modifiers[2] = 2 + (w.personality == 2 ? 1 : 0);
            emit ModifierApplied(opponent.id, 2, opponent.modifiers[2], block.timestamp);
        }
        if (w.modifiers[0] > 0) w.hp -= 5;
        if (w.modifiers[1] > 0) w.hp += 10;
        if (w.modifiers[2] > 0) w.speed -= 5 + (w.personality == 2 ? 2 : 0);
        if (w.modifiers[0] > 0) w.modifiers[0]--;
        if (w.modifiers[1] > 0) w.modifiers[1]--;
        if (w.modifiers[2] > 0) w.modifiers[2]--;
        w.cooldowns[skillIndex] = w.cooldowns[skillIndex] > 0 ? w.cooldowns[skillIndex] - 1 : s.baseCooldown;
    }

    // Internal function to apply modifiers for healers during battle
    function applyModifiersHealer(Waifu storage w, Waifu storage opponent, uint8 skillIndex) internal {
        Skill storage s = waifuSkills[w.id][skillIndex];
        if (s.modifierType == 2 && w.cooldowns[skillIndex] == 0) {
            w.modifiers[1] = 5 + (w.personality == 3 ? 1 : 0);
            emit ModifierApplied(w.id, 1, w.modifiers[1], block.timestamp);
        }
        if (w.modifiers[0] > 0) w.hp -= 5;
        if (w.modifiers[1] > 0) w.hp += 15 + (w.personality == 3 ? 5 : 0);
        if (w.modifiers[2] > 0) w.hp -= 3;
        if (w.modifiers[0] > 0) w.modifiers[0]--;
        if (w.modifiers[1] > 0) w.modifiers[1]--;
        if (w.modifiers[2] > 0) w.modifiers[2]--;
        w.cooldowns[skillIndex] = w.cooldowns[skillIndex] > 0 ? w.cooldowns[skillIndex] - 1 : s.baseCooldown;
    }

    // Internal function to apply modifiers for tacticians during battle
    function applyModifiersTactician(Waifu storage w, Waifu storage opponent, uint8 skillIndex) internal {
        Skill storage s = waifuSkills[w.id][skillIndex];
        if (s.modifierType == 1 && w.cooldowns[skillIndex] == 0) {
            opponent.modifiers[0] = 3 + (w.personality == 4 ? 1 : 0);
            emit ModifierApplied(opponent.id, 0, opponent.modifiers[0], block.timestamp);
        }
        if (w.modifiers[0] > 0) w.hp -= 5 + (w.personality == 4 ? 3 : 0);
        if (w.modifiers[1] > 0) w.hp += 10;
        if (w.modifiers[2] > 0) w.stamina -= 5;
        if (w.modifiers[0] > 0) w.modifiers[0]--;
        if (w.modifiers[1] > 0) w.modifiers[1]--;
        if (w.modifiers[2] > 0) w.modifiers[2]--;
        w.cooldowns[skillIndex] = w.cooldowns[skillIndex] > 0 ? w.cooldowns[skillIndex] - 1 : s.baseCooldown;
    }

    // Helper function to generate random battle phase types
    function generateDynamicPhases() internal view returns (uint8[5] memory) {
        uint8[5] memory phases;
        phases[0] = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, uint256(0)))) % 5);
        phases[1] = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, uint256(1)))) % 5);
        phases[2] = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, uint256(2)))) % 5);
        phases[3] = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, uint256(3)))) % 5);
        phases[4] = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, uint256(4)))) % 5);
        return phases;
    }

    // Helper function to calculate synergy bonuses between two waifus
    function calculateSynergyBonus(Waifu storage w1, Waifu storage w2) internal view returns (uint256) {
        uint256 bonus = 0;
        if (w1.role == 0 && w2.role == 2) bonus += 20 + (w1.personality == 0 ? 5 : 0);
        else if (w1.role == 1 && w2.role == 3) bonus += 15 + (w1.personality == 1 ? 4 : 0);
        else if (w1.role == 2 && w2.role == 4) bonus += 18 + (w1.personality == 2 ? 3 : 0);
        else if (w1.role == 3 && w2.role == 0) bonus += 12 + (w1.personality == 3 ? 6 : 0);
        else if (w1.role == 4 && w2.role == 1) bonus += 25 + (w1.personality == 4 ? 7 : 0);
        
        bonus += (personalityRoleSynergy[w1.personality][w1.role] * w1.trainingCount) / 100;
        bonus += (personalityRoleSynergy[w2.personality][w2.role] * w2.trainingCount) / 100;
        
        if (w1.personality == w2.personality) bonus += 10 + (w1.trainingCount > 5 ? 5 : 0) + (w2.trainingCount > 5 ? 5 : 0);
        if (w1.isFused && w2.isFused) bonus += 30 + (w1.battleHistory[0] > 0 ? w1.battleHistory[0] / 100 : 0);
        if (w1.tier == w2.tier && w1.tier > 2) bonus += 15 + (w1.itemTypeBoosts[0] / 10);
        if (w1.items.length > 0 && w2.items.length > 0) bonus += (w1.items.length + w2.items.length) * 3 + w1.itemTypeBoosts[1];
        if (block.timestamp - w1.lastBattleTimestamp < 1 hours) bonus += 10 + (w1.lastRestTimestamp > w1.lastBattleTimestamp ? 5 : 0);
        if (block.timestamp - w2.lastBattleTimestamp < 1 hours) bonus += 10 + (w2.lastRestTimestamp > w2.lastBattleTimestamp ? 5 : 0);
        
        return bonus;
    }

    // Helper function to calculate total score for a waifu in a battle
    function calculateTotalScore(uint256[5][] storage phaseScores, uint256 index, Waifu storage w) internal view returns (uint256) {
        uint256 total = 0;
        total += phaseScores[0][index] + (w.personality == 0 ? 10 : 0);
        total += phaseScores[1][index] + (w.personality == 1 ? 8 : 0);
        total += phaseScores[2][index] + (w.personality == 2 ? 12 : 0);
        total += phaseScores[3][index] + (w.personality == 3 ? 15 : 0);
        total += phaseScores[4][index] + (w.personality == 4 ? 20 : 0);
        for (uint256 i = 0; i < w.items.length; i++) {
            total += items[w.items[i]].value + (items[w.items[i]].enchantment * 5);
        }
        return total;
    }

    // Internal function to calculate team battle outcomes
    function calculateTeamBattle(uint256 battleId) internal {
        Battle storage b = battles[battleId];
        uint256 team1Score = 0;
        uint256 team2Score = 0;
        uint256 participantCount = b.waifuIds.length;
        uint256 teamSize = participantCount / 2;

        for (uint8 i = 0; i < 5; i++) {
            for (uint256 j = 0; j < participantCount; j++) {
                Waifu storage w = waifus[b.waifuIds[j]];
                uint256 synergyBonus = 0;
                uint256 formationBonus = b.formation == 0 ? 15 : b.formation == 1 ? 5 : 10;

                if (b.phaseTypes[i] == 0) {
                    b.phaseScores[j][i] = w.cooldowns[0] > 0 ? w.attack * 2 : w.attack * 4 + waifuSkills[w.id][0].power * w.traits[0] + synergyBonus + formationBonus;
                    if (w.role == 0 && j < teamSize) applyModifiersAttacker(w, waifus[b.waifuIds[j + teamSize]], 0);
                    else if (w.role == 0 && j >= teamSize) applyModifiersAttacker(w, waifus[b.waifuIds[j - teamSize]], 0);
                } else if (b.phaseTypes[i] == 1) {
                    b.phaseScores[j][i] = w.cooldowns[1] > 0 ? w.defense * 3 : w.defense * 5 + waifuSkills[w.id][1].power * w.traits[1] + synergyBonus + formationBonus;
                    if (w.role == 1 && j < teamSize) applyModifiersDefender(w, waifus[b.waifuIds[j + teamSize]], 1);
                    else if (w.role == 1 && j >= teamSize) applyModifiersDefender(w, waifus[b.waifuIds[j - teamSize]], 1);
                } else if (b.phaseTypes[i] == 2) {
                    b.phaseScores[j][i] = w.cooldowns[2] > 0 || w.modifiers[2] > 0 ? w.speed * 2 : w.speed * 3 + waifuSkills[w.id][2].power * w.traits[2] + synergyBonus + formationBonus;
                    if (w.role == 2 && j < teamSize) applyModifiersSupport(w, waifus[b.waifuIds[j + teamSize]], 2);
                    else if (w.role == 2 && j >= teamSize) applyModifiersSupport(w, waifus[b.waifuIds[j - teamSize]], 2);
                } else if (b.phaseTypes[i] == 3) {
                    b.phaseScores[j][i] = w.hp * 2 + w.stamina * w.traits[0] + synergyBonus + formationBonus;
                    if (w.role == 3 && j < teamSize) applyModifiersHealer(w, waifus[b.waifuIds[j + teamSize]], 0);
                    else if (w.role == 3 && j >= teamSize) applyModifiersHealer(w, waifus[b.waifuIds[j - teamSize]], 0);
                } else {
                    b.phaseScores[j][i] = w.stamina * 2 + w.traits[2] * 3 + synergyBonus + formationBonus;
                    if (w.role == 4 && j < teamSize) applyModifiersTactician(w, waifus[b.waifuIds[j + teamSize]], 1);
                    else if (w.role == 4 && j >= teamSize) applyModifiersTactician(w, waifus[b.waifuIds[j - teamSize]], 1);
                }
                if (w.personality == 4) b.phaseScores[j][i] += uint256(keccak256(abi.encodePacked(battleId, i))) % 20;
            }

            for (uint256 j = 0; j < teamSize; j++) {
                team1Score += b.phaseScores[j][i];
                team2Score += b.phaseScores[j + teamSize][i];
                progressQuest(waifus[b.waifuIds[j]], i % 5);
                progressQuest(waifus[b.waifuIds[j + teamSize]], i % 5);
            }

            uint256[5] memory phaseScoresSlice;
            for (uint256 j = 0; j < 5 && j < participantCount; j++) {
                phaseScoresSlice[j] = b.phaseScores[j][i];
            }
            emit BattlePhaseScored(battleId, i, phaseScoresSlice, block.timestamp);
        }

        b.winnerId = team1Score > team2Score ? b.waifuIds[0] : b.waifuIds[teamSize];
        rewards[waifus[b.winnerId].owner] += 0.1 ether + (b.formation == 2 ? 0.05 ether : 0);
        emit BattleEnded(battleId, b.winnerId, 0.1 ether + (b.formation == 2 ? 0.05 ether : 0));
    }

    // Internal function to progress a waifu's quest
    function progressQuest(Waifu storage w, uint8 questType) internal {
        require(questType < 5, "Invalid quest type specified - must be between 0 and 4");
        uint256 multiplier = questRoleMultipliers[w.role][questType];
        uint256 progress = (10 + (w.tier * 5) + (w.role == questType ? 15 : 0) + (w.personality == questType ? 10 : 0)) * multiplier / 100;
        if (w.personality == 4) progress += uint256(keccak256(abi.encodePacked(w.id, block.timestamp, w.trainingCount))) % 25;
        if (w.isFused) progress += 20;
        if (w.items.length > 0) progress += w.items.length * 5;
        w.questProgress[questType] += progress;
        emit QuestProgressed(w.id, questType, w.questProgress[questType], block.timestamp);

        if (w.questProgress[questType] >= 100 * (w.tier + 1)) {
            w.questProgress[questType] = 0;
            uint256 reward = 0.1 ether * (w.tier + 1) + (w.personality == 3 ? 0.05 ether : 0) + (w.trainingCount > 10 ? 0.02 ether : 0);
            rewards[w.owner] += reward;
            emit QuestCompleted(w.id, questType, reward);
        }
    }

    // Internal function to check and trigger waifu evolution
    function checkEvolution(uint256 waifuId) internal {
        Waifu storage w = waifus[waifuId];
        uint256 expThreshold = 0;
        if (w.tier == 0) expThreshold = 50 + (w.role * 15) + (w.traits[0] * 5);
        else if (w.tier == 1) expThreshold = 100 + (w.role * 20) + (w.traits[0] * 10);
        else if (w.tier == 2) expThreshold = 150 + (w.role * 25) + (w.traits[0] * 15);
        else if (w.tier == 3) expThreshold = 200 + (w.role * 30) + (w.traits[0] * 20);
        else return;

        if (w.exp >= expThreshold && w.tier < 4) {
            w.tier += 1;
            w.attack += 12 + (w.role == 0 ? 8 : 0) + w.traits[0] + (w.personality == 0 ? 5 : 0);
            w.defense += 10 + (w.role == 1 ? 6 : 0) + w.traits[1] + (w.personality == 1 ? 4 : 0);
            w.speed += 8 + (w.role == 2 ? 5 : 0) + w.traits[2] + (w.personality == 2 ? 3 : 0);
            w.hp += 25 + (w.role == 3 ? 10 : 0) + (w.personality == 3 ? 7 : 0);
            w.stamina += 15 + (w.role == 4 ? 7 : 0) + (w.personality == 4 ? 6 : 0);
            w.exp = 0;
            emit WaifuEvolved(waifuId, w.tier, block.timestamp);
        }
    }

    // Fallback function to accept ETH
    receive() external payable {}
}
