module Edgerunning.System

@addField(RipperDocGameController)
public let edgerunningRecoverySystem: wref<EdgerunningRecoverySystem>;

@wrapMethod(RipperDocGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();
  this.edgerunningRecoverySystem = EdgerunningRecoverySystem.GetInstance(this.m_player.GetGame());
}

@wrapMethod(RipperDocGameController)
protected cb func OnHumanityIconHoverOver(evt: ref<inkPointerEvent>) -> Bool {
  this.humanityIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  this.humanityIcon.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
  let data: ref<MessageTooltipData> = new MessageTooltipData();
  let curHumanity: Int32 = this.edgerunningSystem.GetHumanityCurrent();
  let totHumanity: Int32 = this.edgerunningSystem.GetHumanityTotal();
  let curRate = this.edgerunningRecoverySystem.GetHumanityRecoveryRate();
  let maxRate = this.edgerunningRecoverySystem.config.recoveryRate;
  data.Title = s"\(GetLocalizedTextByKey(n"Mod-Edg-Humanity")): \(curHumanity) / \(totHumanity) \(GetLocalizedTextByKey(n"Mod-Edg-Recovery-Rate")): \(curRate) / \(maxRate)";
  data.Description = s"\(GetLocalizedTextByKey(n"Mod-Edg-Humanity-Desc"))\n\(GetLocalizedTextByKey(n"Mod-Edg-Recovery-Rate-Desc"))";
  this.m_TooltipsManager.ShowTooltip(data);
}
