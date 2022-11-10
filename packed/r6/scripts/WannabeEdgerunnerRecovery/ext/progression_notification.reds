import Logging.LTrace

@wrapMethod(ProgressionWidgetGameController)
protected cb func OnCharacterProficiencyUpdated(evt: ref<ProficiencyProgressEvent>) -> Bool {
  LTrace("OnCharacterProficiencyUpdated");
  switch evt.typeAux {
    case 1337: // handles humanity
      this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "Mod-Edg-Humanity", evt.type, evt.currentLevel, evt.isLevelMaxed);
      break;
    default: // default behavior
      wrappedMethod(evt);
      break;
  }
}
