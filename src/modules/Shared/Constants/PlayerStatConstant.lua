local PlayerStatConstant = {}

PlayerStatConstant.ModuleName = "PlayerStatConstant"

PlayerStatConstant.BasicStats = {
    HP = 100,
    AttackDamage = 10,
    SkillDamage = 10,
    Defense = 10,

    Level = 1,
    XP = 0,
    MaxXP = 100,
}

PlayerStatConstant.AdvancedStats = {
    CriticalAttackChance = 0,
    CriticalAttackDamage = 0,
    CounterAttackChance = 0,
}

function PlayerStatConstant.GetDefaultStats(player)
    return {
        BasicStats = PlayerStatConstant.BasicStats,
        AdvancedStats = PlayerStatConstant.AdvancedStats,
    }
end

return PlayerStatConstant