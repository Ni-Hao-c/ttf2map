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


	
	AddSpawnCallback( "env_fog_controller", InitFogController )

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

	


	
}

void function InitFogController( entity fogController )
{
	// fogController.kv.fogztop = GetVisibleFogTop()
	// fogController.kv.fogzbottom = GetVisibleFogBottom()
	// fogController.kv.foghalfdisttop = "60000"
	// fogController.kv.foghalfdistbottom = "200"
	// fogController.kv.fogdistoffset = "0"
	// fogController.kv.fogdensity = ".85"

	// fogController.kv.forceontosky = true
	//fogController.kv.foghalfdisttop = "10000"
		fogController.kv.fogenable = " 0 "


	// 	"spawnflags" "0"
// "spawnclass" "reFog"
// "minfadetime" "1.0"
// "fogcolorstrength" "1.0"
// "fogangles" "-0 90 0"
// "scale" "1"
// "angles" "19.3391 44.7214 18.1569"
// "origin" "-734 586 3302"
// "useworldfog" "1"
// "use_angles" "1"
// "forceontosky" "1"
// "fogztop" "850"
// "fogzbottom" "650"
// "foghalfdisttop" "800"
// "foghalfdistbottom" "4000"
// "fogenable" "1"
// "fogdistoffset" "600"
// "fogdirhalfangle" "70"
// "fogdircolorstrength" ".8"
// "fogdircolor" "255 242 170"
// "fogdensity" ".8"
// "fogcolor" "194 237 255"
// "fogblend" "1"
//"farz" "-1"

}