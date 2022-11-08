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

  // The settings have changed
  public func OnModSettingsChange() -> Void {
    LTrace("OnModSettingsChange");
    this.RefreshConfig();
  }

  // The game-save is loaded
  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    LTrace("OnPlayerAttach");
    this.LoadPlayer(request.owner);
    this.StopRecoverHumanity();
    this.StartRecoverHumanity();
  }

  // The cycle for recovering humanity has elapsed
  public final func OnLaunchCycledRecoverHumanityRequest(request: ref<LaunchCycledRecoverHumanityRequest>) -> Void {
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

  public func LoadPlayer(owner: ref<GameObject>) {
    LTrace("LoadPlayer");
    let game = owner.GetGame();
    this.player = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    LErrorIfUndef(this.player, n"PlayerPuppet");
    this.delaySystem = GameInstance.GetDelaySystem(game);
    LErrorIfUndef(this.delaySystem, n"DelaySystem");
    this.timeSystem = GameInstance.GetTimeSystem(game);
    LErrorIfUndef(this.timeSystem, n"TimeSystem");
    this.edgerunningSystem = EdgerunningSystem.GetInstance(game);
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

  public func StartRecoverHumanity() {
    LTrace("StartRecoverHumanity");
    this.RecoverHumanity();
  }

  public func StopRecoverHumanity() {
    LTrace("StopRecoverHumanity");
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
  public func RecoverHumanity() {
    LTrace("RecoverHumanity");
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
    let tsNowSec = EngineTime.ToFloat(this.timeSystem.GetSimTime());
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
    let slotsCombined = EquipmentSystem.GetData(this.player).GetCyberwareSlotsCombinedCount();
    let slotsTotal = Cast<Float>(slotsCombined & 65535);
    let slotsEquipped = Cast<Float>(slotsCombined / 65535);
    let slotsFillFrac = slotsTotal <= 0.0 ? 1.0 : ClampF(slotsEquipped / slotsTotal, 0.0, 1.0);
    let slotsFreeFrac = 1.0 - slotsFillFrac;
    LDebug(s"Cyberwear load is \(slotsFillFrac), player equipped \(slotsEquipped) out of \(slotsTotal) slots");

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
