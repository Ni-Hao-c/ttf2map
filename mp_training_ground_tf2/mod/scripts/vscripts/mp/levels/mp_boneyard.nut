untyped
global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	print( "[Boneyard] CodeCallback_MapInit" )
	BoneyardShared_Init()
	MegaTurretControl_RegisterSite( < 1301.06, 1242.33, 488 > )
	MegaTurretControl_RegisterSite( < -2939.39, -2017.25, -96 > )
	MegaTurretControl_Init()
	AddCallback_GameStateEnter( eGameState.Postmatch, BoneyardDestroyAmbientFlyers )




	AddCallback_EntitiesDidLoad( Map_EntitiesDidLoad )
	SetEvacSpaceNode( CreateScriptRef( < -1700, -5500, -7600 >, < -3.620642, 270.307129, 0 > ) )
	// AddDeathCallback( "npc_marvin", WargamesDissolveDeadEntity )
	// AddSpawnCallback( "info_spawnpoint_marvin", AddMarvinSpawner )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnMarvinsForRound )



	
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

// void function WargamesDissolveDeadEntity( entity deadEnt, var damageInfo )
// {
// 	EmitSoundAtPosition( TEAM_UNASSIGNED, deadEnt.GetOrigin(), "Object_Dissolve" )
	
// 	if ( deadEnt.IsPlayer() )
// 		deadEnt.DissolveNonLethal( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 500 )
// 	else
// 		deadEnt.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 500 )
// }


// void function AddMarvinSpawner( entity spawn )
// {
// 	file.marvinSpawners.append( spawn )

// }

void function SpawnMarvinsForRound()
{
	// foreach ( entity spawner in file.marvinSpawners )
	// {
	// 	entity marvin = CreateMarvin( TEAM_UNASSIGNED, spawner.GetOrigin(), spawner.GetAngles() )
	// 	marvin.kv.health = 100
	// 	marvin.kv.max_health = 100
	// 	//marvin.kv.spawnflags = 516
	// 	marvin.kv.contents = ( int( marvin.kv.contents ) | CONTENTS_NOGRAPPLE )
	// 	DispatchSpawn( marvin )
	// 	HideName( marvin )

	// 	thread MarvinJobThink( marvin )
	// }


	
	// entity guy = CreateSpectre( TEAM_IMC, < -1988.02 , 2997.28 , 145.28 > ,< 0, 0, 0 > )
	// DispatchSpawn( guy )
	// guy.SetModel( $"models/humans/pilots/pilot_medium_geist_f.mdl")
}

void function CustomProp2( asset modelasset, vector origin, vector angles )
{
	entity prop = CreateEntity( "prop_script" )
	prop.SetValueForModelKey( modelasset )
	prop.SetOrigin( origin )
	prop.SetAngles( angles )
	prop.kv.fadedist = -1
	prop.kv.renderamt = 255
	prop.kv.rendercolor = "255 255 255"
	prop.kv.solid = 6
	prop.kv.modelscale = 0.8
	DispatchSpawn( prop )
}

void function Map_EntitiesDidLoad()
{
	#if SERVER
		print( "[Boneyard] Map_EntitiesDidLoad" )

		// The legacy client flyer-sequence API is unavailable in the current scripts.
		// Spawn replicated script movers and drive their patrols from the server instead.
		thread SpawnBoneyardFlyers()
	#endif





	
}

#if SERVER
const string BONEYARD_FLYER_VOCAL = "AI_Flyer_StartToFlyScream_3P"
const string BONEYARD_FLYER_HIT_VOCAL = "AI_Flyer_AttackScream_3P"
const float BONEYARD_FLYER_RESPAWN_DELAY = 20.0

enum eBoneyardFlyerState
{
	Patrol,
	Perched,
	Escaping
}

struct
{
	array<entity> patrolFlyers
	array<array<vector> > flightPaths
	array<vector> perchOrigins
	array<vector> perchAngles
	array<bool> perchOccupied
	bool flyersActive
} file

