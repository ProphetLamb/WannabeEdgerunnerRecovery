import Logging.LTrace

@wrapMethod(ProgressionWidgetGameController)
protected cb func OnCharacterProficiencyUpdated(evt: ref<ProficiencyProgressEvent>) -> Bool {
  LTrace("OnCharacterProficiencyUpdated");
  wrappedMethod(evt);

  // we handle the type invalid based on the auxilary type
  if !Equals(evt.type, gamedataProficiencyType.Invalid) { return false; }
  switch evt.typeAux {
    case 1337: // handles humanity
      this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"StreetCred", "Mod-Edg-Humanity", evt.type, evt.currentLevel, evt.isLevelMaxed);
  }
}
