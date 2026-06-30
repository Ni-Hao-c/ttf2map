untyped

global function ViperBoss_Init
global function ViperBoss_CreateStage1
global function ViperBoss_CreateStage2
global function ViperBoss_CreateStage3
global function ViperBoss_Destroy
global function ViperBoss_BeforeInit
global function ViperBoss_CommandInit

global struct ViperBossConfig
{
	vector origin
	vector angles
	vector arenaMins
	vector arenaMaxs
	int team = TEAM_IMC
	entity harvester = null
	float healthMultiplier = 1.0
}

const asset VIPER_BOSS_MODEL = $"models/titans/light/titan_northstar_scripted_version.mdl"
const string VIPER_BOSS_WEAPON = "sp_weapon_ViperBossRockets_s2s"
const string VIPER_BOSS_AI_SETTINGS = "npc_titan_auto_stryder_northstar_prime"
const int VIPER_BOSS_BASE_HEALTH = 18000
const float VIPER_BOSS_RETREAT_HEALTH_FRACTION = 0.15
const float VIPER_BOSS_RETREAT_TIME = 3.5

const int VIPER_ROCKET_VOLLEY = 12
const float VIPER_ROCKET_INTERVAL = 0.10
const int VIPER_STAGE3_MAX_ACTIVE_MISSILES = 50
const int VIPER_STAGE3_MIN_MISSILES = 30
const int VIPER_STAGE3_MAX_TARGETS = 5
const float VIPER_STAGE3_VOLLEY_COOLDOWN = 2.5

const float VIPER_RAILGUN_INTERVAL_MIN = 1.0
const float VIPER_RAILGUN_INTERVAL_MAX = 2.5
const int VIPER_RAILGUN_DAMAGE = 500

const float VIPER_PHASE_COOLDOWN_MIN = 8.0
const float VIPER_PHASE_COOLDOWN_MAX = 12.0
const float VIPER_PHASE_DURATION = 1.0
const int VIPER_PHASE_CHAIN_COUNT = 3
const float VIPER_PHASE_CHAIN_DELAY = 0.6

const float VIPER_REGEN_STAGE1 = 50.0
const float VIPER_REGEN_STAGE2 = 80.0
const float VIPER_REGEN_STAGE3 = 35.0

const int VIPER_MANEUVER_FLANK = 0
const int VIPER_MANEUVER_ASCEND = 1
const int VIPER_MANEUVER_DIVE = 2
const int VIPER_MANEUVER_RETREAT = 3

struct ViperFileState
{
	bool initialized
	entity boss
	entity mover
	entity animationRef
	entity harvester
	vector arenaMins
	vector arenaMaxs
	int stage
	int team
	bool retreating
	float nextPhaseTime
	float nextHarvesterHarassTime
	float nextRailgunTime
	int activeMissileCount
	int lastManeuver
	float maneuverChangeTime
}
ViperFileState file

void function ViperBoss_BeforeInit()
{
	ViperBoss_Init()
}

void function ViperBoss_Init()
{
	if ( file.initialized )
		return

	file.initialized = true
	PrecacheModel( VIPER_BOSS_MODEL )
	PrecacheWeapon( VIPER_BOSS_WEAPON )
	PrecacheWeapon( "mp_titanweapon_sniper" )
	ViperBossRockets_Init()
	PrecacheParticleSystem( $"P_xo_jet_fly_large" )
	PrecacheParticleSystem( $"P_xo_jet_fly_small" )
	PrecacheParticleSystem( $"P_titan_core_atlas_blast" )
	RegisterSignal( "ViperBossStop" )
	RegisterSignal( "ViperBossActionInterrupt" )
	RegisterSignal( "ViperBossRailgunInterrupt" )
	RegisterSignal( "ViperBossPhaseInterrupt" )
	RegisterSignal( "ViperBossStageRetreating" )
	RegisterSignal( "ViperBossStageExited" )
	RegisterSignal( "ViperBossDefeated" )
}

entity function ViperBoss_CreateStage1( ViperBossConfig config )
{
	return ViperBoss_CreateStage( config, 1 )
}

entity function ViperBoss_CreateStage2( ViperBossConfig config )
{
	return ViperBoss_CreateStage( config, 2 )
}

entity function ViperBoss_CreateStage3( ViperBossConfig config )
{
	return ViperBoss_CreateStage( config, 3 )
}