void function SpawnBoneyardFlyers()
{
	// Wait until the map has completed its entity setup; spawning earlier can remove
	// script movers during map initialization.
	wait 1.0
	file.flyersActive = true

	file.flightPaths = [
		[
			< -900, -900, 1150 >,
			< 900, -900, 1350 >,
			< 1100, 900, 1200 >,
			< -1100, 900, 1000 >
		],
		[
			< 900, 2700, 2300 >,
			< 2800, 3000, 2500 >,
			< 2700, 4300, 2200 >,
			< 800, 4100, 2100 >
		],
		[
			< -1300, 1300, 4300 >,
			< 500, 1200, 4500 >,
			< 700, 2700, 4200 >,
			< -1500, 2800, 4000 >
		]
	]

	file.perchOrigins = [
		< 624.846, 1645.21, 3670.67 >,
		< -151.801, 878.891, 1120.23 >,
		< -665.572, 1728.81, 1136.03 >,
		< 648.964, 2540.6, 730.031 >,
		< -116.918, 3678.84, 1259.76 >,
		< -513.885, -914.899, 342.719 >,
		< -5094.08, -3393.47, 987.466 >
	]

	file.perchAngles = [
		< 0, 137.329, 0 >,
		< 0, -44.5605, 0 >,
		< 0, 158.027, 0 >,
		< 0, -57.7881, 0 >,
		< 0, -83.9795, 0 >,
		< 0, 119.136, 0 >,
		< 0, -10.5908, 0 >
	]

	for ( int i = 0; i < file.perchOrigins.len(); i++ )
		file.perchOccupied.append( false )

	for ( int i = 0; i < file.flightPaths.len(); i++ )
	{
		SpawnBoneyardPatrolFlyer( i )
	}

}

void function SpawnBoneyardPatrolFlyer( int pathIndex )
{
	array<vector> flightPath = file.flightPaths[pathIndex]
	vector initialDirection = flightPath[1] - flightPath[0]
	entity flyer = CreateServerFlyer( flightPath[0], VectorToAngles( initialDirection ), 100000.0, 12000.0 )
	flyer.s.boneyardState <- eBoneyardFlyerState.Patrol
	flyer.s.boneyardPerchIndex <- -1
	flyer.s.boneyardPathIndex <- pathIndex
	file.patrolFlyers.append( flyer )

	thread BoneyardFlyerPatrol( flyer, pathIndex )
	thread BoneyardFlyerAmbientEffects( flyer )
	thread BoneyardFlyerDamageReaction( flyer )
	thread BoneyardPatrolFlyerRespawn( flyer, pathIndex )
}

void function BoneyardPatrolFlyerRespawn( entity flyer, int pathIndex )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.WaitSignal( "FlyerDeath" )
	BoneyardReleasePerch( flyer )
	file.patrolFlyers.fastremovebyvalue( flyer )
	wait BONEYARD_FLYER_RESPAWN_DELAY

	if ( file.flyersActive )
		SpawnBoneyardPatrolFlyer( pathIndex )

	if ( IsValid( flyer ) )
		flyer.Destroy()
}

void function BoneyardDestroyAmbientFlyers()
{
	file.flyersActive = false

	foreach ( entity flyer in file.patrolFlyers )
	{
		if ( IsValid( flyer ) )
			flyer.Destroy()
	}

	file.patrolFlyers.clear()
}

void function BoneyardFlyerAmbientEffects( entity flyer )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "FlyerDeath" )

	// Keep the flock from sounding synchronized while it circles the map.
	wait RandomFloatRange( 4.0, 10.0 )

	while ( true )
	{
		if ( flyer.s.boneyardState == eBoneyardFlyerState.Patrol )
			EmitSoundOnEntity( flyer, BONEYARD_FLYER_VOCAL )
		wait RandomFloatRange( 12.0, 24.0 )
	}
}

