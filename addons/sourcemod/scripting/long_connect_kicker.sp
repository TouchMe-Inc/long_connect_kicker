#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>


public Plugin myinfo =
{
    name        = "LongConnectKicker",
    author      = "TouchMe",
    description = "Kick connecting players if takes too long",
    version     = "build0002",
    url         = "https://github.com/TouchMe-Inc/long_connect_kicker"
};


ConVar g_cvKickDelay = null;
Handle g_hPlayerTimers[MAXPLAYERS + 1] = {null, ...};

/**
 * Called when the plugin starts
 */
public void OnPluginStart() {
    g_cvKickDelay = CreateConVar("sm_long_connect_kick_delay", "75.0", "Kick player after this many seconds if they are still connecting to server", _, true, 60.0);
}

/**
 * Called when a client disconnects from the server
 * @param iClient The client index
 */
public void OnClientDisconnect(int iClient)
{
    if (g_hPlayerTimers[iClient] != null) {
        delete g_hPlayerTimers[iClient];
    }
}

/**
 * Called when a client is put in the server
 * @param iClient The client index
 */
public void OnClientPutInServer(int iClient) {
    delete g_hPlayerTimers[iClient];
}

/**
 * Called when a client connects to the server
 * @param iClient The client index
 */
public void OnClientConnected(int iClient)
{
    if (IsFakeClient(iClient)) {
        return;
    }

    // Create a timer to kick the player if they take too long to connect
    g_hPlayerTimers[iClient] = CreateTimer(GetConVarFloat(g_cvKickDelay), Timer_LongConnectKick, iClient, .flags = TIMER_FLAG_NO_MAPCHANGE);
}

/**
 * Timer callback to kick players who take too long to connect
 * @param hTimer The timer handle
 * @param iClient The client index
 */
Action Timer_LongConnectKick(Handle hTimer, int iClient)
{
    g_hPlayerTimers[iClient] = null;

    // If the client is no longer connected
    if (!IsClientConnected(iClient)) {
        return Plugin_Stop;
    }

    // Kick the player if they are still not in the game and not in the kick queue
    if (!IsClientInGame(iClient) && !IsClientInKickQueue(iClient)) {
        KickClient(iClient, "Your connecting time into server takes longer than %0.0f seconds", GetConVarFloat(g_cvKickDelay));
    }

    return Plugin_Stop;
}