entity function ViperBoss_CreateStage( ViperBossConfig config, int stage )
{
	ViperBoss_Init()
	if ( IsValid( file.boss ) )
		ViperBoss_Destroy( file.boss )

	if ( config.arenaMins.x >= config.arenaMaxs.x || config.arenaMins.y >= config.arenaMaxs.y || config.arenaMins.z >= config.arenaMaxs.z )
		return null

	float healthScale = max( 0.1, config.healthMultiplier )
	entity boss = CreateNPCTitan( "titan_stryder_northstar_prime", config.team, config.origin, config.angles, [] )
	SetSpawnOption_AISettings( boss, VIPER_BOSS_AI_SETTINGS )
	DispatchSpawn( boss )
	boss.SetModel( VIPER_BOSS_MODEL )
	boss.SetSkin( 1 )
	boss.SetMaxHealth( int( VIPER_BOSS_BASE_HEALTH * healthScale ) )
	boss.SetHealth( boss.GetMaxHealth() )
	boss.SetTitle( "VIPER" )
	boss.SetNoTarget( true )
	boss.TakeWeapon( "mp_titanweapon_sniper" )
	boss.GiveWeapon( "mp_titanweapon_sniper", [ "BossTitanViper" ] )
	boss.TakeOffhandWeapon( 0 )
	boss.GiveOffhandWeapon( VIPER_BOSS_WEAPON, 0, [ "DarkMissiles" ] )
	entity rocketWeapon = boss.GetOffhandWeapon( 0 )
	if ( IsValid( rocketWeapon ) )
		rocketWeapon.AllowUse( false )

	entity ref = CreateScriptMover( boss.GetOrigin(), boss.GetAngles() )
	entity mover = CreateScriptMover( boss.GetOrigin(), boss.GetAngles() )
	boss.SetParent( ref, "", false, 0 )
	boss.Anim_DisableAnimDelta()
	ref.SetParent( mover, "", true, 0 )
	thread PlayAnimTeleport( boss, "s2s_viper_combat_float_idle", ref )

	thread EmitSoundOnEntity( boss, "diag_sp_bossFight_STS676_02_01_imc_viper" )
	thread ViperBoss_TauntThink( boss )
	ViperBoss_StartThrusterFX( boss )

	file.boss = boss
	file.mover = mover
	file.animationRef = ref
	file.harvester = config.harvester
	file.arenaMins = config.arenaMins
	file.arenaMaxs = config.arenaMaxs
	file.stage = stage
	file.team = config.team
	file.retreating = false
	file.nextPhaseTime = Time() + RandomFloatRange( VIPER_PHASE_COOLDOWN_MIN, VIPER_PHASE_COOLDOWN_MAX )
	file.nextHarvesterHarassTime = Time() + RandomFloatRange( 60.0, 75.0 )
	file.nextRailgunTime = Time() + RandomFloatRange( VIPER_RAILGUN_INTERVAL_MIN, VIPER_RAILGUN_INTERVAL_MAX )
	file.activeMissileCount = 0
	file.lastManeuver = VIPER_MANEUVER_ASCEND
	file.maneuverChangeTime = Time() + RandomFloatRange( 4.0, 8.0 )

	AddEntityCallback_OnDamaged( boss, ViperBoss_OnDamaged )
	thread ViperBoss_FlightThink( boss )
	thread ViperBoss_AttackThink( boss )
	if ( stage == 1 || stage == 2 )
		thread ViperBoss_RailgunThink( boss )
	if ( stage == 3 )
		thread ViperBoss_GatlingThink( boss )
	if ( stage == 3 )
		thread ViperBoss_TurretHuntThink( boss )
	thread ViperBoss_RegenThink( boss )
	thread ViperBoss_DeathThink( boss )
	return boss
}

void function ViperBoss_Destroy( entity boss )
{
	if ( !IsValid( boss ) )
		return

	boss.Signal( "ViperBossStop" )
	boss.Signal( "ViperBossActionInterrupt" )
	boss.Signal( "ViperBossRailgunInterrupt" )
	boss.Signal( "ViperBossPhaseInterrupt" )
	if ( boss == file.boss )
	{
		if ( IsValid( file.animationRef ) )
			file.animationRef.Destroy()
		if ( IsValid( file.mover ) )
			file.mover.Destroy()
		file.boss = null
		file.animationRef = null
		file.mover = null
		file.activeMissileCount = 0
	}
	if ( IsValid( boss ) )
		boss.Destroy()
}

void function ViperBoss_OnDamaged( entity boss, var damageInfo )
{
	if ( file.retreating || boss != file.boss || file.stage == 3 )
		return

	float remainingHealth = boss.GetHealth() - DamageInfo_GetDamage( damageInfo )
	if ( remainingHealth > boss.GetMaxHealth() * VIPER_BOSS_RETREAT_HEALTH_FRACTION )
		return

	DamageInfo_SetDamage( damageInfo, 0 )
	thread ViperBoss_Retreat( boss )
}

void function ViperBoss_Retreat( entity boss )
{
	if ( file.retreating || !IsValid( boss ) )
		return

	file.retreating = true
	boss.SetInvulnerable()
	boss.Signal( "ViperBossActionInterrupt" )
	boss.Signal( "ViperBossRailgunInterrupt" )
	boss.Signal( "ViperBossPhaseInterrupt" )
	EmitSoundOnEntity( boss, "diag_sp_bossFight_STS674_01_01_mcor_viper" )
	boss.Signal( "ViperBossStageRetreating", { stage = file.stage } )

	if ( IsValid( file.animationRef ) && IsValid( file.mover ) )
	{
		vector exitPoint = < file.mover.GetOrigin().x, file.mover.GetOrigin().y, file.arenaMaxs.z + 3000.0 >
		thread PlayAnim( boss, "s2s_viper_flight_move", file.animationRef )
		file.mover.NonPhysicsMoveTo( exitPoint, VIPER_BOSS_RETREAT_TIME, 0.2, 0.2 )
	}

	wait VIPER_BOSS_RETREAT_TIME
	if ( IsValid( boss ) )
	{
		boss.Signal( "ViperBossStageExited", { stage = file.stage } )
		ViperBoss_Destroy( boss )
	}
}