void function BoneyardFlyerPatrol( entity flyer, int pathIndex )
{
	array<vector> flightPath = file.flightPaths[pathIndex]
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "BoneyardFlyerEscape" )
	flyer.EndSignal( "BoneyardFlyerStateChanged" )

	// Keep the wing animation running while the script mover follows its route.
	flyer.Anim_Play( "fl_flap_cycle" )

	const float FLY_SPEED = 500.0
	int nextPoint = 1
	float landAtTime = Time() + RandomFloatRange( 45.0, 75.0 )

	while ( true )
	{
		vector destination = flightPath[nextPoint]
		vector direction = destination - flyer.GetOrigin()
		float distance = Distance( flyer.GetOrigin(), destination )

		if ( distance > 1.0 )
		{
			float moveTime = distance / FLY_SPEED
			flyer.RotateTo( VectorToAngles( direction ), 0.25, 0.0, 0.0 )
			flyer.MoveTo( destination, moveTime, 0.0, 0.0 )
			wait moveTime
		}

		if ( Time() >= landAtTime )
		{
			int perchIndex = BoneyardFindClosestFreePerch( flyer.GetOrigin() )
			if ( perchIndex >= 0 )
			{
				BoneyardFlyerLandAtPerch( flyer, perchIndex )
				return
			}

			landAtTime = Time() + 10.0
		}

		wait 0.1
		nextPoint = ( nextPoint + 1 ) % flightPath.len()
	}
}

int function BoneyardFindClosestFreePerch( vector origin )
{
	int closestIndex = -1
	float closestDistance = 99999999.0

	for ( int i = 0; i < file.perchOrigins.len(); i++ )
	{
		if ( file.perchOccupied[i] )
			continue

		float distance = DistanceSqr( origin, file.perchOrigins[i] )
		if ( distance < closestDistance )
		{
			closestDistance = distance
			closestIndex = i
		}
	}

	return closestIndex
}

void function BoneyardFlyerLandAtPerch( entity flyer, int perchIndex )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "FlyerDeath" )

	file.perchOccupied[perchIndex] = true
	flyer.Signal( "BoneyardFlyerStateChanged" )
	flyer.EndSignal( "BoneyardFlyerStateChanged" )

	entity animRef = CreateScriptRef( file.perchOrigins[perchIndex], file.perchAngles[perchIndex] )
	OnThreadEnd(
		function() : ( animRef )
		{
			if ( IsValid( animRef ) )
				animRef.Destroy()
		}
	)

	waitthread PlayAnimTeleport( flyer, "fl_land_flat", animRef )

	if ( !IsValid( flyer ) )
		return

	flyer.s.boneyardState = eBoneyardFlyerState.Perched
	flyer.s.boneyardPerchIndex = perchIndex
	thread BoneyardFlyerPerchedThink( flyer, perchIndex )
}

void function BoneyardFlyerPerchedThink( entity flyer, int perchIndex )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "FlyerDeath" )
	flyer.EndSignal( "BoneyardFlyerEscape" )
	flyer.EndSignal( "BoneyardFlyerStateChanged" )

	flyer.Anim_Play( "fl_perched_idle" )
	float takeoffTime = Time() + RandomFloatRange( 20.0, 40.0 )

	while ( Time() < takeoffTime )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( IsAlive( player ) && DistanceSqr( flyer.GetOrigin(), player.GetOrigin() ) < 1024 * 1024 )
			{
				BoneyardFlyerResumePatrol( flyer, perchIndex )
				return
			}
		}

		wait 1.0
	}

	BoneyardFlyerResumePatrol( flyer, perchIndex )
}

