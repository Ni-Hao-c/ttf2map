global function initFrontierDefenseData





struct {

	vector position = < 1872.01 , 3427.27 , -5.96875 >  // 采集机位�?
	array<vector> dropspawnpoints 
	array<vector> titanspawnpoints 

	// 按采集机分方�?
	array<vector> titanNorth
	array<vector> titanSouth
	array<vector> titanEast
	array<vector> titanWest
	array<vector> dropNorth
	array<vector> dropSouth
	array<vector> dropEast
	array<vector> dropWest

}file


void function initFrontierDefenseData()
{
	useCustomFDLoad = true
	AddCallback_RegisterCustomFDContent( RegisterCustomFDContent )

	// 收集出生点并按采集机分方向——必须在波次代码之前完成
	InitSpawnPointArrays()

// routes[ "hallwayShort" ] <- []
	// routes[ "hallwayShort" ].append( < -2524, -1997, 644 > )
	// routes[ "hallwayShort" ].append( < -4572, -2684, 718 > )
	// routes[ "hallwayShort" ].append( < -6273, -1256, 516 > )
	// routes[ "hallwayShort" ].append( < -7533, -467, 576 > )

	// 	//步兵 infantry


    routes[ "infantryleftRoadMain" ] <- []
    routes[ "infantryleftRoadMain" ].append(< -2076.35 , -2432.48 , -43.4339 > )
    routes[ "infantryleftRoadMain" ].append(< -2003.87 , -1026.52 , -30.9544 > )
    routes[ "infantryleftRoadMain" ].append(< -2140.94 , 26.797 , 54.0313 > )
    routes[ "infantryleftRoadMain" ].append(< -2396.7 , 1008.02 , -28.0527 > )
    routes[ "infantryleftRoadMain" ].append(< -2462.21 , 1916.45 , -43.4009 > )
    routes[ "infantryleftRoadMain" ].append(< -1612.66 , 2333.43 , -29.3545 > )
    routes[ "infantryleftRoadMain" ].append(< -685.361 , 2803.59 , -39.2158 > )
    routes[ "infantryleftRoadMain" ].append(< 606.522 , 2990.57 , -30.2237 > )
    routes[ "infantryleftRoadMain" ].append(< 1199.14 , 3053.34 , -1.96875 > )
    routes[ "infantryleftRoadMain" ].append( < 1747.58 , 3105.71 , -5.96875 > )
    
    

	

 


 	AddStationaryAIPosition(< 3036.25 , -3636.36 , -23.272 > ,  eStationaryAIPositionTypes.MORTAR_TITAN  )

	



    AddStationaryAIPosition( < 253.188 , -3524.15 , 294.031 > , eStationaryAIPositionTypes.LAUNCHER_REAPER )
    AddStationaryAIPosition( < -317.115 , -3242.93 , 350.031 > , eStationaryAIPositionTypes.LAUNCHER_REAPER )



    AddStationaryAIPosition( < -126.947 , -3481.07 , 134.031 > , eStationaryAIPositionTypes.MORTAR_SPECTRE )
    AddStationaryAIPosition( < 2113.81 , -3256.76 , -5.96875 > , eStationaryAIPositionTypes.MORTAR_SPECTRE )



	AddStationaryAIPosition( < 1626.7 , -2136.1 , -8.9972 > , eStationaryAIPositionTypes.SNIPER_TITAN )
	AddStationaryAIPosition( < 661.777 , -2649.12 , -28.9483 > , eStationaryAIPositionTypes.SNIPER_TITAN )





	
    PlaceFDShop(    < 1774.67 , 4186.63 , 5.9535 >  , < 0, 45, 0 > )
	SetFDGroundSpawn( < 1466 , 2949.11 , 134.031 > , < 0, 85, 0 > )
	OverrideFDHarvesterLocation(  < 1872.01 , 3427.27 , -5.96875 > , < 0, 135, 0 > )

  


    
    AddFDDropPodSpawn(< 1369.21 , 3048.35 , 270.031 > )
    //AddFDDropPodSpawn(< 1289.53 , 4330.12 , 7.0937 > )
    //AddFDDropPodSpawn(< 2398.65 , 4303.17 , 42.7243 > )


	
	AddWaveAnnouncement( "fd_introMedium" )
	AddWaveAnnouncement( "fd_waveTypeTicks" )
	AddWaveAnnouncement( "fd_waveTypeCloakDrone" )
	AddWaveAnnouncement( "fd_waveComboArcNuke" )
	AddWaveAnnouncement( "fd_waveComboMultiMix" )


	// 波次配置 �?方向数组: titanNorth/South/East/West, dropNorth/South/East/West
	// ══════════�?波次1: 纯步�?~100 ══════════�?
	// 主力:�?侧翼:�?偷袭:西Stalker 后方炮击:北Mortar
	array<WaveSpawnEvent> wave1
	WaveSpawn_Announce( wave1, "fd_waveTypeInfantry", 0.0 )
	WaveSpawn_Delay( wave1, 1.0 )
	WaveSpawn_ViperBoss( wave1, 1, [ <0,0,500> ], 90 )
	//WaveSpawn_ETitanSpawn( wave1, eFDT.all, file.titanWest, 0, "", 0.8, "" )
	//WaveSpawn_ETitanSpawn( wave1, eFDT.ArcNIU, file.titanWest, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	// 阶段1: �?主力) + �?侧翼) 步兵�?
	for ( int i = 0; i < 2; i++ )
	{
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", file.dropEast[ RandomInt(file.dropEast.len()) ], 0.0, "", 0.3 )
		WaveSpawn_WaitEnemyAliveAmount( wave1, 12 )
	}
	WaveSpawn_WaitEnemyAliveAmount( wave1, 10 )

	// 阶段2: 西面Stalker偷袭 + 继续南面主力
	for ( int i = 0; i < 3; i++ )
	{	
		WaveSpawn_WaitEnemyAliveAmount( wave1, 16 )
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 0.0, "", 0.2 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", file.dropWest[ RandomInt(file.dropWest.len()) ], 0.0, "", 0.4, "fd_waveTypeStalkers" )
	}
	WaveSpawn_WaitEnemyAliveAmount( wave1, 16 )

	// 阶段3: 北面MortarSpectre后方炮击 + 南面步兵 + 东面Stalker
	for ( int i = 0; i < 6; i++ )
	{	
		WaveSpawn_WaitEnemyAliveAmount( wave1, 20 )
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", file.dropEast[ RandomInt(file.dropNorth.len()) ], 0.0, "", 0.3)
		WaveSpawn_InfantrySpawn( wave1, "MortarSpectre", file.dropSouth[ RandomInt(file.dropNorth.len()) ], 0.0, "", 0.3)
		WaveSpawn_InfantrySpawn( wave1, "PodGrunt", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 0.0, "", 0.2 )
		WaveSpawn_InfantrySpawn( wave1, "Stalker", file.dropEast[ RandomInt(file.dropEast.len()) ], 0.0, "", 0.3 )
	}
	WaveSpawn_WaitEnemyAliveAmount( wave1, 0 )
	WaveSpawnEvents.append( wave1 )

	// ══════════�?波次2: 混合 ~70 ══════════�?
	// 主力:�?东泰�?步兵 侧翼:西Reaper 偷袭:北Stalker
	array<WaveSpawnEvent> wave2
	WaveSpawn_Announce( wave2, "fd_waveTypeTicks", 0.0 )

	// 阶段1: 南面+东面泰坦主力
	for ( int i = 0; i < 3; i++ )
	{
		WaveSpawn_ReaperSpawn( wave2, "TickReaper", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 90, "", 0.5 )
		WaveSpawn_ReaperSpawn( wave2, "TickReaper", file.dropEast[ RandomInt(file.dropEast.len()) ], 90, "", 0.5 )
		WaveSpawn_ETitanSpawn( wave2, eFDT.all, file.titanSouth, 180, "", 1.0, "" )
		WaveSpawn_ETitanSpawn( wave2, eFDT.all, file.titanEast, 180, "", 1.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 8 )
	}
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 90, "", 0.5 )
	WaveSpawn_ReaperSpawn( wave2, "TickReaper", file.dropEast[ RandomInt(file.dropEast.len()) ], 90, "", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 6 )

	// 阶段2: 西面Reaper侧翼骚扰 + 东面步兵
	for ( int i = 0; i < 3; i++ )
	{
		WaveSpawn_ETitanSpawn( wave2, eFDT.all, file.titanSouth, 180, "", 1.0, "" )
		WaveSpawn_InfantrySpawn( wave2, "PodGrunt", file.dropEast[ RandomInt(file.dropEast.len()) ], 0.0, "", 0.2 )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_ReaperSpawn( wave2, "TickReaper", file.dropWest[ RandomInt(file.dropWest.len()) ], 90, "", 0.4 )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 16 )
	}
	WaveSpawn_WaitEnemyAliveAmount( wave2, 8 )

	// 阶段3: 北面Stalker偷袭 + 精英Arc泰坦收尾
	for ( int i = 0; i < 4; i++ )
	{
		WaveSpawn_ETitanSpawn( wave2, eFDT.arc, file.titanSouth, 180, "", 1.5, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		WaveSpawn_InfantrySpawn( wave2, "Stalker", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_InfantrySpawn( wave2, "MortarSpectre", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_WaitEnemyAliveAmount( wave2, 10 )
	}
	WaveSpawn_ETitanSpawn( wave2, eFDT.arc, file.titanSouth, 180, "", 1.5, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ETitanSpawn( wave2, eFDT.arc, file.titanEast, 180, "", 1.5, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_ETitanSpawn( wave2, eFDT.arc, file.titanNorth, 180, "", 1.5, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	WaveSpawn_WaitEnemyAliveAmount( wave2, 0 )
	WaveSpawnEvents.append( wave2 )

	// ══════════�?波次3: 泰坦潮汐 ~85 ══════════�?
	// 主力:�?东泰坦集�?侧翼:西Reaper�?偷袭:北精英Arc
	array<WaveSpawnEvent> wave3
	WaveSpawn_Announce( wave3, "fd_incReaperClump", 0.0 )

	// 阶段1: �?东泰坦集�?+ 西面Reaper
	for ( int i = 0; i < 5; i++ )
	{
		WaveSpawn_ETitanSpawn( wave3, eFDT.all, file.titanSouth, 180, "", 0.8, "" )
		WaveSpawn_ETitanSpawn( wave3, eFDT.all, file.titanEast, 180, "", 0.8, "" )
		WaveSpawn_ReaperSpawn( wave3, "TickReaper", file.dropWest[ RandomInt(file.dropWest.len()) ], 90, "", 0.5 )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 10 )
	}
	for ( int i = 0; i < 5; i++ )
		WaveSpawn_ReaperSpawn( wave3, "TickReaper", file.dropWest[ RandomInt(file.dropWest.len()) ], 90, "", 0.5 )
	WaveSpawn_WaitEnemyAliveAmount( wave3, 12 )

	// 阶段2: Reaper�?+ 东面步兵
	for ( int i = 0; i < 8; i++ )
	{
		WaveSpawn_ReaperSpawn( wave3, "TickReaper", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 90, "", 0.3 )
		WaveSpawn_ReaperSpawn( wave3, "Reaper", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 90, "", 0.3 )
		WaveSpawn_InfantrySpawn( wave3, "PodGrunt", file.dropEast[ RandomInt(file.dropEast.len()) ], 0.0, "", 0.2 )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 24 )
	}
	WaveSpawn_WaitEnemyAliveAmount( wave3, 16 )

	// 阶段3: nan面精英Arc + 四方向全力输�?
	for ( int i = 0; i < 5; i++ )
	{
		WaveSpawn_ETitanSpawn( wave3, eFDT.arc, file.titanSouth, 180, "", 0.8, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		WaveSpawn_ETitanSpawn( wave3, eFDT.all, file.titanSouth, 180, "", 0.8, "" )
		WaveSpawn_ETitanSpawn( wave3, eFDT.all, file.titanSouth, 180, "", 0.8, "" )
		WaveSpawn_InfantrySpawn( wave3, "Stalker", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_InfantrySpawn( wave3, "MortarSpectre", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_WaitEnemyAliveAmount( wave3, 20 )
	}
	WaveSpawn_WaitEnemyAliveAmount( wave3, 0 )
	WaveSpawnEvents.append( wave3 )

	// ══════════�?波次4: 泰坦军团 ~65 ══════════�?
	// 主力:�?�?西泰�?侧翼:北Mortar 偷袭:西Reaper
	array<WaveSpawnEvent> wave4
	WaveSpawn_Announce( wave4, "fd_soonNukeTitans", 0.0 )
	WaveSpawn_ViperBoss( wave4, 2 , [ <0,0,500> ], 90 )

	// 阶段1: 2方向泰坦压�?
	for ( int i = 0; i < 8; i++ )
	{
		WaveSpawn_ETitanSpawn( wave4, eFDT.all, file.titanEast, 180, "", 0.6, "" )
		WaveSpawn_ETitanSpawn( wave4, eFDT.all, file.titanEast, 180, "", 0.6, "" )
		//WaveSpawn_ETitanSpawn( wave4, eFDT.all, file.titanWest, 180, "", 0.6, "" )
		WaveSpawn_ReaperSpawn( wave4, "TickReaper", file.dropWest[ RandomInt(file.dropWest.len()) ], 90, "", 0.5 )
		WaveSpawn_WaitEnemyAliveAmount( wave4, 24 )
	}

	// 阶段2: 北面MortarSpectre后方炮击 + 南面步兵
	for ( int i = 0; i < 10; i++ )
	{
		//WaveSpawn_InfantrySpawn( wave4, "Stalker", file.dropNorth[ RandomInt(file.dropSouth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_InfantrySpawn( wave4, "Spectre", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_InfantrySpawn( wave4, "Stalker", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_WaitEnemyAliveAmount( wave4, 30 )
	}
	WaveSpawn_WaitEnemyAliveAmount( wave4, 10 )

	// // 阶段3: 精英Arc泰坦全面碾压 + 东面Reaper
	// for ( int i = 0; i < 10; i++ )
	// {
	// 	//WaveSpawn_ETitanSpawn( wave4, eFDT.arc, file.titanEast, 180, "", 0.8, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	// 	WaveSpawn_ETitanSpawn( wave4, eFDT.ArcNIU, file.titanEast, 180, "", 0.8, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
	// 	WaveSpawn_ReaperSpawn( wave4, "TickReaper", file.dropWest[ RandomInt(file.dropWest.len()) ], 90, "", 0.5 )
	// 	//WaveSpawn_ReaperSpawn( wave4, "TickReaper", file.dropEast[ RandomInt(file.dropEast.len()) ], 90, "", 0.4 )
	// 	WaveSpawn_WaitEnemyAliveAmount( wave4, 28 )
	// }
	WaveSpawn_WaitEnemyAliveAmount( wave4, 0 )
	WaveSpawnEvents.append( wave4 )

	// ══════════�?波次5: 末日浩劫 ~70 ══════════�?
	// 主力:四方向泰坦群 侧翼:Reaper全覆�?偷袭:北面斩首
	array<WaveSpawnEvent> wave5
	WaveSpawn_Announce( wave5, "fd_waveComboMultiMix", 0.0 )
	WaveSpawn_ViperBoss( wave5, 3, [ <0,0,500> ], 90 )
	// 阶段1: 四方向泰坦同时突进（Nuke+Mortar+All�?
	for ( int i = 0; i < 5; i++ )
	{
		WaveSpawn_ETitanSpawn( wave5, eFDT.nuke, file.titanSouth, 0, "", 1.0, "" )
		WaveSpawn_ETitanSpawn( wave5, eFDT.mortar, file.titanEast, 0, "", 1.0, "" )
		WaveSpawn_ETitanSpawn( wave5, eFDT.nuke, file.titanSouth, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.mortar, file.titanWest, 0, "", 1.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave5, 26 )
		WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanSouth, 0, "", 1.0, "" )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanEast, 0, "", 1.0, "" )
		WaveSpawn_ReaperSpawn( wave5, "TickReaper", file.dropSouth[ RandomInt(file.dropSouth.len()) ], 90, "", 0.4 )
		WaveSpawn_ReaperSpawn( wave5, "TickReaper", file.dropEast[ RandomInt(file.dropEast.len()) ], 90, "", 0.4 )
		WaveSpawn_InfantrySpawn( wave5, "MortarSpectre", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 0.0, "", 0.3 )
		WaveSpawn_WaitEnemyAliveAmount( wave5, 26 )
	}

	WaveSpawn_WaitEnemyAliveAmount( wave5, 2 )

	// 阶段2: 精英Arc泰坦终局 + �?西合�?
	for ( int i = 0; i < 6; i++ )
	{
		WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanSouth, 0, "", 0.8, "" )
		WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanEast, 0, "", 0.8, "" )
		WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanWest, 0, "", 0.8, "" )
		WaveSpawn_ETitanSpawn( wave5, eFDT.mortar, file.titanWest, 0, "", 1.0, "" )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.mortar, file.titanWest, 0, "", 1.0, "" )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.mortar, file.titanWest, 0, "", 1.0, "" )
		WaveSpawn_WaitEnemyAliveAmount( wave5, 20 )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.ArcNIU, file.titanNorth, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.ArcNIU, file.titanSouth, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.ArcNIU, file.titanEast, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanSouth, 0, "", 0.8, "" )
		WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanEast, 0, "", 0.8, "" )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanWest, 0, "", 0.8, "" )
		WaveSpawn_ETitanSpawn( wave5, eFDT.ArcNIU, file.titanWest, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.ArcNIU, file.titanSouth, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		WaveSpawn_WaitEnemyAliveAmount( wave5, 20 )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.ArcNIU, file.titanEast, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanSouth, 0, "", 0.8, "" )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanEast, 0, "", 0.8, "" )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanWest, 0, "", 0.8, "" )
		//WaveSpawn_ETitanSpawn( wave5, eFDT.ArcNIU, file.titanWest, 0, "", 1.0, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )
		WaveSpawn_ReaperSpawn( wave5, "Reaper", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 180, "", 0.3 )
		WaveSpawn_ReaperSpawn( wave5, "Reaper", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 180, "", 0.3 )
		//WaveSpawn_ReaperSpawn( wave5, "Reaper", file.titanNorth[ RandomInt(file.dropSouth.len()) ], 180, "", 0.3 )
		WaveSpawn_ReaperSpawn( wave5, "Reaper", file.dropNorth[ RandomInt(file.dropNorth.len()) ], 180, "", 0.3 )
		WaveSpawn_ETitanSpawn( wave5, eFDT.all, file.titanSouth, 0, "", 0.8, "", 0, eFDSD.ALL, eFDTT.TITAN_ELITE )

		WaveSpawn_WaitEnemyAliveAmount( wave5, 15 )
	}

	WaveSpawn_WaitEnemyAliveAmount( wave5, 0 )
	WaveSpawnEvents.append( wave5 )


    







	



	



}