void function ViperBoss_FlightThink( entity boss )
{
	boss.EndSignal( "OnDestroy" )
	boss.EndSignal( "OnDeath" )
	boss.EndSignal( "ViperBossStop" )
	boss.EndSignal( "ViperBossActionInterrupt" )

	while ( true )
	{
		entity target = ViperBoss_GetTarget( boss )
		vector destination = ViperBoss_SelectDestination( boss, target )
		float moveTime

		switch ( file.stage )
		{
			case 1:
				moveTime = 2.5
				break
			case 2:
				moveTime = 2.0
				break
			default:
				moveTime = 1.5
				break
		}

		thread PlayAnim( boss, "s2s_viper_flight_move", file.animationRef, "", 0.15 )
		WaitFrame()
		ViperBoss_SetFlightPoseParams( boss, destination )
		file.mover.NonPhysicsMoveTo( destination, moveTime, 0.2, 0.2 )
		if ( IsValid( target ) )
		{
			vector faceDir = Normalize( target.GetOrigin() - file.mover.GetOrigin() )
			vector faceAngles = VectorToAngles( faceDir )
			float localY = faceAngles.y - file.mover.GetAngles().y
			while ( localY > 180.0 ) localY -= 360.0
			while ( localY < -180.0 ) localY += 360.0
			file.animationRef.NonPhysicsRotateTo( < 0, localY, 0 >, moveTime, moveTime * 0.3, moveTime * 0.3 )
		}
		wait moveTime
		ViperBoss_ClearFlightPoseParams( boss )
		WaitFrame()
		thread PlayAnim( boss, "s2s_viper_flight_move_idle", file.animationRef, "", 0.15 )
		wait file.stage == 3 ? 0.5 : 1.2
	}
}

void function ViperBoss_AttackThink( entity boss )
{
	boss.EndSignal( "OnDestroy" )
	boss.EndSignal( "OnDeath" )
	boss.EndSignal( "ViperBossStop" )
	boss.EndSignal( "ViperBossActionInterrupt" )

	while ( true )
	{
		entity target = ViperBoss_GetTarget( boss )

		if ( file.stage == 2 && Time() >= file.nextPhaseTime && IsValid( target ) )
		{
			waitthread ViperBoss_PhaseChase( boss, target )
			file.nextPhaseTime = Time() + RandomFloatRange( VIPER_PHASE_COOLDOWN_MIN, VIPER_PHASE_COOLDOWN_MAX )
			continue
		}

		if ( IsValid( file.harvester ) && Time() >= file.nextHarvesterHarassTime )
		{
			ViperBossRockets_FireVolley( boss, file.harvester, 6 )
			file.nextHarvesterHarassTime = Time() + RandomFloatRange( 60.0, 75.0 )
			file.activeMissileCount += 6
		}
		else if ( file.stage == 3 )
		{
			ViperBossRockets_FireDistributedVolley( boss )
		}
		else if ( IsValid( target ) )
		{
			ViperBossRockets_FireVolley( boss, target, VIPER_ROCKET_VOLLEY )
			file.activeMissileCount += VIPER_ROCKET_VOLLEY
		}

		wait file.stage == 3 ? VIPER_STAGE3_VOLLEY_COOLDOWN : RandomFloatRange( 8.0, 12.0 )
	}
}

void function ViperBoss_RailgunThink( entity boss )
{
	boss.EndSignal( "OnDestroy" )
	boss.EndSignal( "OnDeath" )
	boss.EndSignal( "ViperBossStop" )
	boss.EndSignal( "ViperBossActionInterrupt" )
	boss.EndSignal( "ViperBossRailgunInterrupt" )

	entity railgun = boss.GetMainWeapons()[0]
	if ( !IsValid( railgun ) )
		return

	OnThreadEnd(
		function() : ( boss )
		{
			if ( IsValid( boss ) )
				boss.Signal( "ViperBossRailgunInterrupt" )
		}
	)

	while ( true )
	{
		entity target = ViperBoss_GetTarget( boss )
		if ( !IsValid( target ) || !IsAlive( target ) )
		{
			wait 0.5
			continue
		}

		int attachID = railgun.LookupAttachment( "muzzle_flash" )
		if ( attachID <= 0 )
		{
			wait 1.0
			continue
		}

		vector muzzleAngles = boss.GetAttachmentAngles( attachID )
		vector muzzleForward = AnglesToForward( muzzleAngles )
		vector muzzlePos = boss.GetAttachmentOrigin( attachID ) + muzzleForward * 80

		vector targetPos = target.GetOrigin() + < 0, 0, 48 >
		vector dir = Normalize( targetPos - muzzlePos )

		ViperBoss_SnapFaceTarget( boss, target )
		ViperBoss_SetAimPoseParams( boss, target )
		wait 0.15
		railgun.FireWeaponBolt( muzzlePos, dir, 10000, damageTypes.largeCaliber, damageTypes.largeCaliber, false, 0 )
		EmitSoundOnEntity( boss, "Weapon_Sniper_Titan_NPC_Fire_3P" )
		ViperBoss_ClearAimPoseParams( boss )

		wait RandomFloatRange( VIPER_RAILGUN_INTERVAL_MIN, VIPER_RAILGUN_INTERVAL_MAX )
	}
}

