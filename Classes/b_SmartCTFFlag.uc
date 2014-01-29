class b_SmartCTFFlag extends CTFFlag;

var int rtnScores[4];
var int cnvrtScores[4];
var int dAssScores[4];
var int pkpScores[8];
var int znDrpd;
var Controller convKillr, returner;
var float lstRtnTime, lstDropTime;
var array<pawn> Covers;
var array<int> CoverNums;




state Dropped
{

   ignores Drop;
   

   function SameTeamTouch(Controller c)
   {
      
   		local int znDropped;
                local UTComp_PRI uPRI, upi;
	        uPRI=class'UTComp_Util'.static.GetUTCompPRI(PlayerController(c).PlayerReplicationInfo);
	 
    		
		if ( C.PlayerReplicationInfo.Team == self.Team )
		{
                        uPRI.numReturns++;
			returner = c;
			UnrealMPGameInfo(Level.Game).GameEvent("flag_returned",""$self.Team.TeamIndex,C.PlayerReplicationInfo);
			znDropped = calcZone(self);
                	BroadcastLocalizedMessage( class'CTFMessage',1, c.PlayerReplicationInfo, None, self.Team );
                        if(c == convKillr)
                        {
                          //BroadcastLocalizedMessage( class'CTFTestMessage',5, c.PlayerReplicationInfo, None, self.Team );
		          uPRI.DScore += default.cnvrtScores[znDropped];
                          uPRI.numConvertions++;
			  xPlayer(c).ClientMessage("..CONVERSION..");
				
			} 
                        else
                        {
                         if(convKillr != none)
			 {
                           uPI=class'UTComp_Util'.static.GetUTCompPRI(PlayerController(convKillr).PlayerReplicationInfo);
                           uPI.numDAssists++;
                           uPI.DScore += default.dAssScores[znDropped];  
                           //xPlayer(c).ClientMessage("..DEFENSIVE ASSIST..");
                         }
                        }
			uPRI.DScore += default.rtnScores[znDropped];
			if(znDropped == 3)
		        {
                       	     //xPlayer(c).ClientMessage("..LAST SECOND SAVE..");
                             Level.Game.ScoreEvent(C.PlayerReplicationInfo,7,"flag_denial");
			
                        }
                        //UnrealMPGameInfo(Level.Game).ScoreEvent(C.PlayerReplicationInfo,default.rtnScores[znDropped],"flag_ret_friendly");             
			convKillr = none;
			znDrpd = -1;
		}
	        lstRtnTime = Level.TimeSeconds;
		while (Covers.Length!=0)
	          Covers.Remove(0,1);
		while (CoverNums.Length!=0)
	          CoverNums.Remove(0,1);
		
		SendHome();
    }

    function LogTaken(Controller c)
    {
        local UTComp_PRI uPRI;
	local int znPckd;
        uPRI=class'UTComp_Util'.static.GetUTCompPRI(PlayerController(c).PlayerReplicationInfo);
        if(oldHolder != c.pawn)
        {
          uPRI.numPickups++;
          znpckd = calcZone(self);
          if(Level.TimeSeconds - lstDropTime <= 2.0)
          {
            //xPlayer(c).ClientMessage("..QUICK PICKUP..");
            znPckd+=4;
          }
          else
            //xPlayer(c).ClientMessage("..PICKUP..");
          uPRI.OScore += default.pkpScores[znPckd];
        }
        UnrealMPGameInfo(Level.Game).GameEvent("flag_pickup",""$Team.TeamIndex,C.PlayerReplicationInfo);
        BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, Team );
    }

    function BeginState()
    {
      super.BeginState();
      lstDropTime = Level.TimeSeconds;
    }

    //function EndState()
    //{
     //   Super.EndState();
       // lstDropTime=-1; 
    //}






  /*    function CheckFit()
    {
	    local vector X,Y,Z;

	    GetAxes(OldHolder.Rotation, X,Y,Z);
	    SetRotation(rotator(-1 * X));
	    if ( !SetLocation(OldHolder.Location - 2 * OldHolder.CollisionRadius * X + OldHolder.CollisionHeight * vect(0,0,0.5))
		    && !SetLocation(OldHolder.Location) )
	    {
		    SetCollisionSize(0.8 * OldHolder.CollisionRadius, FMin(CollisionHeight, 0.8 * OldHolder.CollisionHeight));
		    if ( !SetLocation(OldHolder.Location) )
		    {
                //log(self$" Drop sent flag home", 'Error');
				UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
				BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
			    SendHome();
			    return;
		    }
	    }
    }

    function CheckPain()
    {
        if (IsInPain())
            timer();
    }

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
	{
        CheckPain();
	}

	singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		Super.PhysicsVolumeChange(NewVolume);
        CheckPain();
	}

	function BeginState()
	{
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Down;
        Super.BeginState();
	    bCollideWorld = true;
	    SetCollisionSize(0.5 * default.CollisionRadius, CollisionHeight);
        SetCollision(true, false, false);
        CheckFit();
        CheckPain();
		SetTimer(MaxDropTime, false);
	}

    function EndState()
    {
        Super.EndState();
	bCollideWorld = false;
	SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
        
    }

	function Timer()
	{
		BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
		UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
		Super.Timer();
	} */
}

