public class EdgerunnerRecoveryConfig {
  @runtimeProperty("ModSettings.mod", "Edgerunner")
  @runtimeProperty("ModSettings.category", "Gameplay-Devices-Interactions-Recovery")
  @runtimeProperty("ModSettings.displayName", "Mod-Edg-Recovery-Amount")
  @runtimeProperty("ModSettings.description", "Mod-Edg-Recovery-Amount-Desc")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "500")
  let recoveryAmount: Float = 100;
}
