#include <sdktools>
#include <dhooks>

public Plugin myinfo =  {
	name = "TF2C Command Fix", 
	author = "Scag", 
	description = "Fixes a crash where a players could crash a server via command", 
	version = "1.0.0", 
	url = ""
};

public void OnPluginStart()
{
	GameData conf = LoadGameConfigFile("tf2c.cmdfix");
	Handle hook = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_CBaseEntity);
	if (!DHookSetFromConf(hook, conf, SDKConf_Signature, "CTFPlayer::ClientCommand"))
		SetFailState("You forgot the gamedata, dummy");

	DHookAddParam(hook, HookParamType_ObjectPtr);

	// Throws an error anyway but w/e
	if (!DHookEnableDetour(hook, false, CTFPlayer_ClientCommand))
		SetFailState("You're on your own!");

//	DHookEnableDetour(hook, true, CTFPlayer_ClientCommandPost);

	delete conf;
}

public MRESReturn CTFPlayer_ClientCommand(int pThis, Handle hReturn, Handle hParams)
{
	int argc = DHookGetParamObjectPtrVar(hParams, 1, 0, ObjectValueType_Int);
	if (argc <= 2)
		return MRES_Ignored;

	char command[32]; DHookGetParamObjectPtrString(hParams, 1, 1032, ObjectValueType_CharPtr, command, sizeof(command));
	char class[8]; DHookGetParamObjectPtrString(hParams, 1, 1036, ObjectValueType_CharPtr, class, sizeof(class));
	char idk[8]; DHookGetParamObjectPtrString(hParams, 1, 1040, ObjectValueType_CharPtr, idk, sizeof(idk));
//	PrintToChatAll("%s %s %s", command, class, idk);
	if (!strcmp(command, "disguise", false))
	{
		if (StringToInt(idk) == -1)
		{
			// Gotta get FANCY!
			Address addr = DHookGetParamObjectPtrVar(hParams, 1, 1040, ObjectValueType_Int);
			int team = GetDisguiseTeamExcept(GetClientTeam(pThis));
			team += 0x30;	// ASCII this bitch
			StoreToAddress(addr, team, NumberType_Int8);
			StoreToAddress(addr + view_as< Address >(1), 0, NumberType_Int8);	// Terminate
		}
	}
	return MRES_Ignored;
}

public MRESReturn CTFPlayer_ClientCommandPost(int pThis, Handle hReturn, Handle hParams)
{
	int argc = DHookGetParamObjectPtrVar(hParams, 1, 0, ObjectValueType_Int);
	if (argc <= 2)
		return MRES_Ignored;

	char command[32]; DHookGetParamObjectPtrString(hParams, 1, 1032, ObjectValueType_CharPtr, command, sizeof(command));
	char class[8]; DHookGetParamObjectPtrString(hParams, 1, 1036, ObjectValueType_CharPtr, class, sizeof(class));
	char idk[8]; DHookGetParamObjectPtrString(hParams, 1, 1040, ObjectValueType_CharPtr, idk, sizeof(idk));
	PrintToChatAll("%s %s %s", command, class, idk);
	return MRES_Ignored;
}
// There are 4 teams, so this kinda sucks
public int GetDisguiseTeamExcept(int exclude)
{
	switch (exclude)
	{
		case 2:return 1;
		case 3:return 0;
		case 4:return GetRandomIntExcept(0, 3, 2);
		case 5:return GetRandomInt(0, 2);
		default:return 0;
	}
}

public int GetRandomIntExcept(int low, int high, int exclude)
{
	int num;
	do
	{
		num = GetRandomInt(low, high);
	}	while num == exclude;
	return num;
}