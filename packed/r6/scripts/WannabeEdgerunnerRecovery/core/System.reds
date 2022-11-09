module Edgerunning.System

import Edgerunning.Logging.*

public class EdgerunningRecoverySystem extends ScriptableSystem {
  // ------------------------------------------
  // Fields
  // ------------------------------------------
  // Systems
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;
  private let edgerunningSystem: ref<EdgerunningSystem>;
  // Events
  private let recoverHumanityDelayId: DelayID;

  // The mod config
  private let config: ref<EdgerunnerRecoveryConfig>;
  // The player
  private let player: wref<PlayerPuppet>;
  // The `GameTime` of the last `LaunchCycledRecoverHumanityRequest`
  private persistent let recoveryTsSec: Float = 0;
  // Tracks the remainder of (integer) humanity recovery
  private persistent let recoveryRem: Float = 0;

  // ------------------------------------------
  // Event & Request handlers
  // ------------------------------------------
  private func OnAttach() -> Void {
    LTrace("OnAttach");
    ModSettings.RegisterListenerToModifications(this);
  }

  private func OnDetach() -> Void {
    LTrace("OnDetach");
    ModSettings.UnregisterListenerToModifications(this);
    this.StopRecoverHumanity();
  }

  public func OnModSettingsChange() -> Void {
    LTrace("OnModSettingsChange");
    this.RefreshConfig();
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    LTrace("OnPlayerAttach");
    this.LoadPlayer(request.owner.GetGame());
    this.RefreshConfig();
    this.StopRecoverHumanity();
    this.StartRecoverHumanity();
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    LTrace("OnPlayerDetach");
    this.StopRecoverHumanity();
  }

  // The cycle for recovering humanity has elapsed
  private final func OnLaunchCycledRecoverHumanityRequest(request: ref<LaunchCycledRecoverHumanityRequest>) -> Void {
    LTrace("OnLaunchCycledRecoverHumanityRequest");
    this.RecoverHumanity();
  }

  // ------------------------------------------
  // Core logic: ScriptableSystem
  // ------------------------------------------
  public final static func GetInstance(gameInstance: GameInstance) -> ref<EdgerunningRecoverySystem> {
    let system: ref<EdgerunningRecoverySystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Edgerunning.System.EdgerunningRecoverySystem") as EdgerunningRecoverySystem;
    return system;
  }

  private func LoadPlayer(gameInstance: GameInstance) {
    this.player = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject() as PlayerPuppet;
    LErrorIfUndef(this.player, n"PlayerPuppet");
    this.delaySystem = GameInstance.GetDelaySystem(gameInstance);
    LErrorIfUndef(this.delaySystem, n"DelaySystem");
    this.timeSystem = GameInstance.GetTimeSystem(gameInstance);
    LErrorIfUndef(this.timeSystem, n"TimeSystem");
    this.edgerunningSystem = EdgerunningSystem.GetInstance(gameInstance);
    LErrorIfUndef(this.edgerunningSystem, n"EdgerunningSystem");
  }

  public func RefreshConfig() -> Void {
    this.config = new EdgerunnerRecoveryConfig();
  }

  // ------------------------------------------
  // Interop logic: EdgerunningSystem
  // ------------------------------------------
  /// Decreases damage to humanity by the amount specified
  /// Updates the humanity
  private final func DecHumanityDmg(amount: Int32) {
    let humanityDmgPrevious = this.edgerunningSystem.currentHumanityDamage;
    let humanityDmg = Max(0, humanityDmgPrevious - amount);
    LInfo(s"Recovering \(amount) humanity, from \(humanityDmgPrevious) to \(humanityDmg)");
    if (humanityDmg == humanityDmgPrevious) {
      return;
    }
    // Decrement the humanity damage
    this.edgerunningSystem.currentHumanityDamage = humanityDmg;
    this.edgerunningSystem.InvalidateCurrentState();
  }

