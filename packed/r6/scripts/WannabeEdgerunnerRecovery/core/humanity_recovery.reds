module Edgerunning.System

import Logging.*
import Math.*

public class EdgerunningRecoverySystem extends ScriptableSystem {
  // ------------------------------------------
  // Fields
  // ------------------------------------------
  // Systems
  private let delaySystem: ref<DelaySystem>;
  private let timeSystem: ref<TimeSystem>;
  private let edgerunningSystem: ref<EdgerunningSystem>;
  private let progressionController: ref<ProgressionWidgetGameController>;
  // Events
  private let recoverHumanityDelayId: DelayID;

  // The mod config
  private let config: ref<EdgerunnerRecoveryConfig>;
  // The player
  private let player: wref<PlayerPuppet>;
  // The `GameTime` of the last `LaunchCycledRecoverHumanityRequest`
  private let recoveryTsSec: Float = 0;
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
    this.RecoverHumanityLoop();
  }

  private final func OnEnemyKnockout(affiliation: gamedataAffiliation) {
    LTrace("OnEnemyKnockout");
    this.KnockoutEnemy(affiliation);
  }

  private final func OnPlayerCombatStateChanged(state: PlayerCombatState) {
    LTrace("OnPlayerCombatStateChanged");
    this.ChangeCombatState(state);
  }

  private final func OnRecoverHumanityRequest(request: ref<RecoverHumanityRequest>) -> Void {
    LTrace("OnRecoverHumanityRequest");
    this.RecoverHumanity(request.Amount);
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
  /// The current damage to humanity
  public final func GetHumanityDmg() -> Int32 {
    return this.edgerunningSystem.currentHumanityDamage;
  }
  /// The maximum amount of damage to humanity inflicable due to murder
  public final func GetHumanityDmgPool() -> Int32 {
    return this.edgerunningSystem.config.baseHumanityPool - this.edgerunningSystem.cyberwareCost;
  }
  /// The combined reduction to humanity inflicted due to Cyberware and damage
  public final func GetHumanityRed() -> Int32 {
    return this.edgerunningSystem.cyberwareCost + this.edgerunningSystem.currentHumanityDamage;
  }
  // The total humanity pool
  public final func GetHumanityRedPool() -> Int32 {
    return this.edgerunningSystem.config.baseHumanityPool;
  }

  /// Applies a offset to the humanity damage
  /// If the offset is positive, it will increase the damage; otherwise it will decrease it
  /// If the offset is not zero, invalidates the EdgerunningSystem.
  private final func RecoverHumanity(amount: Int32) {
    let humanityDmgOld = this.GetHumanityDmg();
    let humanityDmgNew = Clamp(humanityDmgOld - amount, 0, this.GetHumanityDmgPool());
    LInfo(s"Recovering \(amount) humanity, from \(humanityDmgOld) to \(humanityDmgNew)");
    if (amount == 0) { return; }
    // Decrement the humanity damage
    this.edgerunningSystem.currentHumanityDamage = humanityDmgNew;
    this.edgerunningSystem.InvalidateCurrentState();

    // show a hud notification on increment
    this.QueueHumanityChangedNotify(amount);
  }

  // ------------------------------------------
  // Core logic: Recover humanity over time
  // ------------------------------------------

  public func IsRecoveringHumanity() -> Bool {
    let invalidDelayId: DelayID;
    return this.recoverHumanityDelayId != invalidDelayId;
  }

  public func StartRecoverHumanity() {
    if !this.IsRecoveringHumanity() {
      this.ScheduleRecoverHumanity();
    }
  }

  public func StopRecoverHumanity() {
    let invalidDelayId: DelayID;
    // Chceck if DelayID was invalid
    if this.recoverHumanityDelayId != invalidDelayId {
      this.delaySystem.CancelDelay(this.recoverHumanityDelayId);
    }
    // Assign invalid DelayID
    this.recoverHumanityDelayId = invalidDelayId;
    // Reset the timestamp, so that the next recovery cycle will start from the current time
    this.recoveryTsSec = 0.0;
  }

  /// Registers a `LaunchCycledRecoverHumanityRequest`, executed after a period of time passed
  private func ScheduleRecoverHumanity() {
    let delaySec = this.config.recoveryScheduleDelaySec;
    LDebug(s"Scheduled next humanity recovery in \(delaySec)s");
    this.recoverHumanityDelayId = this.delaySystem.DelayScriptableSystemRequest(this.GetClassName(), new LaunchCycledRecoverHumanityRequest(), delaySec);
  }

  /// Recovers humanity according to the equipped Cyberware, and the time elapsed, since the last recovery
  /// Schedules next recovery.
  /// Updates `currentHumanityDamage`, `this.recoveryRem`, `this.recoveryTsSec`
  private func RecoverHumanityLoop() {
    // Schedule next recovery
    this.ScheduleRecoverHumanity();

    // Calculate the recovery from the current period

    // Elapsed fraction of a day
    // EngineTime is the simulated time, not the real time
    let tsNowSec = Cast<Float>(GameTime.GetSeconds(this.timeSystem.GetGameTime()));
    let tsDeltaSec = tsNowSec - this.recoveryTsSec;
    let dayFrac = tsDeltaSec / 86400.0;
    LDebug(s"Computing humanity increment for \(tsDeltaSec)s, in period \(this.recoveryTsSec)..\(tsNowSec)s");
    // Update timestamp
    this.recoveryTsSec = tsNowSec;

    if tsNowSec <= 0.0 || tsDeltaSec == tsNowSec {
      LWarn(s"Recovery time before was zero");
      return;
    }

    if tsDeltaSec <= 0.0 {
      LWarn(s"No time elapsed since last recovery");
      return;
    }

    let recoveryRate = this.GetHumanityRecoveryRate();
    // Compute Cyberwear load
    let humanityInc = recoveryRate * dayFrac;
    LDebug(s"Recovery increment is \(humanityInc). dayFrac = \(dayFrac)");
    if (humanityInc <= 0.0) { return; }

    // Compute the total recovery
    let humanityRecovery = this.recoveryRem + humanityInc;
    let humanityIntRecovery = Cast<Int32>(humanityRecovery);
    // Update the remainder of the integer recovery
    this.recoveryRem = humanityRecovery - Cast<Float>(humanityIntRecovery);
    this.RecoverHumanity(humanityIntRecovery);
  }

  public func GetHumanityRecoveryRate() -> Float {
    // If not recovering, return 0
    if !this.IsRecoveringHumanity() {
      return 0.0;
    }

    let slots: CyberwareSlots = EquipmentSystem.GetData(this.player).GetCyberwareSlotsCombinedCount();
    let load = CyberwareSlots.GetLoadFrac(slots);
    LDebug(s"Cyberwear load is \(load). \(slots.Equipped)/\(slots.Total)");

    let recoveryRate = EdgerunningRecoverySystem.GetRecoverHumanityRegenRateAdaptive(this.config.recoveryRate, this.config.recoveryThres, load);
     if !this.config.recoveryAdaptive {
      // Return the base recovery rate signed by the calculated recovery rate
      LDebug("Adaptive recovery disabled, maximum recovery rate applied");
      recoveryRate = SignF(recoveryRate) * this.config.recoveryRate;
    }
    LDebug(s"Recovery rate is \(recoveryRate). rate = \(this.config.recoveryRate), thres = \(this.config.recoveryThres), load = \(load)");
    return recoveryRate;
  }

  public func GetHumanityRecoveryRateMax() -> Float {
    return this.config.recoveryRate;
  }

  /// Returns the degen rate, based on the current load and settings. Negate to get the recovery rate.
  /// Interpolates the load to the interval [-rate, rate], where rate is the recovery rate, zero centrered at the threshold
  ///
  /// 0 ---|------------- 1 thres
  ///     /\
  ///    /    \
  ///   /        \
  ///  /            \
  /// /                \
  ///-1 ---------------- 1 rate
  /// load
  ///
  public static func GetRecoverHumanityRegenRateAdaptive(const rate: Float, const thres: Float, const load: Float) -> Float {
    // Consider the load threshold for the recovery rate
    let loadRem = thres - load;
    // If the value is tiny return zero
    if IsEpsilonF(loadRem) { return 0.0; }

    // Interpolate [0,loadRem] to [0,rate]
    if loadRem < 0.0 {
      return loadRem * rate / (1.0 - thres);
    } else {
      return loadRem * rate / thres;
    }
  }

  // ------------------------------------------
  // Core logic: Enemy Knockout
  // ------------------------------------------

  private func KnockoutEnemy(affiliation: gamedataAffiliation) {
    let reward = this.GetEnemyKnockoutReward(affiliation);
    LInfo(s"Knocking out enemy of affiliation \(affiliation)");
    this.RecoverHumanity(reward);
  }

  /// Returns the reward for knocking an enemy unconscious (in humanity)
  /// Computes $$d / c ^ e$$ where $d$ is the dividend, $c$ is the kill cost, and $e$ the exponent.
  public func GetEnemyKnockoutReward(affiliation: gamedataAffiliation) -> Int32 {
    let dividend = this.config.enemyUnconsciousDiv;
    let exponent = this.config.enemyUnconsciousExp;
    if dividend <= 0.0 { return 0; }

    let killCost = this.edgerunningSystem.GetEnemyCost(affiliation);
    let reward = dividend * PowF(Cast<Float>(killCost), -exponent);
    return Cast<Int32>(reward);
  }

  // ------------------------------------------
  // Core logic: Combat regeneration
  // ------------------------------------------

  private func ChangeCombatState(state: PlayerCombatState) {
    if this.config.recoveryInCombat {
      LInfo("Recovery in combat is enabled");
      // ensure that recovery is started
      this.StartRecoverHumanity();
      return;
    }
    if Equals(state, PlayerCombatState.OutOfCombat) {
      LInfo("Recovery started, player exited combat");
      // immediatly start recovering
      this.RecoverHumanityLoop();
    } else {
      this.StopRecoverHumanity();
      LInfo("Recovery stopped, player entered combat");
    }
  }

  // ------------------------------------------
  // Core logic: HUD
  // ------------------------------------------

  private func QueueHumanityChangedNotify(delta: Int32) {
    let humanityRed = this.GetHumanityRed();
    let evt: ref<ProficiencyProgressEvent>;
    evt.delta = delta;
    evt.expValue = this.GetHumanityRedPool() - humanityRed;
    evt.remainingXP = humanityRed;
    evt.currentLevel = 1;
    evt.isLevelMaxed = false;
    evt.type = gamedataProficiencyType.Assault;
    evt.typeAux = 1337; // reserved for humanity

    LDebug(s"Queueing humanity changed event: delta = \(delta), expValue = \(evt.expValue), remainingXP = \(evt.remainingXP)");
    GameInstance.GetUISystem(this.player.GetGame()).QueueEvent(evt);
  }
}


