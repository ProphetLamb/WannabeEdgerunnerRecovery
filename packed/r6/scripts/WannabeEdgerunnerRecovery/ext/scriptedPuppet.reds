module Edgerunning.System

import Logging.*

@wrapMethod(ScriptedPuppet)
protected func RewardKiller(killer: wref<GameObject>, killType: gameKillType, isAnyDamageNonlethal: Bool) -> Void {
  wrappedMethod(killer, killType, isAnyDamageNonlethal);

  let record: ref<Character_Record> = this.GetRecord();
  let affiliation: gamedataAffiliation = record.Affiliation().Type();
  let type: ENeutralizeType;

  if !IsDefined(killer as PlayerPuppet) {
    return;
  }
  // Knockout is a defeat, that didn't kill the target
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

  if !Equals(type, ENeutralizeType.Killed) && Equals(this.GetNPCType(), gamedataNPCType.Human) {
    EdgerunningRecoverySystem.GetInstance(this.GetGame()).OnEnemyKnockout(affiliation);
  };
}
