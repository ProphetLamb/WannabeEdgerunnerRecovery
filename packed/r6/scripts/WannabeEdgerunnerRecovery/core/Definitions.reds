module Edgerunning.System

public struct CyberwareSlots {
  public let Total: Int32;
  public let Equipped: Int32;

  public static func Create(total: Int32, equipped: Int32) -> CyberwareSlots {
    let slots: CyberwareSlots;
    slots.Total = total;
    slots.Equipped = equipped;
    return slots;
  }

  /// Returns the portion of time during which humanity is recovered, based on the current Cyberwear load
  public static func GetLoadFrac(const slots: CyberwareSlots) -> Float {
    return slots.Total <= 0 ? 1.0 : ClampF(Cast<Float>(slots.Equipped) / Cast<Float>(slots.Total), 0.0, 1.0);
  }
}

public class LaunchCycledRecoverHumanityRequest extends ScriptableSystemRequest {}
