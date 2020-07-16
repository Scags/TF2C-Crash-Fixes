#include <sdktools>
#include <dhooks>

public Plugin myinfo =  {
	name = "TF2C Lag Compensation Fix", 
	author = "Scag", 
	description = "Fixes a crash where players lag compensate with a null usercommand", 
	version = "1.0.0", 
	url = ""
};

public void OnPluginStart()
{
	GameData conf = LoadGameConfigFile("tf2c.cmdfix");
	Handle hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address);
	if (!DHookSetFromConf(hook, conf, SDKConf_Signature, "CLagCompensationManager::StartLagCompensation"))
		SetFailState("Could not set CLagCompensationManager::StartLagCompensation from config");
	DHookAddParam(hook, HookParamType_Int);
	DHookAddParam(hook, HookParamType_Int);
	DHookEnableDetour(hook, false, CLagCompensationManager_StartLagCompensation);
	delete conf;
}

public MRESReturn CLagCompensationManager_StartLagCompensation(Address pThis, Handle hParams)
{
	// CUserCmd*
	return DHookGetParam(hParams, 2) == 0 ? MRES_Supercede : MRES_Ignored;
}
