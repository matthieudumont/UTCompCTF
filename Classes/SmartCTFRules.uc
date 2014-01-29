class SmartCTFRules extends GameRules;

var MutUTComp utcompMutator;
var float coverRadius;
var int FCScores[4];
var int cvrScores[4];

//for (i=0;i<Assists.Length;i++)
		//if (Assists[i] == C)

function ScoreKill(Controller Killer, Controller Killed)
{
	 local int znKilled, i, ind;
         local bool fCover, fcKiller;
	 local UTComp_PRI uPRI;

	 fCover=False;
	 fcKiller = False;
         if(Killer.PlayerReplicationInfo.HasFlag!= none)
		fcKiller = True;
	 
         uPRI=class'UTComp_Util'.static.GetUTCompPRI(PlayerController(Killer).PlayerReplicationInfo);
       
         //Prevention Kill
	 
	 
	 if(Killed.PlayerReplicationInfo.HasFlag!= none)
         {
           uPRI.numFCKills++;
	   znKilled = b_smartCTFFlag(Killed.PlayerReplicationInfo.HasFlag).calcZone(b_smartCTFFlag(Killed.PlayerReplicationInfo.HasFlag)); 
           //FCKill Bonus
	   uPRI.DScore += default.FCScores[znKilled];         

	   //Sets up eventual convertion
           b_SmartCTFFlag(Killed.PlayerReplicationInfo.HasFlag).convKillr = Killer;  
         }
         else if(vsize(CTFBase(Killer.PlayerReplicationInfo.Team.HomeBase).Location - Killed.pawn.Location) <= 1240 && !fcKiller && CTFBase(Killer.PlayerReplicationInfo.Team.HomeBase).myFlag.bHome && Killer != Killed && Killer != none)
	 { 
           uPRI.DScore += 2;
	   //xPlayer(Killer).ClientMessage("..PREVENTION KILL.."); 
         }   
         
         //Look for cover Kill
	 if((CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag.Holder != none))//&&(Killer!= Killed)&&(Killed != none)&&(Killer!=none))
	 {

                znKilled = b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).calcZone(b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag));
	 	if(vsize(Killed.pawn.Location - CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag.Holder.Location) <= coverRadius){
		  //BroadcastLocalizedMessage( class'CTFTestMessage',4, Killer.PlayerReplicationInfo, None, CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag); //For debugging    
                  uPRI.OScore += default.cvrScores[znKilled];
		  if(!fcKiller) 
                    //xPlayer(Killer).ClientMessage("..COVER KILL..");
                                  
  		  for (i=0;i<b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length;i++)
                  {
		    if (b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers[i] == Killer.Pawn )
		    { 
                      fCover = True;
                      ind = i; 
                    }
                  }

                  if(!fCover&&!fcKiller)
                  {  
		    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length = b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length+1;
                    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers[b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length-1] = Killer.Pawn;
                    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums.Length = b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums.Length+1;
                    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums[b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums.Length-1] = 1;	
		  }
                  else
                  {
		    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums[ind]++;
                    if(b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums[ind]==3)
                    {
		       PlayerController(Killer).ReceiveLocalizedMessage( class'CoverSpreeMessage', 0, Killed.PlayerReplicationInfo );
                       //xPlayer(Killer).ClientMessage("..!!COVER SPREE!!..");                    
		    }
		  }  
                  uPRI.numCoverKills++;
		}
		else if(vsize(Killer.pawn.Location - CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag.Holder.Location) <= coverRadius) //If its a cover kill
    	        {
		  //BroadcastLocalizedMessage( class'CTFTestMessage',3, Killer.PlayerReplicationInfo, None, CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag); //For debugging    
         	  uPRI.numCoverKills++;
		  if(!fcKiller)
		    //xPlayer(Killer).ClientMessage("..COVER KILL..");
		for (i=0;i<b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length;i++)
                  {
		    if (b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers[i] == Killer.Pawn )
		    { 
                      fCover = True;
                      ind = i; 
                    }
                  }

                  if(!fCover)
                  {  
		    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length = b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length+1;
                    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers[b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).Covers.Length-1] = Killer.Pawn;
                    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums.Length = b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums.Length+1;
                    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums[b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums.Length-1] = 1;	
		  }
                  else
                  {
		    b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums[ind]++;
                    if(b_smartCTFFlag(CTFBase(Killed.PlayerReplicationInfo.Team.HomeBase).myFlag).CoverNums[ind]==3)
                    {
                        PlayerController(Killer).ReceiveLocalizedMessage( class'CoverSpreeMessage', 0, Killed.PlayerReplicationInfo );
                    	//xPlayer(Killer).ClientMessage("..!!COVER SPREE!!..");                    
		    }
                  }  
		  uPRI.OScore += default.cvrScores[znKilled];
                }
	 }
         super.ScoreKill(Killer, Killed);
	 if ( NextGameRules != None )
	  NextGameRules.ScoreKill(Killer,Killed);
}

defaultproperties
{
     coverRadius=2048.000000
     FCScores(0)=2
     FCScores(1)=3
     FCScores(2)=4
     FCScores(3)=5
     cvrScores(0)=2
     cvrScores(1)=3
     cvrScores(2)=4
     cvrScores(3)=4
}
