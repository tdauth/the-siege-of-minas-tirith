library ThrowingAxe

	globals
		private constant integer ABILITY_ID = 'A06C'
		private constant integer MAX_TARGETS = 5
		private constant real MAX_NEXT_TARGET_RANGE = 1200.0
		private constant real DAMAGE_BONUS_PER_ABILITY_LEVEL = 30.0
		private constant real DAMAGE_BONUS_PER_TARGET = 30.0
	endglobals

	private function GetNextTargetFilter takes nothing returns boolean
		return not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
	endfunction

	private function GetNextTarget takes unit gimli, unit source returns unit
		local group g = CreateGroup()
		local group tmp = CreateGroup()
		local unit first = null
		call GroupEnumUnitsInRange(g, GetUnitX(source), GetUnitY(source), MAX_NEXT_TARGET_RANGE, Filter(function GetNextTargetFilter))
		loop
			set first = FirstOfGroup(g)
			exitwhen (first == null)
			call GroupRemoveUnit(g, first)
			if (IsUnitEnemy(first, GetOwningPlayer(gimli))) then
				call GroupAddUnit(tmp, first)
			endif
		endloop
		
		set first = FirstOfGroup(tmp)
		
		call DestroyGroup(g)
		set g = null
		call DestroyGroup(tmp)
		set tmp = null
		
		return first
	endfunction
	
	function ThrowingAxeEx takes integer abilityId, unit gimli, unit source, unit target, integer counter returns nothing
		local lightning l = AddLightning("MFPB", true, GetUnitX(source), GetUnitY(source), GetUnitX(target), GetUnitY(target))
		local unit nextTarget = GetNextTarget(gimli, target)
		call UnitDamageTargetBJ(gimli,target, GetUnitAbilityLevel(gimli, abilityId) * DAMAGE_BONUS_PER_ABILITY_LEVEL + (counter - 1) * DAMAGE_BONUS_PER_TARGET, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
		call TriggerSleepAction(2.0)
		call DestroyLightning(l)
		set l = null
		if (nextTarget != null and counter < MAX_TARGETS) then
			call ThrowingAxeEx(abilityId, gimli, target, nextTarget, counter + 1)
		endif
	endfunction

	function ThrowingAxe takes unit gimli, unit target returns nothing
		call ThrowingAxeEx(ABILITY_ID, gimli, gimli, target, 1)
	endfunction

endlibrary