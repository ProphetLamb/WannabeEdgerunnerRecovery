module Edgerunning.System

import Logging.*

@wrapMethod(PlayerPuppet)
protected cb func OnInteractionUsed(evt: ref<InteractionChoiceEvent>) -> Bool {
  LTrace("OnInteractionUsed");
  let choice: String = evt.choice.choiceMetaData.tweakDBName;
  LDebug(s"type=\(evt.actionType), choice=\(choice), this.role=\(this.DeterminGameplayRole()), activator.role=\(evt.activator.DeterminGameplayRole())");
  wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnInteraction(evt: ref<InteractionChoiceEvent>) -> Bool {
  LTrace("OnInteraction");
  let choice: String = evt.choice.choiceMetaData.tweakDBName;
  LDebug(s"type=\(evt.actionType), choice=\(choice), this.role=\(this.DeterminGameplayRole()), activator.role=\(evt.activator.DeterminGameplayRole())");
  wrappedMethod(evt);
}
