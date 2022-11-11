public class EdgerunnerRecoveryConfig {
  let recoveryScheduleDelaySec: Float = 55.0;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Recovery")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Recovery-Adaptive")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Recovery-Adaptive-Desc")
  let recoveryAdaptive: Bool = true;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Recovery")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Recovery-Rate")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Recovery-Rate-Desc")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "500")
  let recoveryRate: Float = 200;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Recovery")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Recovery-Threshold")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Recovery-Threshold-Desc")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "1.0")
  let recoveryThres: Float = 0.8;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Recovery")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Recovery-InCombat")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Recovery-InCombat-Desc")
  let recoveryInCombat: Bool = false;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Reward")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Unconscious-Dividend")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Unconscious-Dividend-Desc")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "50.0")
  let enemyUnconsciousDiv: Float = 10.0;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Reward")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Unconscious-Exponent")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Unconscious-Exponent-Desc")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "2.0")
  let enemyUnconsciousExp: Float = 0.5;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Reward")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Reward-Donate")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Reward-Desc")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "50")
  let rewardDonate: Int32 = 10;

  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Mod-Edg-Reward")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Reward-Pet")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Reward-Desc")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "50")
  let rewardPet: Int32 = 10;
}