auto state Home
{
    ignores SendHome, Score, Drop;

    function SameTeamTouch(Controller c)
    {
        local CTFFlag TheFlag;
        local Controller Scorer;
        local float ppp;
        local UTComp_PRI uPRI, uPRI2;
        local int i, numtouch;
    
	uPRI=class'UTComp_Util'.static.GetUTCompPRI(PlayerController(c).PlayerReplicationInfo);
	 


        if (C.PlayerReplicationInfo.HasFlag == None)
            return;

        // Score!
        uPRI.numCaps++;
        if(Level.TimeSeconds - lstRtnTime <= 2.0 && lstDropTime - lstRtnTime >= 2.0)
	{ 
           //BroadcastLocalizedMessage( class'CTFTestMessage',6, c.PlayerReplicationInfo, None, self.Team );
           //xPlayer(c).ClientMessage("..TIMED CAP..");
	  // xPlayer(returner).ClientMessage("..TIMED RETURN..");
	   uPRI2=class'UTComp_Util'.static.GetUTCompPRI(PlayerController(returner).PlayerReplicationInfo);
	   uPRI2.numTimedReturns++;	
           uPRI.numTimedReturns++;
           uPRI.OScore+=10;
	   uPRI2.DScore+=10;
        }
        TheFlag = CTFFlag(C.PlayerReplicationInfo.HasFlag);
        
        //UnrealMPGameInfo(Level.Game).ScoreGameObject(C, flag);
        //*******HUGE MODIF*********************
        // Figure out Team based scoring.
        Scorer = C;
	if (TheFlag.FirstTouch==C&&TheFlag.Assists.length==1)	//ONE MAN RUN
	{
		//Level.Game.ScoreEvent(TheFlag.FirstTouch.PlayerReplicationInfo,5,"flag_cap_1st_touch");
		uPRI.OScore += 10;
		TheFlag.FirstTouch.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	}
        else //Multiple mans run
        {
	 // Guy who caps gets 7
	 Scorer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	 uPRI.OScore += 7;
 	 

	 //wtf well do for zonal assists?
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
                       // xPlayer(TheFlag.Assists[i]).ClientMessage("..ASSIST..");
                        uPRI=class'UTComp_Util'.static.GetUTCompPRI(TheFlag.Assists[i].PlayerReplicationInfo);
		 	Level.Game.ScoreEvent(TheFlag.Assists[i].PlayerReplicationInfo,ppp,"flag_cap_assist");
			uPRI.OScore += 4;
			uPRI.numAssists++;	
		 }
	 }
        }
        CTFGame(Level.Game).IncrementGoalsScored(Scorer.PlayerReplicationInfo);

	// Apply the team score
	Scorer.PlayerReplicationInfo.Team.Score += 1.0;
	Scorer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
	CTFGame(Level.Game).ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_cap_final");
	CTFGame(Level.Game).TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex,1,"flag_cap");
	CTFGame(Level.Game).GameEvent("flag_captured",""$theflag.Team.TeamIndex,Scorer.PlayerReplicationInfo);

	BroadcastLocalizedMessage( class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag.Team );
	CTFGame(Level.Game).AnnounceScore(Scorer.PlayerReplicationInfo.Team.TeamIndex);
	CTFGame(Level.Game).CheckScore(Scorer.PlayerReplicationInfo);

    if ( CTFGame(Level.Game).bOverTime )
    {
		CTFGame(Level.Game).EndGame(Scorer.PlayerReplicationInfo,"timelimit");
    }




        //***************************************






        TheFlag.Score();
		TriggerEvent(HomeBase.Event,HomeBase,C.Pawn);
        if (Bot(C) != None)
            Bot(C).Squad.SetAlternatePath(true);
    }

    function LogTaken(Controller c)
    {
        local UTComp_PRI uPRI;
	uPRI=class'UTComp_Util'.static.GetUTCompPRI(PlayerController(c).PlayerReplicationInfo);
        uPRI.numPulls++;
       // xPlayer(c).ClientMessage("..PULL..");	
        uPRI.OScore += 1;
        BroadcastLocalizedMessage( MessageClass, 6, C.PlayerReplicationInfo, None, Team );
        UnrealMPGameInfo(Level.Game).GameEvent("flag_taken",""$Team.TeamIndex,C.PlayerReplicationInfo);
    }

	function Timer()
	{
		if ( VSize(Location - HomeBase.Location) > 10 )
		{
			UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
            log(self$" Home.Timer: had to sendhome", 'Error');
			SendHome();
		}
	}

	function BeginState()
	{
        Super.BeginState();
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Home;
		bHidden = true;
		HomeBase.bHidden = false;
		HomeBase.Timer();
		HomeBase.NetUpdateTime = Level.TimeSeconds - 1;
		SetTimer(1.0, true);
	}

	function EndState()
	{
        Super.EndState();
		bHidden = false;
		HomeBase.bHidden = true;
		HomeBase.PlayAlarm();
		HomeBase.NetUpdateTime = Level.TimeSeconds - 1;
		SetTimer(0.0, false);
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

function int calcZone(b_SmartCTFFlag theFlag)
{
  local Vector vTemp, vPos, vProj;
  local float distFromFlag, distFlagtoFlag, ratio; 

  if(XCTFGame(Level.Game).Teams[1].HomeBase != None && XCTFGame(Level.Game).Teams[0].HomeBase != None)
  {
    if(theFlag.HomeBase == XCTFGame(Level.Game).Teams[0].HomeBase)
    {
      if(VSize(theFlag.Location - XCTFGame(Level.Game).Teams[1].HomeBase.Location)<1024)
        return 3; 
      vTemp =  XCTFGame(Level.Game).Teams[1].HomeBase.Location -  XCTFGame(Level.Game).Teams[0].HomeBase.Location;
      vPos =  theFlag.Location -  XCTFGame(Level.Game).Teams[0].HomeBase.Location;

    }
    else
    {
      if(VSize(theFlag.Location - XCTFGame(Level.Game).Teams[0].HomeBase.Location)<1024)
        return 3;
      vTemp =  XCTFGame(Level.Game).Teams[0].HomeBase.Location -  XCTFGame(Level.Game).Teams[1].HomeBase.Location;
      vPos =  theFlag.Location -  XCTFGame(Level.Game).Teams[1].HomeBase.Location; 
    }
    vProj = OrthogonalProjection2D(vPos, vTemp);
    distFromFlag = VSize(vProj);
    distFlagtoFlag = VSize(vTemp); 
    ratio = distFromFlag/distFlagToFlag;
   
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

defaultproperties
{
     rtnScores(0)=1
     rtnScores(1)=3
     rtnScores(2)=5
     rtnScores(3)=7
     cnvrtScores(1)=3
     cnvrtScores(2)=6
     cnvrtScores(3)=8
     dAssScores(0)=1
     dAssScores(1)=2
     dAssScores(2)=3
     dAssScores(3)=3
     pkpScores(0)=1
     pkpScores(1)=2
     pkpScores(2)=3
     pkpScores(3)=3
     pkpScores(4)=2
     pkpScores(5)=3
     pkpScores(6)=4
     pkpScores(7)=4
}
