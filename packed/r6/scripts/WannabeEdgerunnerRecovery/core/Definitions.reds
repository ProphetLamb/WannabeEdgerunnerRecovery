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
}

public class LaunchCycledRecoverHumanityRequest extends ScriptableSystemRequest {}