void function ViperBoss_PhaseChase( entity boss, entity target )
{
	if ( !IsValid( target ) || !IsAlive( target ) )
		return

	boss.EndSignal( "ViperBossPhaseInterrupt" )

	for ( int chain = 0; chain < VIPER_PHASE_CHAIN_COUNT; chain++ )
	{
		if ( !IsValid( target ) || !IsAlive( target ) )
			return
		if ( !IsValid( boss ) || !IsAlive( boss ) )
			return

		int result = PhaseShift( boss, 0.0, VIPER_PHASE_DURATION )
		if ( !result )
			return

		vector targetOrigin = target.GetOrigin()
		vector direction = Normalize( targetOrigin - file.mover.GetOrigin() )
		vector side = < -direction.y, direction.x, 0.0 >

		float flankSign = chain % 2 == 0 ? 1.0 : -1.0
		float flankDist = RandomFloatRange( 400.0, 900.0 )
		float heightOffset = chain == 0 ? RandomFloatRange( 200.0, 500.0 ) : RandomFloatRange( -200.0, 300.0 )
		float behindDist = chain == 0 ? 300.0 : RandomFloatRange( 100.0, 400.0 )

		vector destination = targetOrigin - ( direction * behindDist ) + ( side * flankDist * flankSign ) + < 0, 0, heightOffset >
		destination = ViperBoss_ClampToArena( destination )
		file.mover.NonPhysicsMoveTo( destination, VIPER_PHASE_DURATION * 0.6, 0.0, 0.0 )

		boss.WaitSignal( "StopPhaseShift" )

		if ( IsValid( target ) && IsAlive( target ) )
		{
			ViperBoss_EMPBlast( boss, target )
			int volleySize = chain == 0 ? 8 : 4
			ViperBossRockets_FireVolley( boss, target, volleySize )
			file.activeMissileCount += volleySize
		}

		if ( chain < VIPER_PHASE_CHAIN_COUNT - 1 )
			wait VIPER_PHASE_CHAIN_DELAY
	}
}

void function ViperBoss_DeathThink( entity boss )
{
	boss.WaitSignal( "OnDeath" )
	if ( boss != file.boss || file.stage != 3 )
		return

	boss.Signal( "ViperBossDefeated", { stage = 3 } )
	if ( IsValid( file.animationRef ) )
		file.animationRef.Destroy()
	if ( IsValid( file.mover ) )
		file.mover.Destroy()
	file.boss = null
	file.activeMissileCount = 0
}

float function ViperBoss_CalculateThreat( entity boss, entity player )
{
	float threat = 10000.0
	threat -= Distance( boss.GetOrigin(), player.GetOrigin() )
	if ( player.IsTitan() )
		threat *= 3.0
	if ( IsValid( file.harvester ) && IsAlive( file.harvester ) )
	{
		if ( Distance( player.GetOrigin(), file.harvester.GetOrigin() ) < 1500.0 )
			threat *= 2.0
	}
	threat += player.GetHealth() * 0.5
	return max( threat, 1.0 )
}

entity function ViperBoss_GetTarget( entity boss )
{
	array<entity> threatList = ViperBoss_GetThreatList( boss )
	if ( threatList.len() == 0 )
		return null
	return threatList[ 0 ]
}

array<entity> function ViperBoss_GetThreatList( entity boss )
{
	array<entity> players = GetPlayerArray()
	array<entity> remaining
	array<float> scores

	foreach ( entity player in players )
	{
		if ( !IsAlive( player ) || player.GetTeam() == file.team )
			continue
		if ( IsCloaked( player ) )
			continue
		remaining.append( player )
		scores.append( ViperBoss_CalculateThreat( boss, player ) )
	}

	array<entity> result
	while ( remaining.len() > 0 )
	{
		int bestIdx = 0
		float bestScore = scores[ 0 ]
		for ( int i = 1; i < remaining.len(); i++ )
		{
			if ( scores[ i ] > bestScore )
			{
				bestScore = scores[ i ]
				bestIdx = i
			}
		}
		result.append( remaining[ bestIdx ] )
		remaining.remove( bestIdx )
		scores.remove( bestIdx )
	}
	return result
}

vector function ViperBoss_SelectDestination( entity boss, entity target )
{
	if ( !IsValid( target ) )
		return ViperBoss_RandomArenaPoint()

	if ( file.stage != 1 )
	{
		float distance = file.stage == 2 ? 1800.0 : 1200.0
		float angle = RandomFloatRange( 0.0, 360.0 )
		vector point = target.GetOrigin() + < cos( angle ) * distance, sin( angle ) * distance, RandomFloatRange( 350.0, 900.0 ) >
		return ViperBoss_ClampToArena( point )
	}

	if ( Time() >= file.maneuverChangeTime )
	{
		array<int> allManeuvers = [ VIPER_MANEUVER_FLANK, VIPER_MANEUVER_ASCEND, VIPER_MANEUVER_DIVE, VIPER_MANEUVER_RETREAT ]
		array<int> options
		foreach ( int m in allManeuvers )
		{
			if ( m != file.lastManeuver )
				options.append( m )
		}
		file.lastManeuver = options[ RandomInt( options.len() ) ]
		file.maneuverChangeTime = Time() + RandomFloatRange( 5.0, 10.0 )
	}

	vector origin = target.GetOrigin()
	vector direction = Normalize( origin - file.mover.GetOrigin() )
	vector right = < -direction.y, direction.x, 0.0 >
	float flankSign = CoinFlip() ? 1.0 : -1.0

	vector destination
	switch ( file.lastManeuver )
	{
		case VIPER_MANEUVER_FLANK:
			destination = origin + right * RandomFloatRange( 2000.0, 3000.0 ) * flankSign + < 0, 0, RandomFloatRange( 400.0, 700.0 ) >
			break

		case VIPER_MANEUVER_ASCEND:
			destination = origin + < RandomFloatRange( -400.0, 400.0 ), RandomFloatRange( -400.0, 400.0 ), RandomFloatRange( 1000.0, 1600.0 ) >
			break

		case VIPER_MANEUVER_DIVE:
			destination = origin + direction * RandomFloatRange( 600.0, 1200.0 ) + < 0, 0, RandomFloatRange( 100.0, 300.0 ) >
			break

		case VIPER_MANEUVER_RETREAT:
			destination = origin - direction * RandomFloatRange( 2500.0, 3500.0 ) + right * RandomFloatRange( -500.0, 500.0 ) + < 0, 0, RandomFloatRange( 600.0, 1000.0 ) >
			break
	}

	return ViperBoss_ClampToArena( destination )
}

