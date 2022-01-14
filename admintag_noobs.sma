#include <amxmodx>
#include <amxmisc>
#include <regex>

native get_roleUser(id, dest[], len);

#define PATTERN                "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" // \b

#define RCON ADMIN_RCON

enum{
    NUM = 0,
    POINT = 1,
    DPOINT = 2,
    WWW = 3,
    TOTAL_LTS
} 


new const chat[] = "chat.log"
new gSzTag[ 33 ][ 32 ], gPlayerName[ 33 ][ 32 ], gMaxPlayers;

public plugin_init()
{
	register_plugin( "Admin Tag(Para noobs)" , "0.1" , "kikizon" );
	
	register_clcmd( "say" , "clcmdSay" );
	register_clcmd( "say_team" , "clcmdSayTeam" );

	gMaxPlayers = get_maxplayers();

	register_message(get_user_msgid("SayText"), "MessageNameChange")
}


public client_putinserver( index )
{
	get_user_name( index , gPlayerName[index], 31 );
	gSzTag[index][0] = EOS;

	get_roleUser(index, gSzTag[index], 31);
	check_user_name(index)

}

public client_infochanged( index )
{
	new oldname[32], newname[32];
	get_user_name( index , oldname, 31 );
	get_user_info( index , "name", newname, 31 );

	if( !equal(oldname, newname))
		copy( gPlayerName[index], 31, newname );
	check_user_name(index, newname)
}

public clcmdSay(index)
{
	static said[191]; read_args(said, 190); remove_quotes(said); replace_all(said, 190, "%", ""); replace_all(said, 190, "#", "");
	new contador[TOTAL_LTS]

	for( new i = 0; i < strlen(said) ; i++)
    {
        switch(said[i])
        {
            case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' : contador[NUM]++
            
            case '.' : contador[POINT]++
            
            case ':' : contador[DPOINT]++
            
            case 'w' : contador[WWW]++
            
        }
    }
    
    	if(!(get_user_flags(index) & RCON))
    	{


		if(contador[NUM] >= 5 && contador[POINT] || (contador[WWW] >= 3 && containi(said,".com")) || contador[NUM] >= 3 || contador[NUM] >= 2 && contador[POINT])
		{	

			client_print(0, print_chat, "[Anti-Spam] %s Mensaje bloqueado. Considerado Spam", gPlayerName[index])
			return PLUGIN_HANDLED
				
				
		}
		}

	

	if (!ValidMessage(said, 1)) return PLUGIN_CONTINUE;

	static color[11], prefix[128]; get_user_team(index, color, 10);
	formatex(prefix, 127, "%s^x04%s^x03 %s", is_user_alive(index)?"^x01":"^x01*DEAD* ", gSzTag[index], gPlayerName[index]);

	if (is_user_admin(index)) format(said, charsmax(said), "^x04%s", said);

	format(said, charsmax(said), "%s^x01 : %s", prefix, said);

	static i, team[11];

	for (i = 1; i <= gMaxPlayers; ++i)
	{
		if (!is_user_connected(i)) continue;

		get_user_team(i, team, 10);
		changeTeamInfo(i, color);
		writeMessage(i, said);
		changeTeamInfo(i, team);
	}
	log_to_file(chat, "%s",  said, gPlayerName[index])
    
	return PLUGIN_HANDLED_MAIN;
}

