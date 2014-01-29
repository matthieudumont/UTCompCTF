//-----------------------------------------------------------
//Matthieu Dumont - 2006
//-----------------------------------------------------------
class CTFTestMessage extends CTFMessage;


static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
 if(Switch==0)
 {
   return "in home zone"; 
 }
 if(Switch==1)
 {
   return "in neutral zone"; 
 }
 if(Switch==3)
 {
   return "COVER KILL killer close"; 
 }
  if(Switch==4)
 {
   return "COVER KILL killed close"; 
 }
  if(Switch==5)
 {
   return "** CONVERTION **"; 
 }
 if(Switch==6)
 {
   return "** TIMED RETURN OMGOMG **"; 
 }
 else
   return "in ennemy zone";
}

defaultproperties
{
}
