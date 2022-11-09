module Edgerunning.System

import Logging.LDebug

@wrapMethod(ScriptedPuppet)
protected func RewardKiller(killer: wref<GameObject>, killType: gameKillType, isAnyDamageNonlethal: Bool) -> Void {
  wrappedMethod(killer, killType, isAnyDamageNonlethal);

  let record: ref<Character_Record> = this.GetRecord();
  let affiliation: gamedataAffiliation = record.Affiliation().Type();
  let type: ENeutralizeType;

  if !IsDefined(killer as PlayerPuppet) {
    return;
  }
  if Equals(killType, gameKillType.Defeat) || this.m_forceDefeatReward {
    if isAnyDamageNonlethal {
      type = ENeutralizeType.Unconscious;
    } else {
      type = ENeutralizeType.Defeated;
    };
  } else {
    type = ENeutralizeType.Killed;
  };

  LDebug(s"Reward killer: target = \(affiliation), killType = \(killType), neutralizeType = \(type), NPC type = \(this.GetNPCType())");

  if Equals(type, ENeutralizeType.Unconscious) && Equals(this.GetNPCType(), gamedataNPCType.Human) {
    EdgerunningRecoverySystem.GetInstance(this.GetGame()).OnEnemyUnconscious(affiliation);
  };
}