vector function ViperBoss_RandomArenaPoint()
{
	return < RandomFloatRange( file.arenaMins.x, file.arenaMaxs.x ), RandomFloatRange( file.arenaMins.y, file.arenaMaxs.y ), RandomFloatRange( file.arenaMins.z, file.arenaMaxs.z ) >
}

vector function ViperBoss_ClampToArena( vector point )
{
	return < clamp( point.x, file.arenaMins.x, file.arenaMaxs.x ), clamp( point.y, file.arenaMins.y, file.arenaMaxs.y ), clamp( point.z, file.arenaMins.z, file.arenaMaxs.z ) >
}

void function ViperBoss_SetFlightPoseParams( entity boss, vector destination )
{
	vector start = boss.GetOrigin()
	vector dir = Normalize( < destination.x - start.x, destination.y - start.y, 0 > )
	float yaw = GraphCapped( dir.x, -0.5, 0.5, 45.0, -45.0 )
	float back = GraphCapped( dir.y, -0.8, 0.8, 45.0, -45.0 )

	int yawID = boss.LookupPoseParameterIndex( "move_yaw" )
	int backID = boss.LookupPoseParameterIndex( "move_yaw_backward" )
	if ( yawID >= 0 ) boss.SetPoseParameterOverTime( yawID, yaw, 0.8 )
	if ( backID >= 0 ) boss.SetPoseParameterOverTime( backID, back, 0.8 )
}

void function ViperBoss_ClearFlightPoseParams( entity boss )
{
	int yawID = boss.LookupPoseParameterIndex( "move_yaw" )
	int backID = boss.LookupPoseParameterIndex( "move_yaw_backward" )
	if ( yawID >= 0 ) boss.SetPoseParameterOverTime( yawID, 0, 0.5 )
	if ( backID >= 0 ) boss.SetPoseParameterOverTime( backID, 0, 0.5 )
}

void function ViperBoss_SetAimPoseParams( entity boss, entity target )
{
	vector dir = Normalize( target.GetOrigin() - boss.GetOrigin() )
	vector angles = VectorToAngles( dir )
	vector localAng = angles - < 0, 270, 0 >
	float yaw = GraphCapped( localAng.y, -90.0, 90.0, -45.0, 45.0 )
	float pitch = GraphCapped( localAng.x, -30.0, 30.0, -30.0, 30.0 )

	int yawID = boss.LookupPoseParameterIndex( "aim_yaw_scripted" )
	int pitchID = boss.LookupPoseParameterIndex( "aim_pitch_scripted" )
	if ( yawID >= 0 ) boss.SetPoseParameterOverTime( yawID, yaw, 0.3 )
	if ( pitchID >= 0 ) boss.SetPoseParameterOverTime( pitchID, pitch, 0.3 )
}

void function ViperBoss_ClearAimPoseParams( entity boss )
{
	int yawID = boss.LookupPoseParameterIndex( "aim_yaw_scripted" )
	int pitchID = boss.LookupPoseParameterIndex( "aim_pitch_scripted" )
	if ( yawID >= 0 ) boss.SetPoseParameterOverTime( yawID, 0, 0.3 )
	if ( pitchID >= 0 ) boss.SetPoseParameterOverTime( pitchID, 0, 0.3 )
}

void function ViperBoss_SnapFaceTarget( entity boss, entity target )
{
	vector faceDir = Normalize( target.GetOrigin() - file.mover.GetOrigin() )
	vector faceAngles = VectorToAngles( faceDir )
	vector currentAngles = file.animationRef.GetAngles()
	float currentY = currentAngles.y
	float localY = faceAngles.y - file.mover.GetAngles().y
	while ( localY > 180.0 ) localY -= 360.0
	while ( localY < -180.0 ) localY += 360.0
	float delta = fabs( localY - currentY )
	while ( delta > 180.0 ) delta -= 360.0
	float turnTime = clamp( delta / 180.0, 0.15, 0.6 )
	file.animationRef.NonPhysicsRotateTo( < 0, localY, 0 >, turnTime, turnTime * 0.3, turnTime * 0.3 )
}

entity function ViperBoss_CoreGlow( entity boss )
{
	entity core = CreateCoreEffect( boss, $"P_titan_core_atlas_blast" )
	entity shake = CreateShake( boss.GetOrigin(), 10.0, 5.0, 2.0, 2000.0 )
	return core
}

void function ViperBoss_CoreGlowCleanup( entity core )
{
	if ( IsValid( core ) )
		core.Destroy()
}

