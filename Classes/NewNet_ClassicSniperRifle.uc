/*
UTComp - UT2004 Mutator
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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NewNet_ClassicSniperRifle extends ClassicSniperRifle
    HideDropDown
	CacheExempt;

var TimeStamp T;
var MutUTComp M;

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire;
}

function DisableNet()
{
    NewNet_ClassicSniperFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_ClassicSniperFire(FireMode[0]).PingDT = 0.00;
}

simulated function ClientStartFire(int mode)
{
    if (mode == 1)
    {
        FireMode[mode].bIsFiring = true;
        if( Instigator.Controller.IsA( 'PlayerController' ) )
            PlayerController(Instigator.Controller).ToggleZoom();
    }
    else
    {
        SuperClientStartFire(mode);
    }
}

simulated event SuperClientStartFire(int Mode)
{
    if(Level.NetMode!=NM_Client || !class'BS_xPlayer'.static.UseNewNet())
        super(Weapon).ClientStartFire(mode);
    else
        NewNet_ClientStartFire(mode);
}

simulated event NewNet_ClientStartFire(int Mode)
{
    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            if(T==None)
                foreach DynamicActors(class'TimeStamp', T)
                     break;

            NewNet_ServerStartFire(mode, T.ClientTimeStamp);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

function NewNet_ServerStartFire(byte Mode, float ClientTimeStamp)
{
    if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
	        break;

    if(NewNet_ClassicSniperFire(FireMode[Mode])!=None)
    {
        NewNet_ClassicSniperFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
        NewNet_ClassicSniperFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    ServerStartFire(Mode);
}

defaultproperties
{
     FireModeClass(0)=Class'utcompvSrc.NewNet_ClassicSniperFire'
     PickupClass=Class'utcompvSrc.NewNet_ClassicSniperRiflePickup'
}