// ══════════════�?自动生成 �?硬编码出生点坐标 ══════════════�?
// 来源: mp_training_ground_tf2_spawn.ent
// 采集�? < 1872.01 , 3427.27 , -5.96875 >, 距离过滤 > 500
// 泰坦�? 73  步兵/死神�? 53
void function InitSpawnPointArrays()
{
	// ── 泰坦出生�?(73�? ──
	file.titanspawnpoints.append(< 2754.39 , -3732.19 , -3.04133 >)
	file.titanspawnpoints.append(< 292.003 , -4078.24 , 6.9793 >)
	file.titanspawnpoints.append(< -2481.33 , -2726.93 , 7.9335 >)
	file.titanspawnpoints.append(< 3100.39 , -3416.26 , 3.55 >)
	file.titanspawnpoints.append(< 3253.64 , -2651.36 , -10.91827 >)
	file.titanspawnpoints.append(< -3190.63 , -3271.1 , 115.0 >)
	file.titanspawnpoints.append(< -2990.86 , -3470.86 , 115.0 >)
	file.titanspawnpoints.append(< -2791.1 , -3670.63 , 115.0 >)
	file.titanspawnpoints.append(< -2990.86 , -3870.39 , 115.0 >)
	file.titanspawnpoints.append(< -3190.63 , -3670.62 , 115.0 >)
	file.titanspawnpoints.append(< -3390.4 , -3470.87 , 115.0 >)
	file.titanspawnpoints.append(< -3590.15 , -3670.63 , 115.0 >)
	file.titanspawnpoints.append(< -3390.4 , -3870.39 , 115.0 >)
	file.titanspawnpoints.append(< -3190.63 , -4070.15 , 115.0 >)
	file.titanspawnpoints.append(< 3634.07 , 2717.66 , 3.0451 >)
	file.titanspawnpoints.append(< 3170.63 , 2064.91 , -26.5895 >)
//	file.titanspawnpoints.append(< 969.705 , 4053.08 , -5.21187 >)
	file.titanspawnpoints.append(< -766.693 , 3854.93 , -9.16385 >)
	file.titanspawnpoints.append(< -2301.83 , 1545.54 , -9.85805 >)
	file.titanspawnpoints.append(< -3004.38 , 1583.16 , 36.1496 >)
	file.titanspawnpoints.append(< 3114.58 , -3113.12 , 18.6618 >)
	file.titanspawnpoints.append(< 3358.4 , 3934.39 , 115.0 >)
//	file.titanspawnpoints.append(< 3158.63 , 4134.15 , 115.0 >)
//	file.titanspawnpoints.append(< 3358.4 , 3534.87 , 115.0 >)
	file.titanspawnpoints.append(< 3558.15 , 3734.63 , 115.0 >)
//	file.titanspawnpoints.append(< 3158.63 , 3734.62 , 115.0 >)
//	file.titanspawnpoints.append(< 2759.1 , 3734.63 , 115.0 >)
//	file.titanspawnpoints.append(< 2958.86 , 3934.39 , 115.0 >)
//	file.titanspawnpoints.append(< 2958.86 , 3534.86 , 115.0 >)
//	file.titanspawnpoints.append(< 3158.63 , 3335.1 , 115.0 >)
	file.titanspawnpoints.append(< 773.043 , -3703.85 , -15.76949 >)
	file.titanspawnpoints.append(< 825.791 , -2920.88 , -12.118284 >)
	file.titanspawnpoints.append(< 2796.21 , -2296.06 , 11.8817 >)
	file.titanspawnpoints.append(< -799.23 , -3581.42 , 5.01 >)
	file.titanspawnpoints.append(< -1915.12 , -4114.69 , 28.4477 >)
	file.titanspawnpoints.append(< -1954.21 , -2500.16 , -12.369621 >)
	file.titanspawnpoints.append(< -789.562 , -1963.35 , -13.87204 >)
//	file.titanspawnpoints.append(< 2114.1 , 2480.82 , -5.39711 >)
	file.titanspawnpoints.append(< 664.448 , 1948.02 , -14.75704 >)
	file.titanspawnpoints.append(< -587.429 , 2470.94 , -5.28096 >)
	file.titanspawnpoints.append(< -2702.92 , 2141.4 , -13.827156 >)
	file.titanspawnpoints.append(< -3053.54 , 3930.19 , 26.2634 >)
	file.titanspawnpoints.append(< -1916.32 , 4170.88 , -1.6253 >)
	file.titanspawnpoints.append(< -3454.75 , 2454.3 , 64.3162 >)
	file.titanspawnpoints.append(< -3453.15 , 3031.45 , 84.0476 >)
	file.titanspawnpoints.append(< -3436.15 , 1301.11 , 59.6958 >)
	file.titanspawnpoints.append(< -3468.07 , 1883.91 , 104.696 >)
//	file.titanspawnpoints.append(< 1856 , 4096 , 51.0 >)
	file.titanspawnpoints.append(< -2336 , 3904 , 51.0 >)
	file.titanspawnpoints.append(< 1056 , -4256 , 51.0 >)
	file.titanspawnpoints.append(< -1088 , -4256 , 51.0 >)
	file.titanspawnpoints.append(< -3712 , -1536 , 51.0 >)
	file.titanspawnpoints.append(< -3062.22 , -1991.2 , 51.0 >)
	file.titanspawnpoints.append(< -3200 , -1024 , 51.0 >)
	file.titanspawnpoints.append(< -3156 , -2728 , -1.0 >)
	file.titanspawnpoints.append(< -3520 , -3872 , 147.0 >)
//	file.titanspawnpoints.append(< 2336 , 4104 , 75.0 >)
//	file.titanspawnpoints.append(< 3008 , 4096 , 51.0 >)
//	file.titanspawnpoints.append(< 2912 , 3424 , 51.0 >)
	file.titanspawnpoints.append(< -3200 , 3296 , 51.0 >)
	file.titanspawnpoints.append(< 3520.95 , -1360.52 , 71.5766 >)
	file.titanspawnpoints.append(< 3524.11 , -1901.4 , 39.5087 >)
	file.titanspawnpoints.append(< 3519.32 , -2457.22 , 53.7 >)
	file.titanspawnpoints.append(< 1874.53 , -4192.09 , 13.5798 >)
	file.titanspawnpoints.append(< 2484.53 , -4133.54 , 26.6474 >)
	file.titanspawnpoints.append(< -3913.56 , -1922.84 , 35.0345 >)
	file.titanspawnpoints.append(< -4014.06 , -2479.7 , 113.993 >)
	file.titanspawnpoints.append(< -3990.4 , -3017.7 , 81.9929 >)
	file.titanspawnpoints.append(< 3584 , 4096 , 131.0 >)
	file.titanspawnpoints.append(< -3008 , -3840 , 51.0 >)
	file.titanspawnpoints.append(< -2400 , -3840 , -13.0 >)
	file.titanspawnpoints.append(< -3488 , -1952 , -17.0 >)
	file.titanspawnpoints.append(< -3154.52 , -2432.71 , 51.0 >)

	// ── 步兵/死神出生�?(53�? ──
	file.dropspawnpoints.append(< 902.244 , -2956.13 , 1.984 >)
	file.dropspawnpoints.append(< -2656 , -3072 , 83.0 >)
	file.dropspawnpoints.append(< -2999.96 , 4022.94 , 20.4741 >)
	file.dropspawnpoints.append(< -959.072 , 2768.54 , -19.7339 >)
	file.dropspawnpoints.append(< 3184 , -3520 , 99.0 >)
	file.dropspawnpoints.append(< 1896 , -4064 , 83.0 >)
	file.dropspawnpoints.append(< -675.592 , -3377.27 , 4.698 >)
	file.dropspawnpoints.append(< -2064 , -3904 , 83.0 >)
	file.dropspawnpoints.append(< -1922.99 , 4063.4 , 18.0161 >)
//	file.dropspawnpoints.append(< 740.836 , 3436.53 , -22.58655 >)
	file.dropspawnpoints.append(< -940.894 , 2953.65 , 4.564 >)
	file.dropspawnpoints.append(< -556.894 , 2969.65 , 4.564 >)
	file.dropspawnpoints.append(< 614.24 , -2956.13 , 1.984 >)
	file.dropspawnpoints.append(< 870.24 , -2716.13 , 1.984 >)
	file.dropspawnpoints.append(< -832 , -2752 , -13.0 >)
	file.dropspawnpoints.append(< -2488 , -1656 , 7.0 >)
	file.dropspawnpoints.append(< -2944 , -1088 , 3.0 >)
	file.dropspawnpoints.append(< -1920 , -1920 , -13.0 >)
	file.dropspawnpoints.append(< 952 , -1480 , -1.0 >)
	file.dropspawnpoints.append(< 3200 , -1472 , 55.0 >)
	file.dropspawnpoints.append(< 3008 , -2624 , 19.0 >)
//	file.dropspawnpoints.append(< 1824 , 2624 , -13.0 >)
	file.dropspawnpoints.append(< -1057.45 , 2960.71 , 18.9462 >)
	file.dropspawnpoints.append(< 3200 , 2624 , -13.0 >)
	file.dropspawnpoints.append(< 2552.35 , 1543.35 , 15.8714 >)
//	file.dropspawnpoints.append(< 1896 , 2152 , -13.0 >)
	file.dropspawnpoints.append(< -1088 , 1744 , 19.0 >)
	file.dropspawnpoints.append(< -2272 , 1792 , -13.0 >)
	file.dropspawnpoints.append(< -3072 , 2624 , -13.0 >)
	file.dropspawnpoints.append(< 2304 , -1600 , 19.0 >)
	file.dropspawnpoints.append(< -656 , -3216 , 27.0 >)
	file.dropspawnpoints.append(< -1249.68 , -2552.67 , 15.7358 >)
	file.dropspawnpoints.append(< -2179.96 , -1983.64 , 3.5013 >)
	file.dropspawnpoints.append(< -3555.62 , -2629.49 , -10.9137 >)
	file.dropspawnpoints.append(< 613.038 , -2783.22 , 1.0651 >)
	file.dropspawnpoints.append(< 1154.74 , -2572.78 , 19.0998 >)
	file.dropspawnpoints.append(< 554.301 , -1599.78 , 19.402 >)
	file.dropspawnpoints.append(< 3285.62 , -2972.33 , 24.6614 >)
//	file.dropspawnpoints.append(< 3262.53 , 3056.51 , 98.71 >)
	file.dropspawnpoints.append(< 3717.92 , 2089.31 , 14.1753 >)
//	file.dropspawnpoints.append(< 2160.45 , 2108.01 , 33.0142 >)
//	file.dropspawnpoints.append(< 1246.86 , 2550.59 , 16.2803 >)
	file.dropspawnpoints.append(< -1066.72 , 2614.36 , 19.0278 >)
	file.dropspawnpoints.append(< -542.322 , 1538.18 , 19.3082 >)
	file.dropspawnpoints.append(< -2179.29 , 2466.75 , 9.2121 >)
	file.dropspawnpoints.append(< -3157.85 , 2051.07 , -0.6363 >)
	file.dropspawnpoints.append(< -1146.85 , 3879.94 , 19.7312 >)
	file.dropspawnpoints.append(< 1835.41 , -2522.05 , 27.2596 >)
	file.dropspawnpoints.append(< 2528.99 , -2454.72 , 18.7095 >)
	file.dropspawnpoints.append(< 2694.96 , -2098.65 , 17.7935 >)
	file.dropspawnpoints.append(< 2968.74 , -2085.42 , 17.8601 >)
	file.dropspawnpoints.append(< -971.31 , -1559.75 , 17.8334 >)
	file.dropspawnpoints.append(< -558.922 , -1812.68 , 16.6134 >)

	// ── 按方向分�?──
	// �?(y > 3427)
//	file.titanNorth.append(< 969.705 , 4053.08 , -5.21187 >)
//	file.titanNorth.append(< -766.693 , 3854.93 , -9.16385 >)
//	file.titanNorth.append(< 3358.4 , 3934.39 , 115.0 >)
//	file.titanNorth.append(< 3158.63 , 4134.15 , 115.0 >)
//	file.titanNorth.append(< 3358.4 , 3534.87 , 115.0 >)
//	file.titanNorth.append(< 3558.15 , 3734.63 , 115.0 >)
//	file.titanNorth.append(< 3158.63 , 3734.62 , 115.0 >)
//	file.titanNorth.append(< 2759.1 , 3734.63 , 115.0 >)
//	file.titanNorth.append(< 2958.86 , 3934.39 , 115.0 >)
//	file.titanNorth.append(< 2958.86 , 3534.86 , 115.0 >)
	file.titanNorth.append(< -3053.54 , 3930.19 , 26.2634 >)
//	file.titanNorth.append(< -1916.32 , 4170.88 , -1.6253 >)
//	file.titanNorth.append(< 1856 , 4096 , 51.0 >)
	file.titanNorth.append(< -2336 , 3904 , 51.0 >)
//	file.titanNorth.append(< 2336 , 4104 , 75.0 >)
//	file.titanNorth.append(< 3008 , 4096 , 51.0 >)
//	file.titanNorth.append(< 3584 , 4096 , 131.0 >)
	file.dropNorth.append(< -2999.96 , 4022.94 , 20.4741 >)
	file.dropNorth.append(< -1922.99 , 4063.4 , 18.0161 >)
//	file.dropNorth.append(< 740.836 , 3436.53 , -22.58655 >)
//	file.dropNorth.append(< -1146.85 , 3879.94 , 19.7312 >)

	// �?(y < 3427)
	file.titanSouth.append(< 2754.39 , -3732.19 , -3.04133 >)
	file.titanSouth.append(< 292.003 , -4078.24 , 6.9793 >)
	file.titanSouth.append(< -2481.33 , -2726.93 , 7.9335 >)
	file.titanSouth.append(< 3100.39 , -3416.26 , 3.55 >)
	file.titanSouth.append(< 3253.64 , -2651.36 , -10.91827 >)
	file.titanSouth.append(< -3190.63 , -3271.1 , 115.0 >)
	file.titanSouth.append(< -2990.86 , -3470.86 , 115.0 >)
	file.titanSouth.append(< -2791.1 , -3670.63 , 115.0 >)
	file.titanSouth.append(< -2990.86 , -3870.39 , 115.0 >)
	file.titanSouth.append(< -3190.63 , -3670.62 , 115.0 >)
	file.titanSouth.append(< -3390.4 , -3470.87 , 115.0 >)
	file.titanSouth.append(< -3590.15 , -3670.63 , 115.0 >)
	file.titanSouth.append(< -3390.4 , -3870.39 , 115.0 >)
	file.titanSouth.append(< -3190.63 , -4070.15 , 115.0 >)
	file.titanSouth.append(< 3634.07 , 2717.66 , 3.0451 >)
	file.titanSouth.append(< 3170.63 , 2064.91 , -26.5895 >)
	file.titanSouth.append(< -2301.83 , 1545.54 , -9.85805 >)
	file.titanSouth.append(< -3004.38 , 1583.16 , 36.1496 >)
	file.titanSouth.append(< 3114.58 , -3113.12 , 18.6618 >)
//	file.titanSouth.append(< 3158.63 , 3335.1 , 115.0 >)
	file.titanSouth.append(< 773.043 , -3703.85 , -15.76949 >)
	file.titanSouth.append(< 825.791 , -2920.88 , -12.118284 >)
	file.titanSouth.append(< 2796.21 , -2296.06 , 11.8817 >)
	file.titanSouth.append(< -799.23 , -3581.42 , 5.01 >)
	file.titanSouth.append(< -1915.12 , -4114.69 , 28.4477 >)
	file.titanSouth.append(< -1954.21 , -2500.16 , -12.369621 >)
	file.titanSouth.append(< -789.562 , -1963.35 , -13.87204 >)
//	file.titanSouth.append(< 2114.1 , 2480.82 , -5.39711 >)
	file.titanSouth.append(< 664.448 , 1948.02 , -14.75704 >)
	file.titanSouth.append(< -587.429 , 2470.94 , -5.28096 >)
	file.titanSouth.append(< -2702.92 , 2141.4 , -13.827156 >)
	file.titanSouth.append(< -3454.75 , 2454.3 , 64.3162 >)
	file.titanSouth.append(< -3453.15 , 3031.45 , 84.0476 >)
	file.titanSouth.append(< -3436.15 , 1301.11 , 59.6958 >)
	file.titanSouth.append(< -3468.07 , 1883.91 , 104.696 >)
	file.titanSouth.append(< 1056 , -4256 , 51.0 >)
	file.titanSouth.append(< -1088 , -4256 , 51.0 >)
	file.titanSouth.append(< -3712 , -1536 , 51.0 >)
	file.titanSouth.append(< -3062.22 , -1991.2 , 51.0 >)
	file.titanSouth.append(< -3200 , -1024 , 51.0 >)
	file.titanSouth.append(< -3156 , -2728 , -1.0 >)
	file.titanSouth.append(< -3520 , -3872 , 147.0 >)
//	file.titanSouth.append(< 2912 , 3424 , 51.0 >)
	file.titanSouth.append(< -3200 , 3296 , 51.0 >)
	file.titanSouth.append(< 3520.95 , -1360.52 , 71.5766 >)
	file.titanSouth.append(< 3524.11 , -1901.4 , 39.5087 >)
	file.titanSouth.append(< 3519.32 , -2457.22 , 53.7 >)
	file.titanSouth.append(< 1874.53 , -4192.09 , 13.5798 >)
	file.titanSouth.append(< 2484.53 , -4133.54 , 26.6474 >)
	file.titanSouth.append(< -3913.56 , -1922.84 , 35.0345 >)
	file.titanSouth.append(< -4014.06 , -2479.7 , 113.993 >)
	file.titanSouth.append(< -3990.4 , -3017.7 , 81.9929 >)
	file.titanSouth.append(< -3008 , -3840 , 51.0 >)
	file.titanSouth.append(< -2400 , -3840 , -13.0 >)
	file.titanSouth.append(< -3488 , -1952 , -17.0 >)
	file.titanSouth.append(< -3154.52 , -2432.71 , 51.0 >)
	file.dropSouth.append(< 902.244 , -2956.13 , 1.984 >)
	file.dropSouth.append(< -2656 , -3072 , 83.0 >)
	file.dropSouth.append(< -959.072 , 2768.54 , -19.7339 >)
	file.dropSouth.append(< 3184 , -3520 , 99.0 >)
	file.dropSouth.append(< 1896 , -4064 , 83.0 >)
	file.dropSouth.append(< -675.592 , -3377.27 , 4.698 >)
	file.dropSouth.append(< -2064 , -3904 , 83.0 >)
	file.dropSouth.append(< -940.894 , 2953.65 , 4.564 >)
	file.dropSouth.append(< -556.894 , 2969.65 , 4.564 >)
	file.dropSouth.append(< 614.24 , -2956.13 , 1.984 >)
	file.dropSouth.append(< 870.24 , -2716.13 , 1.984 >)
	file.dropSouth.append(< -832 , -2752 , -13.0 >)
	file.dropSouth.append(< -2488 , -1656 , 7.0 >)
	file.dropSouth.append(< -2944 , -1088 , 3.0 >)
	file.dropSouth.append(< -1920 , -1920 , -13.0 >)
	file.dropSouth.append(< 952 , -1480 , -1.0 >)
	file.dropSouth.append(< 3200 , -1472 , 55.0 >)
	file.dropSouth.append(< 3008 , -2624 , 19.0 >)
//	file.dropSouth.append(< 1824 , 2624 , -13.0 >)
	file.dropSouth.append(< -1057.45 , 2960.71 , 18.9462 >)
	file.dropSouth.append(< 3200 , 2624 , -13.0 >)
	file.dropSouth.append(< 2552.35 , 1543.35 , 15.8714 >)
//	file.dropSouth.append(< 1896 , 2152 , -13.0 >)
	file.dropSouth.append(< -1088 , 1744 , 19.0 >)
	file.dropSouth.append(< -2272 , 1792 , -13.0 >)
	file.dropSouth.append(< -3072 , 2624 , -13.0 >)
	file.dropSouth.append(< 2304 , -1600 , 19.0 >)
	file.dropSouth.append(< -656 , -3216 , 27.0 >)
	file.dropSouth.append(< -1249.68 , -2552.67 , 15.7358 >)
	file.dropSouth.append(< -2179.96 , -1983.64 , 3.5013 >)
	file.dropSouth.append(< -3555.62 , -2629.49 , -10.9137 >)
	file.dropSouth.append(< 613.038 , -2783.22 , 1.0651 >)
	file.dropSouth.append(< 1154.74 , -2572.78 , 19.0998 >)
	file.dropSouth.append(< 554.301 , -1599.78 , 19.402 >)
	file.dropSouth.append(< 3285.62 , -2972.33 , 24.6614 >)
//	file.dropSouth.append(< 3262.53 , 3056.51 , 98.71 >)
	file.dropSouth.append(< 3717.92 , 2089.31 , 14.1753 >)
//	file.dropSouth.append(< 2160.45 , 2108.01 , 33.0142 >)
//	file.dropSouth.append(< 1246.86 , 2550.59 , 16.2803 >)
	file.dropSouth.append(< -1066.72 , 2614.36 , 19.0278 >)
	file.dropSouth.append(< -542.322 , 1538.18 , 19.3082 >)
	file.dropSouth.append(< -2179.29 , 2466.75 , 9.2121 >)
	file.dropSouth.append(< -3157.85 , 2051.07 , -0.6363 >)
	file.dropSouth.append(< 1835.41 , -2522.05 , 27.2596 >)
	file.dropSouth.append(< 2528.99 , -2454.72 , 18.7095 >)
	file.dropSouth.append(< 2694.96 , -2098.65 , 17.7935 >)
	file.dropSouth.append(< 2968.74 , -2085.42 , 17.8601 >)
	file.dropSouth.append(< -971.31 , -1559.75 , 17.8334 >)
	file.dropSouth.append(< -558.922 , -1812.68 , 16.6134 >)

	// �?(x > 1872)
	file.titanEast.append(< 2754.39 , -3732.19 , -3.04133 >)
	file.titanEast.append(< 3100.39 , -3416.26 , 3.55 >)
	file.titanEast.append(< 3253.64 , -2651.36 , -10.91827 >)
	file.titanEast.append(< 3634.07 , 2717.66 , 3.0451 >)
	file.titanEast.append(< 3170.63 , 2064.91 , -26.5895 >)
	file.titanEast.append(< 3114.58 , -3113.12 , 18.6618 >)
	file.titanEast.append(< 3358.4 , 3934.39 , 115.0 >)
//	file.titanEast.append(< 3158.63 , 4134.15 , 115.0 >)
//	file.titanEast.append(< 3358.4 , 3534.87 , 115.0 >)
	file.titanEast.append(< 3558.15 , 3734.63 , 115.0 >)
//	file.titanEast.append(< 3158.63 , 3734.62 , 115.0 >)
//	file.titanEast.append(< 2759.1 , 3734.63 , 115.0 >)
//	file.titanEast.append(< 2958.86 , 3934.39 , 115.0 >)
//	file.titanEast.append(< 2958.86 , 3534.86 , 115.0 >)
//	file.titanEast.append(< 3158.63 , 3335.1 , 115.0 >)
	file.titanEast.append(< 2796.21 , -2296.06 , 11.8817 >)
//	file.titanEast.append(< 2114.1 , 2480.82 , -5.39711 >)
//	file.titanEast.append(< 2336 , 4104 , 75.0 >)
//	file.titanEast.append(< 3008 , 4096 , 51.0 >)
//	file.titanEast.append(< 2912 , 3424 , 51.0 >)
	file.titanEast.append(< 3520.95 , -1360.52 , 71.5766 >)
	file.titanEast.append(< 3524.11 , -1901.4 , 39.5087 >)
	file.titanEast.append(< 3519.32 , -2457.22 , 53.7 >)
	file.titanEast.append(< 1874.53 , -4192.09 , 13.5798 >)
	file.titanEast.append(< 2484.53 , -4133.54 , 26.6474 >)
	file.titanEast.append(< 3584 , 4096 , 131.0 >)
	file.dropEast.append(< 3184 , -3520 , 99.0 >)
	file.dropEast.append(< 1896 , -4064 , 83.0 >)
	file.dropEast.append(< 3200 , -1472 , 55.0 >)
	file.dropEast.append(< 3008 , -2624 , 19.0 >)
	file.dropEast.append(< 3200 , 2624 , -13.0 >)
	file.dropEast.append(< 2552.35 , 1543.35 , 15.8714 >)
//	file.dropEast.append(< 1896 , 2152 , -13.0 >)
	file.dropEast.append(< 2304 , -1600 , 19.0 >)
	file.dropEast.append(< 3285.62 , -2972.33 , 24.6614 >)
//	file.dropEast.append(< 3262.53 , 3056.51 , 98.71 >)
	file.dropEast.append(< 3717.92 , 2089.31 , 14.1753 >)
//	file.dropEast.append(< 2160.45 , 2108.01 , 33.0142 >)
	file.dropEast.append(< 2528.99 , -2454.72 , 18.7095 >)
	file.dropEast.append(< 2694.96 , -2098.65 , 17.7935 >)
	file.dropEast.append(< 2968.74 , -2085.42 , 17.8601 >)

	// �?(x < 1872)
	file.titanWest.append(< 292.003 , -4078.24 , 6.9793 >)
	file.titanWest.append(< -2481.33 , -2726.93 , 7.9335 >)
	file.titanWest.append(< -3190.63 , -3271.1 , 115.0 >)
	file.titanWest.append(< -2990.86 , -3470.86 , 115.0 >)
	file.titanWest.append(< -2791.1 , -3670.63 , 115.0 >)
	file.titanWest.append(< -2990.86 , -3870.39 , 115.0 >)
	file.titanWest.append(< -3190.63 , -3670.62 , 115.0 >)
	file.titanWest.append(< -3390.4 , -3470.87 , 115.0 >)
	file.titanWest.append(< -3590.15 , -3670.63 , 115.0 >)
	file.titanWest.append(< -3390.4 , -3870.39 , 115.0 >)
	file.titanWest.append(< -3190.63 , -4070.15 , 115.0 >)
//	file.titanWest.append(< 969.705 , 4053.08 , -5.21187 >)
	file.titanWest.append(< -766.693 , 3854.93 , -9.16385 >)
	file.titanWest.append(< -2301.83 , 1545.54 , -9.85805 >)
	file.titanWest.append(< -3004.38 , 1583.16 , 36.1496 >)
	file.titanWest.append(< 773.043 , -3703.85 , -15.76949 >)
	file.titanWest.append(< 825.791 , -2920.88 , -12.118284 >)
	file.titanWest.append(< -799.23 , -3581.42 , 5.01 >)
	file.titanWest.append(< -1915.12 , -4114.69 , 28.4477 >)
	file.titanWest.append(< -1954.21 , -2500.16 , -12.369621 >)
	file.titanWest.append(< -789.562 , -1963.35 , -13.87204 >)
	file.titanWest.append(< 664.448 , 1948.02 , -14.75704 >)
	file.titanWest.append(< -587.429 , 2470.94 , -5.28096 >)
	file.titanWest.append(< -2702.92 , 2141.4 , -13.827156 >)
	file.titanWest.append(< -3053.54 , 3930.19 , 26.2634 >)
	file.titanWest.append(< -1916.32 , 4170.88 , -1.6253 >)
	file.titanWest.append(< -3454.75 , 2454.3 , 64.3162 >)
	file.titanWest.append(< -3453.15 , 3031.45 , 84.0476 >)
	file.titanWest.append(< -3436.15 , 1301.11 , 59.6958 >)
	file.titanWest.append(< -3468.07 , 1883.91 , 104.696 >)
//	file.titanWest.append(< 1856 , 4096 , 51.0 >)
	file.titanWest.append(< -2336 , 3904 , 51.0 >)
	file.titanWest.append(< 1056 , -4256 , 51.0 >)
	file.titanWest.append(< -1088 , -4256 , 51.0 >)
	file.titanWest.append(< -3712 , -1536 , 51.0 >)
	file.titanWest.append(< -3062.22 , -1991.2 , 51.0 >)
	file.titanWest.append(< -3200 , -1024 , 51.0 >)
	file.titanWest.append(< -3156 , -2728 , -1.0 >)
	file.titanWest.append(< -3520 , -3872 , 147.0 >)
	file.titanWest.append(< -3200 , 3296 , 51.0 >)
	file.titanWest.append(< -3913.56 , -1922.84 , 35.0345 >)
	file.titanWest.append(< -4014.06 , -2479.7 , 113.993 >)
	file.titanWest.append(< -3990.4 , -3017.7 , 81.9929 >)
	file.titanWest.append(< -3008 , -3840 , 51.0 >)
	file.titanWest.append(< -2400 , -3840 , -13.0 >)
	file.titanWest.append(< -3488 , -1952 , -17.0 >)
	file.titanWest.append(< -3154.52 , -2432.71 , 51.0 >)
	file.dropWest.append(< 902.244 , -2956.13 , 1.984 >)
	file.dropWest.append(< -2656 , -3072 , 83.0 >)
	file.dropWest.append(< -2999.96 , 4022.94 , 20.4741 >)
	file.dropWest.append(< -959.072 , 2768.54 , -19.7339 >)
	file.dropWest.append(< -675.592 , -3377.27 , 4.698 >)
	file.dropWest.append(< -2064 , -3904 , 83.0 >)
	file.dropWest.append(< -1922.99 , 4063.4 , 18.0161 >)
//	file.dropWest.append(< 740.836 , 3436.53 , -22.58655 >)
	file.dropWest.append(< -940.894 , 2953.65 , 4.564 >)
	file.dropWest.append(< -556.894 , 2969.65 , 4.564 >)
	file.dropWest.append(< 614.24 , -2956.13 , 1.984 >)
	file.dropWest.append(< 870.24 , -2716.13 , 1.984 >)
	file.dropWest.append(< -832 , -2752 , -13.0 >)
	file.dropWest.append(< -2488 , -1656 , 7.0 >)
	file.dropWest.append(< -2944 , -1088 , 3.0 >)
	file.dropWest.append(< -1920 , -1920 , -13.0 >)
	file.dropWest.append(< 952 , -1480 , -1.0 >)
//	file.dropWest.append(< 1824 , 2624 , -13.0 >)
	file.dropWest.append(< -1057.45 , 2960.71 , 18.9462 >)
	file.dropWest.append(< -1088 , 1744 , 19.0 >)
	file.dropWest.append(< -2272 , 1792 , -13.0 >)
	file.dropWest.append(< -3072 , 2624 , -13.0 >)
	file.dropWest.append(< -656 , -3216 , 27.0 >)
	file.dropWest.append(< -1249.68 , -2552.67 , 15.7358 >)
	file.dropWest.append(< -2179.96 , -1983.64 , 3.5013 >)
	file.dropWest.append(< -3555.62 , -2629.49 , -10.9137 >)
	file.dropWest.append(< 613.038 , -2783.22 , 1.0651 >)
	file.dropWest.append(< 1154.74 , -2572.78 , 19.0998 >)
	file.dropWest.append(< 554.301 , -1599.78 , 19.402 >)
//	file.dropWest.append(< 1246.86 , 2550.59 , 16.2803 >)
	file.dropWest.append(< -1066.72 , 2614.36 , 19.0278 >)
	file.dropWest.append(< -542.322 , 1538.18 , 19.3082 >)
	file.dropWest.append(< -2179.29 , 2466.75 , 9.2121 >)
	file.dropWest.append(< -3157.85 , 2051.07 , -0.6363 >)
	file.dropWest.append(< -1146.85 , 3879.94 , 19.7312 >)
	file.dropWest.append(< 1835.41 , -2522.05 , 27.2596 >)
	file.dropWest.append(< -971.31 , -1559.75 , 17.8334 >)
	file.dropWest.append(< -558.922 , -1812.68 , 16.6134 >)

	// 兜底：确保没有方向数组为空，否则 RandomInt(0) 崩溃
	FillEmptyDirectionArrays()
}