void function ViperBossRockets_FireDistributedVolley( entity boss )
{
	array<entity> threatList = ViperBoss_GetThreatList( boss )
	if ( threatList.len() == 0 )
		return

	int availableSlots = VIPER_STAGE3_MAX_ACTIVE_MISSILES - file.activeMissileCount
	int targetsNeeded = int( min( threatList.len(), VIPER_STAGE3_MAX_TARGETS ) )
	int missilesPerTarget = int( max( 6.0, float( VIPER_STAGE3_MIN_MISSILES ) / float( targetsNeeded ) ) )
	int totalMissiles = targetsNeeded * missilesPerTarget

	if ( totalMissiles > availableSlots )
		missilesPerTarget = int( max( 1.0, float( availableSlots ) / float( targetsNeeded ) ) )
	totalMissiles = targetsNeeded * missilesPerTarget

	if ( totalMissiles <= 0 )
		return

	EmitSoundOnEntity( boss, "northstar_rocket_warning" )
	entity coreGlow = ViperBoss_CoreGlow( boss )
	thread PlayAnim( boss, "s2s_viper_flight_core", file.animationRef, "", 0.1 )
	wait 0.3
	entity weapon = boss.GetOffhandWeapon( 0 )
	if ( !IsValid( weapon ) )
	{
		ViperBoss_CoreGlowCleanup( coreGlow )
		return
	}

	for ( int i = 0; i < totalMissiles; i++ )
	{
		int targetIndex = i % targetsNeeded
		entity target = threatList[ targetIndex ]
		if ( !IsValid( target ) || !IsAlive( target ) )
			continue

		string attachmentName = IsEven( i ) ? "SCRIPT_POD_R" : "SCRIPT_POD_L"
		int attachment = boss.LookupAttachment( attachmentName )
		if ( attachment <= 0 )
			continue

		vector targetPos = target.GetOrigin() + < 0, 0, 48 >
		vector muzzlePos = boss.GetAttachmentOrigin( attachment )
		vector muzzleForward = AnglesToForward( boss.GetAttachmentAngles( attachment ) )
		vector targetDirection = Normalize( targetPos - muzzlePos )
		vector launchDirection = Normalize( ( muzzleForward * 0.70 ) + ( targetDirection * 0.30 ) )

		StartParticleEffectOnEntity( boss, GetParticleSystemIndex( $"wpn_mflash_xo_rocket_shoulder" ), FX_PATTACH_POINT_FOLLOW, attachment )
		entity missile = weapon.FireWeaponMissile( muzzlePos, launchDirection, 1.0, DF_GIB | DF_IMPACT, damageTypes.explosive, false, PROJECTILE_NOT_PREDICTED )
		if ( IsValid( missile ) )
		{
			missile.SetOwner( boss )
			missile.DamageAliveOnly( true )
			missile.kv.lifetime = 8.0
			missile.DisableHibernation()
			SetTeam( missile, boss.GetTeam() )
			EmitSoundOnEntity( missile, "Weapon_Sidwinder_Projectile" )
			file.activeMissileCount++
			thread ViperBossRockets_HomingThink( missile, target, < 0, 0, RandomFloatRange( 0, 96 ) > )
		}
		wait VIPER_ROCKET_INTERVAL
	}
	ViperBoss_CoreGlowCleanup( coreGlow )
}

void function ViperBossRockets_FireVolley( entity boss, entity target, int missileCount )
{
	entity weapon = boss.GetOffhandWeapon( 0 )
	if ( !IsValid( weapon ) || !IsValid( target ) || !IsAlive( target ) )
		return

		EmitSoundOnEntity( boss, "northstar_rocket_warning" )
		entity coreGlow = ViperBoss_CoreGlow( boss )
		thread PlayAnim( boss, "s2s_viper_flight_core", file.animationRef, "", 0.1 )
		wait 0.3
		for ( int i = 0; i < missileCount; i++ )
	{
		if ( !IsValid( target ) || !IsAlive( target ) )
			return

		string attachmentName = IsEven( i ) ? "SCRIPT_POD_R" : "SCRIPT_POD_L"
		int attachment = boss.LookupAttachment( attachmentName )
		if ( attachment <= 0 )
			return

		vector targetPos = target.GetOrigin() + < 0, 0, 48 >
		vector muzzlePos = boss.GetAttachmentOrigin( attachment )
		vector muzzleForward = AnglesToForward( boss.GetAttachmentAngles( attachment ) )
		vector targetDirection = Normalize( targetPos - muzzlePos )
		vector launchDirection = Normalize( ( muzzleForward * 0.70 ) + ( targetDirection * 0.30 ) )

		StartParticleEffectOnEntity( boss, GetParticleSystemIndex( $"wpn_mflash_xo_rocket_shoulder" ), FX_PATTACH_POINT_FOLLOW, attachment )
		entity missile = weapon.FireWeaponMissile( muzzlePos, launchDirection, 1.0, DF_GIB | DF_IMPACT, damageTypes.explosive, false, PROJECTILE_NOT_PREDICTED )
		if ( IsValid( missile ) )
		{
			missile.SetOwner( boss )
			missile.DamageAliveOnly( true )
			missile.kv.lifetime = 8.0
			missile.DisableHibernation()
			SetTeam( missile, boss.GetTeam() )
			EmitSoundOnEntity( missile, "Weapon_Sidwinder_Projectile" )
			thread ViperBossRockets_HomingThink( missile, target, < 0, 0, RandomFloatRange( 0, 96 ) > )
		}
		wait VIPER_ROCKET_INTERVAL
	}
	ViperBoss_CoreGlowCleanup( coreGlow )
}

