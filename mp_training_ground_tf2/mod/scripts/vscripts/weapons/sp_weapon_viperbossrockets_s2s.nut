global function ViperBossScriptOnlyWeapon

#if SERVER
global function ViperBossNPCScriptOnlyWeapon
#endif

global function ViperBossRockets_Init

void function ViperBossRockets_Init()
{
	PrecacheParticleSystem( $"wpn_mflash_xo_rocket_shoulder" )
}

var function ViperBossScriptOnlyWeapon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return
}

#if SERVER
var function ViperBossNPCScriptOnlyWeapon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return
}
#endif