  // ------------------------------------------
  // Core logic: Recover humanity
  // ------------------------------------------

  public func IsRecoveringHumanity() -> Bool {
    let invalidDelayId: DelayID;
    return this.recoverHumanityDelayId != invalidDelayId;
  }

  public func StartRecoverHumanity() {
    this.RecoverHumanity();
  }

  public func StopRecoverHumanity() {
    let invalidDelayId: DelayID;
    // Chceck if DelayID was invalid
    if this.recoverHumanityDelayId != invalidDelayId {
      this.delaySystem.CancelDelay(this.recoverHumanityDelayId);
    }
    // Assign invalid DelayID
    this.recoverHumanityDelayId = invalidDelayId;
  }

  /// Recovers humanity according to the equipped Cyberware, and the time elapsed, since the last recovery
  /// Schedules next recovery.
  /// Updates `currentHumanityDamage`, `this.recoveryRem`, `this.recoveryTsSec`
  private func RecoverHumanity() {
    // Schedule next recovery
    this.ScheduleRecoverHumanity();
    // Calculate the recovery from the current period
    let humanityInc = this.RecoverHumanityCalcPeriodInc();
    if (humanityInc <= 0.0) { return; }

    // Compute the total recovery
    let humanityRecovery = this.recoveryRem + humanityInc;
    let humanityIntRecovery = Cast<Int32>(humanityRecovery);
    // Update the remainder of the integer recovery
    this.recoveryRem = humanityRecovery - Cast<Float>(humanityIntRecovery);
    this.DecHumanityDmg(humanityIntRecovery);
  }

  /// Returns the fractional amount of humanity to recover
  /// Updates `this.recoveryTsSec`
  private func RecoverHumanityCalcPeriodInc() -> Float {
    // Elapsed fraction of a day
    // EngineTime is the simulated time, not the real time
    let tsNowSec = Cast<Float>(GameTime.GetSeconds(this.timeSystem.GetGameTime()));
    let tsDeltaSec = tsNowSec - this.recoveryTsSec;
    let dayFrac = tsDeltaSec / 86400.0;
    LDebug(s"Computing humanity increment for \(tsDeltaSec)s, in period \(this.recoveryTsSec)..\(tsNowSec)s");
    // Update timestamp
    this.recoveryTsSec = tsNowSec;

    if (tsNowSec <= 0.0) {
      LWarn(s"Recovery time before was zero");
      return 0.0;
    }

    if tsDeltaSec <= 0.0 {
      LWarn(s"No time elapsed since last recovery");
      return 0.0;
    }

    // Compute Cyberwear load
    let slots = EquipmentSystem.GetData(this.player).GetCyberwareSlotsCombinedCount();
    let slotsFillFrac = slots.Total <= 0 ? 1.0 : ClampF(Cast<Float>(slots.Equipped) / Cast<Float>(slots.Total), 0.0, 1.0);
    let slotsFreeFrac = 1.0 - slotsFillFrac;
    LDebug(s"Cyberwear load is \(slotsFillFrac), player equipped \(slots.Equipped) out of \(slots.Total) slots");

    // Compute $a*(\frac{c_{empty}}{c_{filled}})*t^{-1}$
    let inc = this.config.recoveryAmount * slotsFreeFrac * dayFrac;
    LDebug(s"Recovered \(this.config.recoveryAmount)*\(slotsFreeFrac)*\(dayFrac)=\(inc) humanity since last recovery");
    return inc;
  }

  /// Registers a `LaunchCycledRecoverHumanityRequest`, executed after a period of time passed
  private func ScheduleRecoverHumanity() {
    let delaySec = 10.0;
    LDebug(s"Scheduled next humanity recovery in \(delaySec)s");
    this.recoverHumanityDelayId = this.delaySystem.DelayScriptableSystemRequest(this.GetClassName(), new LaunchCycledRecoverHumanityRequest(), delaySec);
  }
}
