global function BoneyardShared_Init

void function BoneyardShared_Init()
{
	FlyersShared_Init()

	#if SERVER
		RegisterSignal( "BoneyardFlyerEscape" )
		RegisterSignal( "BoneyardFlyerStateChanged" )
	#endif
}
