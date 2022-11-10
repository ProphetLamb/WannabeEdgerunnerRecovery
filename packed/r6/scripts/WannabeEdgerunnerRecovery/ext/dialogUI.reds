
import Logging.*

@wrapMethod(dialogWidgetGameController)
protected cb func OnLastAttemptedChoiceCustom(value: Variant) -> Bool {
  LTrace("OnLastAttemptedChoiceCustom");
  LDebug(s"Selected LocKey \(this.m_lastSelectedHub)");
  let hubLastSelected = this.m_lastSelectedHub;
  wrappedMethod(value);

  switch hubLastSelected {
    case "LocKey#45546": // donate to veteran or bum
      break;
  }
}