void function BoneyardFlyerResumePatrol( entity flyer, int perchIndex )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "FlyerDeath" )

	BoneyardReleasePerch( flyer )
	flyer.Signal( "BoneyardFlyerStateChanged" )
	flyer.EndSignal( "BoneyardFlyerStateChanged" )
	flyer.s.boneyardState = eBoneyardFlyerState.Patrol

	entity animRef = CreateScriptRef( flyer.GetOrigin(), flyer.GetAngles() )
	OnThreadEnd(
		function() : ( animRef )
		{
			if ( IsValid( animRef ) )
				animRef.Destroy()
		}
	)

	waitthread PlayAnimTeleport( flyer, "fl_perched_takeoff", animRef )

	if ( IsValid( flyer ) )
	{
		int pathIndex = BoneyardFindClosestFlightPath( flyer.GetOrigin() )
		flyer.s.boneyardPathIndex = pathIndex
		thread BoneyardFlyerPatrol( flyer, pathIndex )
	}
}

int function BoneyardFindClosestFlightPath( vector origin )
{
	int closestIndex = 0
	float closestDistance = 99999999.0

	for ( int i = 0; i < file.flightPaths.len(); i++ )
	{
		float distance = DistanceSqr( origin, file.flightPaths[i][0] )
		if ( distance < closestDistance )
		{
			closestDistance = distance
			closestIndex = i
		}
	}

	return closestIndex
}

void function BoneyardReleasePerch( entity flyer )
{
	int perchIndex = expect int( flyer.s.boneyardPerchIndex )
	if ( perchIndex >= 0 && perchIndex < file.perchOccupied.len() )
		file.perchOccupied[perchIndex] = false

	flyer.s.boneyardPerchIndex = -1
}

void function BoneyardFlyerDamageReaction( entity flyer )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "FlyerDeath" )
	flyer.WaitSignal( "OnDamaged" )

	if ( flyer.s.health <= 0 )
		return

	EmitSoundOnEntity( flyer, BONEYARD_FLYER_HIT_VOCAL )
	BoneyardReleasePerch( flyer )
	flyer.s.boneyardState = eBoneyardFlyerState.Escaping
	flyer.Signal( "BoneyardFlyerStateChanged" )
	flyer.Signal( "BoneyardFlyerEscape" )
	thread BoneyardFlyerEscape( flyer )
}

void function BoneyardFlyerEscape( entity flyer )
{
	flyer.EndSignal( "OnDestroy" )
	flyer.EndSignal( "FlyerDeath" )

	vector start = flyer.GetOrigin()
	vector destination = start + flyer.GetForwardVector() * 6000.0 + < 0, 0, 1800 >
	destination = ClampToWorldspace( destination )

	float travelTime = Distance( start, destination ) / 1400.0
	flyer.Anim_Play( "fl_flap_cycle" )
	flyer.RotateTo( VectorToAngles( destination - start ), 0.15, 0.0, 0.0 )
	flyer.MoveTo( destination, travelTime, 0.0, 0.0 )
	wait travelTime

	if ( !IsValid( flyer ) || !file.flyersActive )
		return

	// A hit scatters the flyer temporarily; it then returns to its assigned patrol.
	wait RandomFloatRange( 8.0, 16.0 )

	if ( !IsValid( flyer ) || !file.flyersActive )
		return

	int pathIndex = expect int( flyer.s.boneyardPathIndex )
	vector returnPosition = file.flightPaths[pathIndex][0]
	vector returnDirection = returnPosition - flyer.GetOrigin()
	float returnTime = Distance( flyer.GetOrigin(), returnPosition ) / 1400.0

	flyer.RotateTo( VectorToAngles( returnDirection ), 0.15, 0.0, 0.0 )
	flyer.MoveTo( returnPosition, returnTime, 0.0, 0.0 )
	wait returnTime

	if ( IsValid( flyer ) && file.flyersActive )
	{
		flyer.s.boneyardState = eBoneyardFlyerState.Patrol
		thread BoneyardFlyerPatrol( flyer, pathIndex )
		thread BoneyardFlyerDamageReaction( flyer )
	}
}
#endif
