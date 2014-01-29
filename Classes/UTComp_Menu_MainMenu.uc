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

class UTComp_Menu_MainMenu extends PopupPageBase;

var automated array<GUIButton> UTCompMenuButtons;
var automated GUITabControl c_Main;
var automated FloatingImage i_FrameBG2;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	super.InitComponent(MyController, MyComponent);
}

function bool InternalOnClick(GUIComponent C)
{
    if(C==UTCompMenuButtons[0])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_BrightSkins");

    else if(C==UTCompMenuButtons[1])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_ColorNames");

    else if(C==UTCompMenuButtons[2])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_TeamOverlay");

    else if(C==UTCompMenuButtons[3])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_Crosshairs");

    else if(C==UTCompMenuButtons[4])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_Hitsounds");

    else if(C==UTCompMenuButtons[5])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_Voting");

    else if(C==UTCompMenuButtons[6])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_AutoDemoSS");

    else if(C==UTCompMenuButtons[7])
        PlayerOwner().ClientReplaceMenu("UTCompvSrc.UTComp_Menu_Miscellaneous");

    return false;
}

function OnClose(optional bool bCancelled)
{
   if(PlayerOwner().IsA('BS_xPlayer'))
   {
      BS_xPlayer(PlayerOwner()).ReSkinAll();
      BS_xPlayer(PlayerOwner()).InitializeScoreboard();
      BS_xPlayer(PlayerOwner()).MatchHudColor();
   }
   super.OnClose(bCancelled);
}

defaultproperties
{
     UTCompMenuButtons(0)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.SkinModelButton'
     UTCompMenuButtons(1)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.ColoredNameButton'
     UTCompMenuButtons(2)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.OverlayButton'
     UTCompMenuButtons(3)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.CrosshairButton'
     UTCompMenuButtons(4)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.HitsoundButton'
     UTCompMenuButtons(5)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.VotingButton'
     UTCompMenuButtons(6)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.AutoDemoButton'
     UTCompMenuButtons(7)=GUIButton'utcompvSrc.UTComp_Menu_MainMenu.MiscButton'
     Begin Object Class=GUITabControl Name=LoginMenuTC
         bFillSpace=True
         bDockPanels=True
         WinTop=0.072718
         WinLeft=0.134782
         WinWidth=0.725325
         WinHeight=0.208177
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=LoginMenuTC.InternalOnActivate
     End Object
     c_Main=GUITabControl'utcompvSrc.UTComp_Menu_MainMenu.LoginMenuTC'

     Begin Object Class=FloatingImage Name=FloatingFrameBackground2
         Image=Texture'2K4Menus.NewControls.Display95'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.270000
         WinLeft=0.075000
         WinWidth=0.850000
         WinHeight=0.580000
         RenderWeight=0.020000
         bBoundToParent=False
         bScaleToParent=False
     End Object
     i_FrameBG2=FloatingImage'utcompvSrc.UTComp_Menu_MainMenu.FloatingFrameBackground2'

     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=0
         DropShadowY=0
         WinTop=0.100000
         WinLeft=0.075000
         WinWidth=0.850000
         WinHeight=0.750000
         RenderWeight=0.010000
         bBoundToParent=False
         bScaleToParent=False
     End Object
     i_FrameBG=FloatingImage'utcompvSrc.UTComp_Menu_MainMenu.FloatingFrameBackground'

     bRequire640x480=True
     bPersistent=True
     bAllowedAsLast=True
     WinTop=0.114990
     WinHeight=0.804690
}