public clcmdSayTeam( index )
{
	static said[191]; read_args(said, 190); remove_quotes(said); replace_all(said, 190, "%", ""); replace_all(said, 190, "#", "");

	new contador[TOTAL_LTS]

	for( new i = 0; i < strlen(said) ; i++)
    {
        switch(said[i])
        {
            case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' : contador[NUM]++
            
            case '.' : contador[POINT]++
            
            case ':' : contador[DPOINT]++
            
            case 'w' : contador[WWW]++
            
        }
    }

	if(contador[NUM] >= 5 && contador[POINT] || (contador[WWW] >= 3 && containi(said,".com"))|| contador[NUM] >= 3 || contador[NUM] >= 2 && contador[POINT])
	{
		client_print(0, print_chat, "[Anti-Spam] Mensaje bloqueado. Considerado Spam")
		return PLUGIN_HANDLED
	}

	if (!ValidMessage(said, 1)) return PLUGIN_CONTINUE;

	static playerTeam, playerTeamName[20]; playerTeam = get_user_team(index);

	switch (playerTeam)
	{
		case 1: formatex( playerTeamName, 19, "^x01(^x03 CT^x01 ) " );
		case 2: formatex( playerTeamName, 19, "^x01(^x03 TT^x01 ) " );
		default: formatex( playerTeamName, 19, "^x01(^x03 SPEC^x01 ) " );
	}

	static color[11], prefix[128]; get_user_team(index, color, 10); 
	formatex(prefix, 127, "%s%s^x04%s^x03 %s", is_user_alive(index)?"^x01":"^x01*DEAD* ", playerTeamName, gSzTag[index], gPlayerName[index]);

	if (is_user_admin(index)) format(said, charsmax(said), "^x04%s", said);

	format(said, charsmax(said), "%s^x01 : %s", prefix, said);

	static i, team[11];
	for (i = 1; i <= gMaxPlayers; ++i)
	{
		if (!is_user_connected(i) || get_user_team(i) != playerTeam) continue;

		get_user_team(i, team, 10);
		changeTeamInfo(i, color);
		writeMessage(i, said);
		changeTeamInfo(i, team);
	}	
	log_to_file(chat, "%s", said, gPlayerName[index] )
	return PLUGIN_HANDLED_MAIN;
}

stock ValidMessage(text[], maxcount) 
{
	static len, i, count;
	len = strlen(text);
	count = 0;

	if (!len) return false;

	for (i = 0; i < len; ++i) 
	{
		if (text[i] != ' ') 
		{
			++count;
			
			if (count >= maxcount)
				return true;
		}
	}

	return false;
}

public changeTeamInfo(player, team[])
{
	static msgteamInfo;
	if( !msgteamInfo ) msgteamInfo = get_user_msgid( "TeamInfo" );

	message_begin(MSG_ONE, msgteamInfo, _, player);
	write_byte(player);
	write_string(team);
	message_end();
}

public writeMessage(player, message[])
{
	static msgSayText;
	if( !msgSayText ) msgSayText = get_user_msgid( "SayText" );

	message_begin(MSG_ONE, msgSayText, {0, 0, 0}, player);
	write_byte(player);
	write_string(message);
	message_end();
}

stock check_user_name(id, const name[32] = "") 
{
    new plrname[32]
    
    if(equal(name, ""))
    {
        get_user_name(id, plrname, 31)
    }
    else
    {
        plrname = name
    }
    
    new g_returnvalue, g_error[64]
    new Regex:g_result = regex_match(plrname, PATTERN, g_returnvalue, g_error, 63)
    switch(g_result)
    {
        case REGEX_MATCH_FAIL, REGEX_PATTERN_FAIL:
        {
            return log_amx("REGEX ERROR! %s", g_error)
        }
        
        case REGEX_NO_MATCH:
        {
            return 0
        }
        
        default:
        {
            new name[33]
            get_user_name(id, name, 32)
            client_cmd(id, "name ^"[SVL] USER ^"")
            client_print(0, print_chat, "[Anti-Spam] %s Intento Cambiarse el Nombre", name)
            server_cmd("kick %s", name)
        
            return 1
        }
    }
    
    return -1

}
public MessageNameChange(msgid, dest, id)
{
    new szInfo[64] 

    get_msg_arg_string(2, szInfo, 63) 

    if(!equali(szInfo, "#Cstrike_Name_Change"))
    {
        return PLUGIN_CONTINUE    
    }
    
    return PLUGIN_HANDLED
}