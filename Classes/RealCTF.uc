class RealCTF extends xCTFGame;


var int rtnScores[3];
var float coverRadius;




function ScoreFlag(Controller Scorer, CTFFlag theFlag)
{
	local float Dist,oppDist;
	local int i;
	local float ppp,numtouch;
	local vector FlagLoc;
        local int znDropped;

	if ( Scorer.PlayerReplicationInfo.Team == theFlag.Team )
	{
		Scorer.AwardAdrenaline(ADR_Return);
		FlagLoc = TheFlag.Position().Location;
		Dist = vsize(FlagLoc - TheFlag.HomeBase.Location);

		if (TheFlag.TeamNum==0)
			oppDist = vsize(FlagLoc - Teams[1].HomeBase.Location);
		else
  			oppDist = vsize(FlagLoc - Teams[0].HomeBase.Location);

		GameEvent("flag_returned",""$theFlag.Team.TeamIndex,Scorer.PlayerReplicationInfo);
		znDropped = calcZone(theFlag);
                BroadcastLocalizedMessage( class'CTFMessage',1, Scorer.PlayerReplicationInfo, None, TheFlag.Team );
		BroadcastLocalizedMessage( class'CTFTestMessage',znDropped, Scorer.PlayerReplicationInfo, None, TheFlag.Team );
		//if (Dist>1024)
		//{
			
			
				Scorer.PlayerReplicationInfo.Score += default.rtnScores[znDropped];
				ScoreEvent(Scorer.PlayerReplicationInfo,default.rtnScores[znDropped],"flag_ret_friendly");
			
		//}

             
                
		return;
	}

	// Figure out Team based scoring.
	if (TheFlag.FirstTouch!=None)	// Original Player to Touch it gets 5
	{
		ScoreEvent(TheFlag.FirstTouch.PlayerReplicationInfo,5,"flag_cap_1st_touch");
		TheFlag.FirstTouch.PlayerReplicationInfo.Score += 5;
		TheFlag.FirstTouch.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	}

	// Guy who caps gets 5
	Scorer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	Scorer.PlayerReplicationInfo.Score += 5;
	IncrementGoalsScored(Scorer.PlayerReplicationInfo);
    Scorer.AwardAdrenaline(ADR_Goal);

	// Each player gets 20/x but it's guarenteed to be at least 1 point but no more than 5 points
	numtouch=0;
	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None)
			numtouch = numtouch + 1.0;
	}

	ppp = FClamp(20/numtouch,1,5);

	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None)
		{
			ScoreEvent(TheFlag.Assists[i].PlayerReplicationInfo,ppp,"flag_cap_assist");
			TheFlag.Assists[i].PlayerReplicationInfo.Score += int(ppp);
		}
	}

	// Apply the team score
	Scorer.PlayerReplicationInfo.Team.Score += 1.0;
	Scorer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
	ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_cap_final");
	TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex,1,"flag_cap");
	GameEvent("flag_captured",""$theflag.Team.TeamIndex,Scorer.PlayerReplicationInfo);

	BroadcastLocalizedMessage( class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag.Team );
	AnnounceScore(Scorer.PlayerReplicationInfo.Team.TeamIndex);
	CheckScore(Scorer.PlayerReplicationInfo);

    if ( bOverTime )
    {
		EndGame(Scorer.PlayerReplicationInfo,"timelimit");
    }
} 

//================================================================
//Returns a 2D vector(Z=0) representing the 2D orthogonal 
//projection of Projected on ProjectedOn 
//================================================================
function Vector OrthogonalProjection2D(Vector projected, Vector projectedOn)
{
  local float dotP, prSize;
  local Vector rtnVct;  

  projected.Z = 0;
  projectedOn.Z = 0;

  dotP = projected Dot projectedOn;
  prSize = VSize(projectedOn) * VSize(projectedOn);
  
  Log("OK WERE IN THE ORTHO PRODUCT");  
   
  Log("Projected:"$projected);
  Log("ProjectedOn:"$projectedOn);
  Log("dotP:"$dotP);
  Log("prsize:"$prSize);
  rtnVct = (dotP/prSize) * projectedOn;

  return rtnVct; 
}

function int calcZone(CTFFlag theFlag)
{
  local Vector vTemp, vPos, vProj;
  local float distFromFlag, distFlagtoFlag, ratio; 
  //Log("ZZCC"$Teams[1].HomeBase);
  //Log("ZZCC"$Teams[2].HomeBase);
  if(Teams[1].HomeBase != None && Teams[0].HomeBase != None)
  {
    if(theFlag.HomeBase == Teams[0].HomeBase)
    {
      vTemp =  Teams[1].HomeBase.Location -  Teams[0].HomeBase.Location;
      vPos =  theFlag.Location -  Teams[0].HomeBase.Location;

    }
    else
    {
      vTemp =  Teams[0].HomeBase.Location -  Teams[1].HomeBase.Location;
      vPos =  theFlag.Location -  Teams[1].HomeBase.Location; 
    }
    Log("o flag"$Teams[0].HomeBase.Location);
    Log("1 flag"$Teams[1].HomeBase.Location);
    vProj = OrthogonalProjection2D(vPos, vTemp);
    distFromFlag = VSize(vProj);
    Log("!!-vProj!"$vProj);
    distFlagtoFlag = VSize(vTemp); 
    Log("!!-dftf"$DistFlagtoFlag);
    ratio = distFromFlag/distFlagToFlag;
   
    Log("Ratio:"$ratio);
    if(ratio <= 0.3333)
      return 0; //Home base
    else if( ratio <= 0.666)
     return 1; //Neutral zone
    else
     return 2; //ennemy zone
  }
  else
    return -1;  
}


function ScoreKill(Controller Killer, Controller Other)
{
  super.ScoreKill(Killer, Other);
  if(CTFBase(Other.PlayerReplicationInfo.Team.HomeBase).myFlag.Holder != Killer && CTFBase(Other.PlayerReplicationInfo.Team.HomeBase).myFlag.Holder != none && Killer != none && Killer != other && Other != none) //If its a kill(not suicide) while flag is out.
  {
    if(vsize(Killer.Location - CTFBase(Other.PlayerReplicationInfo.Team.HomeBase).myFlag.Holder.Location) <= coverRadius || vsize(Other.Location - CTFBase(Other.PlayerReplicationInfo.Team.HomeBase).myFlag.Holder.Location) <= coverRadius) //If its a cover kill
    {
    	BroadcastLocalizedMessage( class'CTFTestMessage',3, Killer.PlayerReplicationInfo, None, CTFBase(Other.PlayerReplicationInfo.Team.HomeBase).myFlag); //For debugging    
    }
  }


}

defaultproperties
{
     rtnScores(0)=2
     rtnScores(1)=7
     rtnScores(2)=13
     coverRadius=5000.000000
}
