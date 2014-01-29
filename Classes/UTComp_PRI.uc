/* UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Jo�l Moffatt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. */

class UTComp_PRI extends LinkedReplicationInfo;
//=========================
//VARS USED BY CTF UTCOMP
var int numPickups;
var int numReturns;
var int numConvertions;
var int numTimedReturns;
var int numCoverKills;
var int numFCKills;
var int numDAssists;
var int numPulls;
var int numCaps;
var int numAssists;

//-----------
var int Oscore; //Offensive score
var int DScore; //Defensive score
//=========================



var int PickedUpFifty;
var int PickedUpHundred;
var int PickedUpAmp;
var int PickedUpVial;
var int PickedUpHealth;
var int PickedUpKeg;
var int PickedUpAdren;


var int NormalWepStatsAlt[15];
var int NormalWepStatsPrim[15];

var int NormalWepStatsAltHit[15];
var int NormalWepStatsPrimHit[15];

var string ColoredName;
var int RealKills;
var bool bIsReady;
var byte CoachTeam;
var byte Vote;
var byte VoteSwitch;
var byte VoteSwitch2;
var byte VotedYes, VotedNo;
var bool bShowSelf;
var string VoteOptions;
var string VoteOptions2;

var bool bSendWepStats;

var int DamR;

var byte CurrentVoteID;
var bool bWantsMapList;
var bool bReplied;
var int CurrentMapsSent;
var array<string> UTCompMapList;
var array<string> UTCompMapListClient; //necessary due to IA
var int TotalMapsToBeReceived;

var bool bIsLegitPlayer;
var int totaldamageg;

const iMAXPLAYERS = 8;

struct TeamOverlayInfo
{
    var byte Armor;
    var byte Weapon;
    var int Health;
    var PlayerReplicationInfo PRI;
};

var byte bHasDD[iMAXPLAYERS];


var TeamOverlayInfo OverlayInfo[iMAXPLAYERS];

var bool bMapListCompleted;

var class<DamageType> WepStatDamTypesAlt[15];
var class<DamageType> WepStatDamTypesPrim[15];
var localized string WepStatNames[15];

replication
{

    reliable if ( bNetDirty && (Role == Role_Authority) )
      OScore, DScore;
    reliable if(Role==Role_Authority)
         bIsReady, CoachTeam, CurrentVoteID,
         ColoredName, RealKills;
    unreliable if(Role==Role_Authority && bNetOwner)
        PickedUpFifty, PickedUpHundred, PickedUpAmp,
        PickedUpVial, PickedUpHealth, PickedUpKeg,
        PickedUpAdren, DamR, VoteSwitch, VoteOptions,
        Vote, VoteOptions2, VoteSwitch2, numPickups, numReturns, numConvertions, numTimedReturns, numCoverKills, numFCKills, numDAssists, numPulls, numCaps, numAssists;
    unreliable if(Role==Role_Authority && bNetOwner && bSendWepStats)
        NormalWepStatsPrim, NormalWepStatsAlt;
    unreliable if(Role==Role_Authority && bNetOwner)
        OverlayInfo, VotedYes, VotedNo, bHasDD;
    reliable if(Role<Role_Authority)
        Ready, NotReady, SetVoteMode, SetCoachTeam,
        CallVote, PassVote, SetColoredName, SetShowSelf, GetMapList, ReplyToMapSend;

    reliable if(Role==Role_Authority && bNetOwner)
        MapListSend, SendTotalMapNumber;
}

function CallVote(byte b, byte switch, string Options, optional byte P2, optional string Options2)
{
    local UTComp_VotingHandler uVote;

    foreach DynamicActors(class'UTComp_VotingHandler', uVote)
    {
        if(uVote.StartVote(b,switch,Options, p2, options2, false))
            Vote=1;
    }
}

function PassVote(byte b, byte switch, string Options, optional byte P2, optional string Options2)
{
    local UTComp_VotingHandler uVote;

    foreach DynamicActors(class'UTComp_VotingHandler', uVote)
    {
        if(uVote.StartVote(b,switch,Options, p2, options2, True))
            Vote=1;
    }
}

function NotReady()
{
    bIsReady=False;
}

function Ready()
{
    bIsReady=True;
}

function SetCoachTeam(byte b)
{
    CoachTeam=b;
}

function SetVoteMode(byte b)
{
    Vote=b;
}

function ClearStats()
{
    local int i;
    for(i=0; i<15; i++)
    {
        NormalWepStatsAlt[i]=0;
        NormalWepStatsPrim[i]=0;
    }
    DamR=0;
    numFCKills=0;
    numDAssists=0;
    numPulls=0;
    numCaps=0;
    numAssists=0;
    PickedUpFifty=0;
    PickedUpHundred=0;
    PickedUpAmp=0;
    PickedUpVial=0;
    PickedUpHealth=0;
    PickedUpKeg=0;
    PickedUpAdren=0;
    RealKills=0;
    TotalDamageG=0;
    numPickups=0;
    numReturns=0;
    numConvertions=0;
    numTimedReturns=0;
    numCoverKills=0; 
    OScore=0;
    DScore=0;
}

function SetColoredName(string S)
{
    ColoredName=S;
}

function SetShowSelf(bool b)
{
    bShowSelf=b;
}

function string MakeSafeName(string S)
{
    local int i;
    local bool NotSafeYet;

    while(Len(S)>0 && NotSafeYet)
    {
        NotSafeYet=False;
        for(i=1; i<4; i++)
        {
            if(Mid(S, Len(S)-i)==chr(0x1B))
            {
                S=Left(S,Len(S)-i);
                NotSafeYet=True;
                break;
            }
        }
    }
    return S;
}

event Tick(float DeltaTime)
{
    if(bWantsMapList && bReplied)
    {
        bReplied=False;
        ServerSendMapList();
    }

    super.Tick(DeltaTime);
}

function ReplyToMapSend()
{
    bReplied=True;
}

function GetMapList()
{
    if(bMapListCompleted)
       return;
    bWantsMapList=True;
    ServerSendMapList();
    SendTotalMapNumber(UTCompMapList.Length);
}

function SendTotalMapNumber(int i)
{
    TotalMapsToBeReceived=i;
}

simulated function MapListSend(string S)
{
    if(Level.NetMode==NM_DedicatedServer)
        return;
    if(!(Left(S, 4) ~="Tut-" || Left(S, 4) ~="Mov-"))
        UTCompMapListClient[UTCompMapListClient.Length]=S;
    ReplyToMapSend();
}

function ServerSendMapList()
{
    if(CurrentMapsSent==0)
    {
        Level.Game.LoadMapList("", UTCompMapList);
    }
    if(UTCompMapList.Length==0)
        bWantsMapList=False;
    if(CurrentMapsSent<UTCompMapList.Length)
    {
        MapListSend(UTCompMapList[CurrentMapsSent]);
        CurrentMapsSent+=1;
    }
    else
    {
        bWantsMapList=False;
        bMapListCompleted=True;
    }
}

defaultproperties
{
     CoachTeam=255
     Vote=255
     VoteSwitch=255
     bSendWepStats=True
     CurrentVoteID=255
}
