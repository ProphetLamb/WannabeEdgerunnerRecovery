module Math

/// The epsilon value used for floating point comparisons.
public static func EpsilonF() -> Float { return 0.0000001192092896; }
/// Indicates whether the absolute of a value is less than the epsilon value.
public static func IsEpsilonF(const v: Float) -> Bool { return AbsF(v) < 0.0000001192092896; }

public static func SignF(const s: Float) -> Float { return s < 0.0 ? -1.0 : 1.0; }
public static func SignF(const s: Int32) -> Float { return s < 0 ? -1.0 : 1.0; }
public static func Sign(const s: Int32) -> Int32 { return s < 0 ? -1 : 1; }
public static func Sign(const s: Float) -> Int32 { return s < 0.0 ? -1 : 1; }
