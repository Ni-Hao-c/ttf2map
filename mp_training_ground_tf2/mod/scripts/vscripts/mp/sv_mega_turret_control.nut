untyped

global function MegaTurretControl_Precache
global function MegaTurretControl_RegisterSite
global function MegaTurretControl_Init

const asset MEGA_TURRET_CONTROL_MODEL = $"models/turrets/turret_imc_lrg.mdl"
const string MEGA_TURRET_CONTROL_AI_SETTING = "npc_turret_mega_old"
const float MEGA_TURRET_CONTROL_PANEL_RADIUS = 128.0
const float MEGA_TURRET_CONTROL_TURRET_RADIUS = 8192.0
const float MEGA_TURRET_CONTROL_TARGET_RANGE = 16000.0

struct
{
	array<vector> panelOrigins
	bool callbackRegistered
	bool initialized
} file

void function MegaTurretControl_Precache()
{
	PrecacheModel( MEGA_TURRET_CONTROL_MODEL )
	PrecacheWeapon( "mp_weapon_mega_turret" )
	PrecacheWeapon( "mp_weapon_turret_tday" )
}

void function MegaTurretControl_RegisterSite( vector panelOrigin )
{
	if ( file.initialized )
	{
		print( "[MegaTurretControl] Registration ignored after initialization" )
		return
	}

	file.panelOrigins.append( panelOrigin )
}

void function MegaTurretControl_Init()
{
	if ( file.callbackRegistered )
		return

	file.callbackRegistered = true
	MegaTurretControl_Precache()
	AddCallback_GameStateEnter( eGameState.Prematch, MegaTurretControl_OnPrematch )
}

void function MegaTurretControl_OnPrematch()
{
	if ( file.initialized )
		return

	file.initialized = true
	RegisterSignal( "MegaTurretControlReassigned" )

	print( "[MegaTurretControl] Initializing " + file.panelOrigins.len() + " turret site(s)" )
	array<entity> panels = GetEntArrayByClass_Expensive( "prop_control_panel" )

	for ( int i = 0; i < file.panelOrigins.len(); i++ )
	{
		entity panel = MegaTurretControl_FindPanel( panels, file.panelOrigins[i] )
		if ( !IsValid( panel ) )
		{
			print( "[MegaTurretControl] Control panel not found at registered position" )
			continue
		}

		entity originalTurret = MegaTurretControl_FindTurret( panel.GetOrigin() )
		if ( !IsValid( originalTurret ) )
		{
			print( "[MegaTurretControl] Mega turret not found near registered panel" )
			continue
		}

		panel.SetUsable()
		panel.SetUsableByGroup( "pilot" )
		panel.SetUsePrompts( "Activate Mega Turret", "Activate Mega Turret" )
		panel.s.megaTurretControlTurret <- originalTurret
		panel.s.megaTurretControlOrigin <- originalTurret.GetOrigin()
		panel.s.megaTurretControlAngles <- originalTurret.GetAngles()

		originalTurret.Destroy()
		entity replacementTurret = MegaTurretControl_Respawn( panel )
		if ( !IsValid( replacementTurret ) )
			continue

		AddCallback_OnUseEntity( panel, MegaTurretControl_OnPanelUsed )
		print( "[MegaTurretControl] Replaced and bound turret site " + i )
	}
}

entity function MegaTurretControl_FindPanel( array<entity> panels, vector expectedOrigin )
{
	entity closestPanel = null
	float closestDistance = MEGA_TURRET_CONTROL_PANEL_RADIUS * MEGA_TURRET_CONTROL_PANEL_RADIUS

	foreach ( entity panel in panels )
	{
		float distance = DistanceSqr( panel.GetOrigin(), expectedOrigin )
		if ( distance < closestDistance )
		{
			closestDistance = distance
			closestPanel = panel
		}
	}

	return closestPanel
}

