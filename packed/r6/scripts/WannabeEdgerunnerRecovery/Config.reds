public class EdgerunnerRecoveryConfig {
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
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "1")
  let recoveryThres: Float = 1;

  let recoveryScheduleDelaySec: Float = 66;
}