void function ViperBossRockets_HomingThink( entity missile, entity target, vector offset )
{
	missile.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ()
		{
			file.activeMissileCount = int( max( 0.0, float( file.activeMissileCount - 1 ) ) )
		}
	)

	float startTime = Time()
	while ( IsValid( target ) && IsAlive( target ) )
	{
		if ( !IsValid( missile ) )
			return
		missile.SetMissileTarget( target, offset )
		missile.SetHomingSpeeds( GraphCapped( Time() - startTime, 0.0, 3.0, 75.0, 150.0 ), 0 )
		wait 0.2
	}
}

// ViperBossRockets_Init() is defined in sp_weapon_viperbossrockets_s2s.nut

void function ViperBoss_TauntThink( entity boss )
{
	boss.EndSignal( "OnDestroy" )
	boss.EndSignal( "OnDeath" )
	boss.EndSignal( "ViperBossStop" )

	array<string> taunts = [
		"diag_sp_viperchat_STS670_01_01_mcor_viper",
		"diag_sp_viperchat_STS666_01_01_mcor_viper",
		"diag_sp_bossFight_STS673_01_01_mcor_viper",
		"diag_sp_bossFight_STS678_01_01_mcor_viper",
		"diag_sp_bossFight_STS678_02_01_mcor_viper",
		"diag_sp_bossFight_STS674_01_01_mcor_viper",
		"diag_sp_viperchat_STS677_03_01_mcor_viper",
	]

	wait RandomFloatRange( 15.0, 25.0 )
	while ( true )
	{
		if ( !IsValid( boss ) || !IsAlive( boss ) )
			return
		string line = taunts[ RandomInt( taunts.len() ) ]
		EmitSoundOnEntity( boss, line )
		wait RandomFloatRange( 18.0, 30.0 )
	}
}

void function ViperBoss_StartThrusterFX( entity boss )
{
	StartParticleEffectOnEntity( boss, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, boss.LookupAttachment( "FX_L_BOT_THRUST" ) )
	StartParticleEffectOnEntity( boss, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, boss.LookupAttachment( "FX_R_BOT_THRUST" ) )
	StartParticleEffectOnEntity( boss, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, boss.LookupAttachment( "FX_L_TOP_THRUST" ) )
	StartParticleEffectOnEntity( boss, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, boss.LookupAttachment( "FX_R_TOP_THRUST" ) )
}

void function ViperBoss_GatlingThink( entity boss )
{
	boss.EndSignal( "OnDestroy" )
	boss.EndSignal( "OnDeath" )
	boss.EndSignal( "ViperBossStop" )
	boss.EndSignal( "ViperBossActionInterrupt" )

	entity railgun = boss.GetMainWeapons()[0]
	if ( !IsValid( railgun ) )
		return

	wait RandomFloatRange( 5.0, 8.0 )
	while ( true )
	{
		entity target = ViperBoss_GetTarget( boss )
		if ( !IsValid( target ) || !IsAlive( target ) )
		{
			wait 1.0
			continue
		}

		for ( int i = 0; i < 40; i++ )
		{
			vector muzzlePos = boss.GetOrigin() + boss.GetForwardVector() * 100 + boss.GetUpVector() * 200
			vector targetPos = target.GetOrigin() + < RandomFloatRange( -80, 80 ), RandomFloatRange( -80, 80 ), RandomFloatRange( -50, 50 ) >
			vector dir = Normalize( targetPos - muzzlePos )
			railgun.FireWeaponBolt( muzzlePos, dir, 8000, damageTypes.largeCaliber, damageTypes.largeCaliber, false, 0 )
			wait 0.08
		}
		wait RandomFloatRange( 2.0, 4.0 )
	}
}

void function ViperBoss_EMPBlast( entity boss, entity target )
{
	if ( !IsValid( target ) || !IsAlive( target ) )
		return

	float empRadius = 800.0
	vector bossOrigin = boss.GetOrigin()
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsAlive( player ) || player.GetTeam() == file.team )
			continue
		if ( Distance( bossOrigin, player.GetOrigin() ) > empRadius )
			continue

		StatusEffect_AddTimed( player, eStatusEffect.emp, 1.0, 1.5, 0.5 )
	}
	EmitSoundOnEntity( boss, "Titan_PhaseDash_Activate_3P" )
}

void function ViperBoss_RegenThink( entity boss )
{
	boss.EndSignal( "OnDestroy" )
	boss.EndSignal( "OnDeath" )
	boss.EndSignal( "ViperBossStop" )

	float regenRate
	switch ( file.stage )
	{
		case 1: regenRate = VIPER_REGEN_STAGE1; break
		case 2: regenRate = VIPER_REGEN_STAGE2; break
		default: regenRate = VIPER_REGEN_STAGE3; break
	}

	while ( true )
	{
		wait 1.0
		if ( IsValid( boss ) && IsAlive( boss ) )
		{
			float newHealth = boss.GetHealth() + regenRate
			if ( newHealth > boss.GetMaxHealth() )
				newHealth = float( boss.GetMaxHealth() )
			boss.SetHealth( int( newHealth ) )
		}
	}
}

