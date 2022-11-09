module Edgerunning.System

/// Returns the total and equipped number of Cyberware slots, as a tuple of two 16bit integers.
/// slotsTotal := (slotsCombined & 65535)
/// slotsEquipped := (slotsCombined - 65535)
@addMethod(EquipmentSystemPlayerData)
public final const func GetCyberwareSlotsCombinedCount() -> CyberwareSlots {
  let slotsEquipped = 0;
  let slotsTotal = 0;
  for slot in [
      gamedataEquipmentArea.FrontalCortexCW,
      gamedataEquipmentArea.SystemReplacementCW,
      gamedataEquipmentArea.EyesCW,
      gamedataEquipmentArea.MusculoskeletalSystemCW,
      gamedataEquipmentArea.NervousSystemCW,
      gamedataEquipmentArea.CardiovascularSystemCW,
      gamedataEquipmentArea.ImmuneSystemCW,
      gamedataEquipmentArea.IntegumentarySystemCW,
      gamedataEquipmentArea.HandsCW,
      gamedataEquipmentArea.ArmsCW,
      gamedataEquipmentArea.LegsCW
    ] {
    let equipSlots = this.m_equipment.equipAreas[this.GetEquipAreaIndex(slot)].equipSlots;
    let len = ArraySize(equipSlots);
    let i = 0;
    while i < len {
      if ItemID.IsValid(equipSlots[i].itemID) {
        slotsEquipped += 1;
      };
      i += 1;
    };
    slotsTotal += len;
  };
  // Return a tuple of two 16bit integers (technically 16+15 bit: 1b sign,15b slotsEquipped, 16b slotsTotal
  return CyberwareSlots.Create(slotsTotal, slotsEquipped);
}

