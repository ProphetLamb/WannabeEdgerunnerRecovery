
import Logging.*
import Edgerunning.System.EdgerunningRecoverySystem

@wrapMethod(dialogWidgetGameController)
protected cb func OnLastAttemptedChoiceCustom(value: Variant) -> Bool {
  LTrace("OnLastAttemptedChoiceCustom");
  LDebug(s"lastLoc = \(this.m_lastSelectedHub), choice = \(value)");
  switch this.m_lastSelectedHub {
    case "LocKey#45546": // donate to veteran or bum
      EdgerunningRecoverySystem.GetInstance(this.GetPlayerControlledObject().GetGame()).OnNpcDonate();
      break;
  }
  return wrappedMethod(value);
}
