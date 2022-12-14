module Edgerunning.System

import Math.Sign

@addField(RipperDocGameController)
public let edgerunningRecoverySystem: wref<EdgerunningRecoverySystem>;

@wrapMethod(RipperDocGameController)
protected cb func OnInitialize() -> Bool {
  let ret = wrappedMethod();
  this.edgerunningRecoverySystem = EdgerunningRecoverySystem.GetInstance(this.m_player.GetGame());
  return ret;
}

@wrapMethod(RipperDocGameController)
protected cb func OnHumanityIconHoverOver(evt: ref<inkPointerEvent>) -> Bool {
  this.humanityIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  this.humanityIcon.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
  let data = new MessageTooltipData();
  let curHumanity = this.edgerunningSystem.GetHumanityCurrent();
  let totHumanity = this.edgerunningSystem.GetHumanityTotal();
  let curRate = Cast<Int32>(this.edgerunningRecoverySystem.GetHumanityRecoveryRate());
  let maxRate = Sign(curRate) * Cast<Int32>(this.edgerunningRecoverySystem.GetHumanityRecoveryRateMax());
  data.Title = s"\(GetLocalizedTextByKey(n"Mod-Edg-Humanity")): \(curHumanity) / \(totHumanity)\n\(GetLocalizedTextByKey(n"Mod-Edg-Recovery-Rate")): \(curRate) / \(maxRate)";
  data.Description = s"\(GetLocalizedTextByKey(n"Mod-Edg-Humanity-Desc"))\n\n\(GetLocalizedTextByKey(n"Mod-Edg-Recovery-Rate-Desc"))";
  this.m_TooltipsManager.ShowTooltip(data);
}
