untyped
global function CodeCallback_MapInit


struct {

	array<entity> marvinSpawners
	array<entity> TurretSpawners


} file





void function CodeCallback_MapInit()
{
	MegaTurretControl_RegisterSite( < -1443.77, -1975.52, 0.999 > )
	MegaTurretControl_RegisterSite( < 1443.77, 1975.52, 0.999 > )
	MegaTurretControl_RegisterSite( < 2604.23, -3137.52, 280.999 > )
	MegaTurretControl_RegisterSite( < -2604.23, 3137.52, 280.999 > )
	MegaTurretControl_Init()




	AddCallback_EntitiesDidLoad( Map_EntitiesDidLoad )
	SetEvacSpaceNode( CreateScriptRef( < -1700, -5500, -7600 >, < -3.620642, 270.307129, 0 > ) )
	AddDeathCallback( "npc_marvin", WargamesDissolveDeadEntity )
	AddSpawnCallback( "info_spawnpoint_marvin", AddMarvinSpawner )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnMarvinsForRound )



	
	// Load Frontier Defense Data
	if( GameRules_GetGameMode() == FD )
		initFrontierDefenseData()
}

void function WargamesDissolveDeadEntity( entity deadEnt, var damageInfo )
{
	EmitSoundAtPosition( TEAM_UNASSIGNED, deadEnt.GetOrigin(), "Object_Dissolve" )
	
	if ( deadEnt.IsPlayer() )
		deadEnt.DissolveNonLethal( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 500 )
	else
		deadEnt.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 500 )
}


void function AddMarvinSpawner( entity spawn )
{
	file.marvinSpawners.append( spawn )

}

void function SpawnMarvinsForRound()
{
	foreach ( entity spawner in file.marvinSpawners )
	{
		entity marvin = CreateMarvin( TEAM_UNASSIGNED, spawner.GetOrigin(), spawner.GetAngles() )
		marvin.kv.health = 100
		marvin.kv.max_health = 100
		//marvin.kv.spawnflags = 516
		marvin.kv.contents = ( int( marvin.kv.contents ) | CONTENTS_NOGRAPPLE )
		DispatchSpawn( marvin )
		HideName( marvin )

		thread MarvinJobThink( marvin )
	}



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


	PrecacheModel( $"models/IMC_base/thumper_platform_grid_corner_03.mdl" )
	entity Prop10450 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < 1806, 2826.13, 216.00 >, < 0, 0, 90 > )
//	entity Prop10451 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < -1484, 1496.00, 216.00 >, < 0, 90, 90 > )
//	entity Prop10452 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < -332, 1504.00, 176.00 >, < 0, -90, 90 > )
//	entity Prop10453 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < 764, -2104.00, 162.00 >, < 0, -90, 90 > )
//	entity Prop10454 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < 1060, -2104.00, 162.00 >, < 0, 90, 90 > )
//	entity Prop10455 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < -456, -2268.00, 200.00 >, < 0, 180, 90 > )
	entity Prop10456 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < 440, 2420.00, 200.00 >, < 0, 180, 90 > )
	entity Prop10457 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < -456, -2404.00, 200.00 >, < 0, 0, 90 > )
//	entity Prop10458 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < 1484, -1496.00, 216.00 >, < 0, -90, 90 > )
//	entity Prop10459 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < 332, -1504.00, 176.00 >, < 0, 90, 90 > )
	entity Prop10460 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < -1806, -2826.13, 216.00 >, < 0, 180, 90 > )
	entity Prop10461 = CustomProp2( $"models/IMC_base/thumper_platform_grid_corner_03.mdl", < 440, 2284.00, 200.00 >, < 0, 0, 90 > )



	
}