void function ViperBoss_TurretHuntThink( entity boss )
{
	boss.EndSignal( "OnDestroy" )
	boss.EndSignal( "OnDeath" )
	boss.EndSignal( "ViperBossStop" )
	boss.EndSignal( "ViperBossActionInterrupt" )

	wait 3.0
	while ( true )
	{
		array<entity> turrets = GetEntArrayByClass_Expensive( "npc_turret_mega" )
		array<entity> panels = GetEntArrayByClass_Expensive( "prop_control_panel" )
		entity bestTurret = null
		float bestDist = 999999.0

		foreach ( entity turret in turrets )
		{
			if ( !IsValid( turret ) || !IsAlive( turret ) )
				continue
			if ( turret.GetTeam() == file.team )
				continue
			float d = Distance( boss.GetOrigin(), turret.GetOrigin() )
			if ( d < bestDist )
			{
				bestDist = d
				bestTurret = turret
			}
		}

		if ( IsValid( bestTurret ) )
		{
			entity linkedPanel = null
			foreach ( entity panel in panels )
			{
				if ( !IsValid( panel ) )
					continue
				if ( !( "megaTurretControlTurret" in panel.s ) )
					continue
				if ( expect entity( panel.s.megaTurretControlTurret ) == bestTurret )
				{
					linkedPanel = panel
					break
				}
			}

			wait 0.3
			ViperBossRockets_FireVolley( boss, bestTurret, 10 )
			file.activeMissileCount += 10
			wait 0.5

			if ( !IsValid( bestTurret ) || !IsAlive( bestTurret ) )
			{
				if ( IsValid( linkedPanel ) )
					linkedPanel.Destroy()
			}
		}

		wait RandomFloatRange( 8.0, 15.0 )
	}
}

void function ViperBoss_CommandInit()
{
	#if SERVER
	AddClientCommandCallback( "viper_stage1", ViperBoss_CommandStage1 )
	AddClientCommandCallback( "viper_stage2", ViperBoss_CommandStage2 )
	AddClientCommandCallback( "viper_stage3", ViperBoss_CommandStage3 )
	AddClientCommandCallback( "viper_kill", ViperBoss_CommandKill )
	#endif
}

#if SERVER
bool function ViperBoss_CommandStage1( entity player, array<string> args )
{
	ViperBossConfig config = ViperBoss_ParseCommandArgs( player, args )
	entity boss = ViperBoss_CreateStage1( config )
	if ( IsValid( boss ) )
		Chat_ServerPrivateMessage( player, "\x1b[33m[Viper] \x1b[37mStage 1 created.", false )
	else
		Chat_ServerPrivateMessage( player, "\x1b[31m[Viper] Failed to create Stage 1.", false )
	return true
}

bool function ViperBoss_CommandStage2( entity player, array<string> args )
{
	ViperBossConfig config = ViperBoss_ParseCommandArgs( player, args )
	entity boss = ViperBoss_CreateStage2( config )
	if ( IsValid( boss ) )
		Chat_ServerPrivateMessage( player, "\x1b[33m[Viper] \x1b[37mStage 2 created. " + VIPER_PHASE_CHAIN_COUNT + "-hit phase chain, cooldown " + VIPER_PHASE_COOLDOWN_MIN + "-" + VIPER_PHASE_COOLDOWN_MAX + "s.", false )
	else
		Chat_ServerPrivateMessage( player, "\x1b[31m[Viper] Failed to create Stage 2.", false )
	return true
}

bool function ViperBoss_CommandStage3( entity player, array<string> args )
{
	ViperBossConfig config = ViperBoss_ParseCommandArgs( player, args )
	entity boss = ViperBoss_CreateStage3( config )
	if ( IsValid( boss ) )
		Chat_ServerPrivateMessage( player, "\x1b[33m[Viper] \x1b[37mStage 3 created. Min " + VIPER_STAGE3_MIN_MISSILES + " missiles distributed across up to " + VIPER_STAGE3_MAX_TARGETS + " targets, " + VIPER_STAGE3_MAX_ACTIVE_MISSILES + " max active.", false )
	else
		Chat_ServerPrivateMessage( player, "\x1b[31m[Viper] Failed to create Stage 3.", false )
	return true
}

bool function ViperBoss_CommandKill( entity player, array<string> args )
{
	if ( IsValid( file.boss ) )
	{
		ViperBoss_Destroy( file.boss )
		Chat_ServerPrivateMessage( player, "\x1b[33m[Viper] \x1b[37mBoss destroyed.", false )
	}
	else
	{
		Chat_ServerPrivateMessage( player, "\x1b[31m[Viper] No active boss to kill.", false )
	}
	return true
}

ViperBossConfig function ViperBoss_ParseCommandArgs( entity player, array<string> args )
{
	ViperBossConfig config

	bool hasOrigin = args.len() >= 3
	bool hasArenaMins = args.len() >= 6
	bool hasArenaMaxs = args.len() >= 9
	bool hasTeam = args.len() >= 10
	bool hasHealthMult = args.len() >= 11

	config.origin = player.GetOrigin()
	config.angles = < 0, player.EyeAngles().y, 0 >

	if ( hasOrigin )
		config.origin = < float( args[0] ), float( args[1] ), float( args[2] ) >

	if ( hasArenaMins )
		config.arenaMins = < float( args[3] ), float( args[4] ), float( args[5] ) >
	else
		config.arenaMins = < -3000, -3500, 700 >

	if ( hasArenaMaxs )
		config.arenaMaxs = < float( args[6] ), float( args[7] ), float( args[8] ) >
	else
		config.arenaMaxs = < 3000, 2900, 3000 >

	if ( hasTeam )
		config.team = int( args[9] )

	if ( hasHealthMult )
		config.healthMultiplier = float( args[10] )

	return config
}
#endif
