#include <sdktools>
#include <dhooks>

#define ptr(%1) view_as< Address >(%1)

public Plugin myinfo =  {
	name = "TF2C Healer Fix", 
	author = "Scag", 
	description = "Fixes a crash where a null healer stops healing a player", 
	version = "1.0.0", 
	url = ""
};

int g_Patch[64];
int g_Old[64];
int g_Length;

Address g_Addr;

public void OnPluginStart()
{
	GameData conf = LoadGameConfigFile("tf2c.cmdfix");
	g_Addr = conf.GetAddress("CTFPlayerShared::StopHealing");
	int offset = conf.GetOffset("StopHealing::Offset");
	g_Length = conf.GetOffset("StopHealing::PatchLength");

	Handle hook = DHookCreateDetour(g_Addr, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
	DHookAddParam(hook, HookParamType_CBaseEntity);
	DHookEnableDetour(hook, false, CTFPlayerShared_StopHealing);
	DHookEnableDetour(hook, true, CTFPlayerShared_StopHealingPost);

	g_Addr += view_as< Address >(offset);

	for (int i = 0; i < g_Length; ++i)
	{
		g_Patch[i] = 0x90;	// Nop.avi
		g_Old[i] = LoadFromAddress(g_Addr + ptr(i), NumberType_Int8);
	}

//	PrintToServer("%d", g_Length);
//	char buffer[256];
//	for (int i = 0; i < g_Length; ++i)
//		Format(buffer, sizeof(buffer), "%s %2X", buffer, g_Old[i]);
//	PrintToServer("%s", buffer);
}

bool g_bInCall;

public MRESReturn CTFPlayerShared_StopHealing(Handle hParams)
{
	// Bad boi
//	PrintToChatAll("hooked");
	if (DHookIsNullParam(hParams, 1))
	{
//		PrintToChatAll("Param is null! Patching...");
		g_bInCall = true;
		Patch(g_Patch);
	}
}

public MRESReturn CTFPlayerShared_StopHealingPost(Handle hParams)
{
	if (g_bInCall)
	{
		Patch(g_Old);
		g_bInCall = false;
	}
}

public void Patch(int[] patch)
{
	for (int i = 0; i < g_Length; ++i)
		StoreToAddress(g_Addr + ptr(i), patch[i], NumberType_Int8);
}
