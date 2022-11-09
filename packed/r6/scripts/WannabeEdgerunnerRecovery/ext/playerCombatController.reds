module Edgerunning.System

import Logging.LTrace

@wrapMethod(PlayerCombatController)
public final func OnInvalidateActiveState(evt: ref<PlayerCombatControllerInvalidateEvent>) -> Void {
    LTrace("OnInvalidateActiveState");
    let stateOld = this.m_otherVars.m_state;
    let stateNew = evt.m_state;
    wrappedMethod(evt);

    if !Equals(stateOld, stateNew) {
        return;
    }
    let player = this.m_owner as PlayerPuppet;
    // ignore if not player or jonny
    if !IsDefined(player) || player.IsPossessedE() {
        return;
    }
    let system = EdgerunningRecoverySystem.GetInstance(player.GetGame());
    system.OnPlayerCombatStateChanged(stateNew);
}
