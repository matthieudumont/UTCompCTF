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

class UTComp_Vote_Started extends CriticalEventPlus;

#exec AUDIO IMPORT FILE=Sounds\error2.wav	GROUP=Sounds

var Sound error2;

static simulated function ClientReceive (PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	P.PlayAnnouncement(Default.error2,1,True);
}

defaultproperties
{
     error2=Sound'utcompvSrc.Sounds.error2'
}
