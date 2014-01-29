/* UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Joël Moffatt

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

class UTComp_Menu_OpenedMenu extends UTComp_Menu_MainMenu;

var automated array<GUILabel> l_Mode;
var automated GUIImage i_UTCompLogo;
var automated GUIButton bu_Ready, bu_NotReady;

var color GoldColor;

var UTComp_ServerReplicationInfo RepInfo;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(myController,MyOwner);
    l_Mode[2].Caption="UTComp Version"$class'Gameinfo'.Static.MakeColorCode(GoldColor)$" Src";
}

function RandomCrap()
{
    if(RepInfo==None)
       foreach PlayerOwner().ViewTarget.DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
          break;

    if (RepInfo.EnableBrightSkinsMode == 1)
        l_Mode[0].Caption = class'Gameinfo'.Static.MakeColorCode(GoldColor)$"Brightskins Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Brightskins Disabled";
    else if (RepInfo.EnableBrightSkinsMode == 2)
        l_Mode[0].Caption = class'Gameinfo'.Static.MakeColorCode(GoldColor)$"Brightskins Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Bright Epic Style Skins";
    else if (RepInfo.EnableBrightSkinsMode == 3)
        l_Mode[0].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Brightskins Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  UTComp Style Skins";
    if (RepInfo.EnableHitSoundsMode == 0)
       l_Mode[1].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Hitsounds Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Disabled";
    else if (RepInfo.EnableHitSoundsMode == 1)
       l_Mode[1].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Hitsounds Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Line Of Sight";
    else if (RepInfo.EnableHitSoundsMode == 2)
       l_Mode[1].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Hitsounds Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Everywhere";
    if(RepInfo.benableDoubleDamage)
       l_Mode[3].Caption =class'gameinfo'.Static.MakeColorCode(GoldColor)$"Double Damage Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$" Enabled";
    else
       l_Mode[3].Caption =class'GameInfo'.Static.MakeColorCode(GoldColor)$"Double Damage Mode:"$class'GameInfo'.Static.MakeColorCode(WhiteColor)$" Disabled";
    if(RepInfo.bEnableEnhancedNetCode)
       l_Mode[5].Caption =class'gameinfo'.Static.MakeColorCode(GoldColor)$"Enhanced Netcode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$" Enabled";
    else
       l_Mode[5].Caption =class'GameInfo'.Static.MakeColorCode(GoldColor)$"Enhanced Netcode:"$class'GameInfo'.Static.MakeColorCode(WhiteColor)$" Disabled";

   if(!PlayerOwner().PlayerReplicationInfo.bOnlySpectator)
   {
     bu_Ready.Caption="Ready";
     bu_NotReady.Caption="Not Ready";
   }
   else
   {
     bu_Ready.Caption="Coach Red";
     bu_NotReady.Caption="Coach Blue";
   }
}

event opened(GUIComponent Sender)
{
    super.Opened(Sender);
    RandomCrap();
}

function bool InternalOnClick( GUIComponent C )
{

    switch (C)
    {
      case bu_Ready:   if(PlayerOwner().IsA('BS_xPlayer'))
                           {
                              if(PlayerOwner().PlayerReplicationInfo.bOnlySpectator)
                                BS_xPlayer(PlayerOwner()).SpecLockRed();
                              else
                                BS_xPlayer(PlayerOwner()).Ready();
                           }
                           PlayerOwner().ClientCloseMenu();
                           return false;

      case bu_NotReady:
                           if(PlayerOwner().IsA('BS_xPlayer'))
                           {
                              if(PlayerOwner().PlayerReplicationInfo.bOnlySpectator)
                                BS_xPlayer(PlayerOwner()).SpecLockBlue();
                              else
                                BS_xPlayer(PlayerOwner()).NotReady();
                           }
                           PlayerOwner().ClientCloseMenu();
                           return false;
    }

    return super.internalonclick(C);
}

defaultproperties
{
     l_Mode(0)=GUILabel'utcompvSrc.UTComp_Menu_OpenedMenu.BrightSkinsModeLabel'
     l_Mode(1)=GUILabel'utcompvSrc.UTComp_Menu_OpenedMenu.HitSoundsModeLabel'
     l_Mode(2)=GUILabel'utcompvSrc.UTComp_Menu_OpenedMenu.VersionLabel'
     l_Mode(3)=GUILabel'utcompvSrc.UTComp_Menu_OpenedMenu.AmpModeLabel'
     l_Mode(4)=GUILabel'utcompvSrc.UTComp_Menu_OpenedMenu.NewVersions'
     l_Mode(5)=GUILabel'utcompvSrc.UTComp_Menu_OpenedMenu.NetCodeModeLabel'
     l_Mode(6)=GUILabel'utcompvSrc.UTComp_Menu_OpenedMenu.ServerSetLabel'
     Begin Object Class=GUIImage Name=UTCompLogo
         Image=Texture'utcompvSrc.UTCompLogo'
         ImageStyle=ISTY_Scaled
         WinTop=0.307113
         WinLeft=0.312500
         WinWidth=0.375000
         WinHeight=0.125000
     End Object
     i_UTCompLogo=GUIImage'utcompvSrc.UTComp_Menu_OpenedMenu.UTCompLogo'

     Begin Object Class=GUIButton Name=ReadyButton
         WinTop=0.650000
         WinLeft=0.250000
         WinWidth=0.200000
         WinHeight=0.060000
         OnClick=UTComp_Menu_OpenedMenu.InternalOnClick
         OnKeyEvent=ReadyButton.InternalOnKeyEvent
     End Object
     bu_Ready=GUIButton'utcompvSrc.UTComp_Menu_OpenedMenu.ReadyButton'

     Begin Object Class=GUIButton Name=NotReadyButton
         WinTop=0.650000
         WinLeft=0.550000
         WinWidth=0.200000
         WinHeight=0.060000
         OnClick=UTComp_Menu_OpenedMenu.InternalOnClick
         OnKeyEvent=NotReadyButton.InternalOnKeyEvent
     End Object
     bu_NotReady=GUIButton'utcompvSrc.UTComp_Menu_OpenedMenu.NotReadyButton'

     GoldColor=(G=200,R=230)
}
