module Math

/// The epsilon value used for floating point comparisons.
public static func EpsilonF() -> Float { return 0.0000001192092896; }
/// Indicates whether the absolute of a value is less than the epsilon value.
public static func IsEpsilonF(const v: Float) -> Bool { return AbsF(v) < 0.0000001192092896; }
