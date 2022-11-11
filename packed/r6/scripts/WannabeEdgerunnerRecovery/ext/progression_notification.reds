import Logging.LTrace

@wrapMethod(ItemsNotificationQueue)
protected cb func OnCharacterProficiencyUpdated(evt: ref<ProficiencyProgressEvent>) -> Bool {
  LTrace("OnCharacterProficiencyUpdated");
  switch evt.typeAux {
    case 1337: // handles humanity
      this.PushXPNotification(evt.expValue, evt.remainingXP, evt.delta, n"StreetCred", GetLocalizedTextByKey(n"Mod-Edg-Humanity"), gamedataProficiencyType.Invalid, evt.currentLevel, evt.isLevelMaxed);
      break;
    default: // default behavior
      return wrappedMethod(evt);
  }
}
