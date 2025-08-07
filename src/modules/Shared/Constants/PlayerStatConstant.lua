local PlayerStatConstant = {}

PlayerStatConstant.ModuleName = "PlayerStatConstant"

PlayerStatConstant.BasicStats = {
    HP = 100,
    AttackDamage = 10,
    SkillDamage = 20,
    Defense = 30,

    Level = 1,
    EXP = 0,
    MaxEXP = 100,
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