entity function MegaTurretControl_FindTurret( vector panelOrigin )
{
	entity closestTurret = null
	float closestDistance = MEGA_TURRET_CONTROL_TURRET_RADIUS * MEGA_TURRET_CONTROL_TURRET_RADIUS
	array<entity> turrets = GetEntArrayByClass_Expensive( "npc_turret_mega" )

	foreach ( entity turret in turrets )
	{
		if ( !IsValid( turret ) )
			continue

		float distance = DistanceSqr( turret.GetOrigin(), panelOrigin )
		if ( distance < closestDistance )
		{
			closestDistance = distance
			closestTurret = turret
		}
	}

	return closestTurret
}

function MegaTurretControl_OnPanelUsed( panel, player )
{
	if ( !IsValid( panel ) || !IsValid( player ) )
		return

	entity usePanel = expect entity( panel )
	entity usingPlayer = expect entity( player )
	if ( !usingPlayer.IsPlayer() || !( "megaTurretControlTurret" in usePanel.s ) )
		return

	entity turret = expect entity( usePanel.s.megaTurretControlTurret )
	if ( !IsValid( turret ) || !IsAlive( turret ) )
	{
		turret = MegaTurretControl_Respawn( usePanel )
		if ( !IsValid( turret ) )
			return
	}

	int team = usingPlayer.GetTeam()
	SetTeam( turret, team )
	turret.SetBossPlayer( usingPlayer )
	turret.SetNoTarget( false )
	turret.StartDeployed()
	turret.Signal( "MegaTurretControlReassigned" )
	//thread MegaTurretControl_TargetThink( turret, team )

	SetTeam( usePanel, team )
	EmitSoundOnEntity( usePanel, "diag_neut_friendlySpawnOnPlayer" )
	print( "[MegaTurretControl] " + usingPlayer.GetPlayerName() + " activated turret; state=" + turret.GetTurretState() )
}

entity function MegaTurretControl_Respawn( entity panel )
{
	if ( !( "megaTurretControlOrigin" in panel.s ) || !( "megaTurretControlAngles" in panel.s ) )
		return null

	if ( "megaTurretControlTurret" in panel.s )
	{
		entity oldTurret = expect entity( panel.s.megaTurretControlTurret )
		if ( IsValid( oldTurret ) )
			oldTurret.Destroy()
	}

	vector origin = expect vector( panel.s.megaTurretControlOrigin )
	vector angles = expect vector( panel.s.megaTurretControlAngles )
	entity turret = CreateEntity( "npc_turret_mega" )
	turret.SetOrigin( origin )
	turret.SetAngles( angles )
	SetSpawnOption_AISettings( turret, MEGA_TURRET_CONTROL_AI_SETTING )
	DispatchSpawn( turret )

	SetTeam( turret, TEAM_UNASSIGNED )
	//turret.SetNoTarget( true )
	panel.s.megaTurretControlTurret = turret
	turret.TakeActiveWeapon()
	turret.GiveWeapon( "mp_weapon_turret_tday", [ "SoundGroupB" ] )
	//turret.SetModel(MEGA_TURRET_CONTROL_MODEL)
	print( "[MegaTurretControl] Respawned npc_turret_mega_old" )
	return turret
}

void function MegaTurretControl_TargetThink( entity turret, int team )
{
	turret.EndSignal( "OnDestroy" )
	turret.EndSignal( "OnDeath" )
	turret.EndSignal( "MegaTurretControlReassigned" )

	while ( turret.GetTeam() == team )
	{
		entity bestTarget = null
		float bestDistance = MEGA_TURRET_CONTROL_TARGET_RANGE * MEGA_TURRET_CONTROL_TARGET_RANGE
		array<entity> targets = GetNPCArrayOfEnemies( team )
		targets.extend( GetPlayerArrayOfEnemies( team ) )

		foreach ( entity target in targets )
		{
			if ( !IsAlive( target ) )
				continue

			float distance = DistanceSqr( turret.GetOrigin(), target.GetOrigin() )
			if ( distance < bestDistance )
			{
				bestDistance = distance
				bestTarget = target
			}
		}

		if ( IsValid( bestTarget ) )
			turret.SetEnemy( bestTarget )

		wait 0.5
	}
}