// 补全空方向数组（从主数组复制�?
void function FillEmptyDirectionArrays()
{
	if ( file.titanNorth.len() == 0 ) foreach ( v in file.titanspawnpoints ) file.titanNorth.append(v)
	if ( file.titanSouth.len() == 0 ) foreach ( v in file.titanspawnpoints ) file.titanSouth.append(v)
	if ( file.titanEast.len()  == 0 ) foreach ( v in file.titanspawnpoints ) file.titanEast.append(v)
	if ( file.titanWest.len()  == 0 ) foreach ( v in file.titanspawnpoints ) file.titanWest.append(v)
	if ( file.dropNorth.len()  == 0 ) foreach ( v in file.dropspawnpoints ) file.dropNorth.append(v)
	if ( file.dropSouth.len()  == 0 ) foreach ( v in file.dropspawnpoints ) file.dropSouth.append(v)
	if ( file.dropEast.len()   == 0 ) foreach ( v in file.dropspawnpoints ) file.dropEast.append(v)
	if ( file.dropWest.len()   == 0 ) foreach ( v in file.dropspawnpoints ) file.dropWest.append(v)
}



void function RegisterCustomFDContent()
{

	array<entity> triggers = GetEntArrayByClass_Expensive( "trigger_hurt" )
	foreach ( entity trigger in triggers )
	{
		if( trigger.kv.damageSourceName == "burn" )
			trigger.kv.triggerFilterNpc = "none"
	}
	

    array<entity> Turrets = GetEntArrayByClass_Expensive( "npc_turret_mega" )
	foreach ( entity Turret in Turrets )
	{
		Turret.Destroy()
	}

	array<entity> panels = GetEntArrayByClass_Expensive( "prop_control_panel" )
	foreach ( entity panel in panels )
	{
		panel.Destroy()
	}
	
	// 	// AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoint )
	// AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoint )
	// AddSpawnCallback( "info_spawnpoint_droppod", InitSpawnpoint )
	// AddSpawnCallback( "info_spawnpoint_dropship", InitSpawnpoint )
	// AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoint )
	// AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoint )
	// AddSpawnCallback( "info_spawnpoint_droppod_start", InitSpawnpoint )
	// AddSpawnCallback( "info_spawnpoint_dropship_start", InitSpawnpoint )

	// (出生点收集与方向分类已移�?initFrontierDefenseData 中的 GatherAndSortSpawnPoints)





	AddFDCustomShipStart(  < 2748.5 , 3735.36 , -27.6909 > , < 0, -15, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < 2724.89 , 2966.06 , -61.3146 > , < 0, -135, 0 >, TEAM_MILITIA )
	AddFDCustomShipStart( < 3131.91 , -1195.42 , 14.6769 > , < 0, -90, 0 >, TEAM_IMC )
	AddFDCustomShipStart(  < 2875.69 , -3668.53 , -38.2318 > , < 0, -90, 0 >, TEAM_IMC )





	
	//AddFDCustomTitanStart( < -7056, 322, 696 >, < 0, -45, 0 > )
	//AddFDCustomTitanStart( < -7874, -1013, 632 >, < 0, -20, 0 > )
	
	//SpawnFDHeavyTurret( < -6658, -75, 696 >, < 0, 135, 0 >, < -6778, -132, 580 >, < 0, 45, 0 > )
	


}