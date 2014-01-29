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

class UTComp_Menu_Miscellaneous extends UTComp_Menu_MainMenu;

var automated GUILabel l_ScoreboardTitle;
var automated GUILabel l_InfoTitle;
var automated GUILabel l_GenericTitle;
var automated GUILabel l_CrossScale;
var automated GUILabel l_NewNet;
var automated GUILabel l_CTF;


var automated moCheckBox ch_UseScoreBoard;
var automated moCheckBox ch_TransSwitch;
var automated moCheckBox ch_WepStats;
var automated moCheckBox ch_PickupStats;
var automated moCheckBox ch_InfoBox;
var automated moCheckBox ch_FootSteps;
var automated moCheckBox ch_MatchHudColor;
var automated moCheckBox ch_UseNewNet;

var automated moComboBox co_CrosshairScale;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController,MyOwner);

    ch_TransSwitch.Checked(class'Translauncher'.default.bPrevWeaponSwitch);
    ch_InfoBox.Checked(class'UTComp_Overlay'.default.DesiredOnJoinMessageTime!=0.0);
    ch_UseScoreboard.Checked(!class'BS_xPlayer'.default.bUseDefaultScoreboard);
    ch_WepStats.Checked(class'UTComp_Scoreboard'.default.bDrawStats);
    ch_PickupStats.Checked(class'UTComp_Scoreboard'.default.bDrawPickups);
    ch_FootSteps.Checked(class'UTComp_xPawn'.default.bPlayOwnFootSteps);
    ch_MatchHudColor.Checked(class'UTComp_HudSettings'.default.bMatchHudColor);
    ch_UseNewNet.Checked(class'BS_xPlayer'.default.bEnableEnhancedNetCode);
}

function InternalOnChange( GUIComponent C )
{
    switch(C)
    {
        case ch_InfoBox:  if(ch_InfoBox.IsChecked())
                              class'UTComp_Overlay'.default.DesiredOnJoinMessageTime=6.0;
                          else
                              class'UTComp_Overlay'.default.DesiredOnJoinMessageTime=0;  break;
        case ch_UseScoreboard: class'BS_xPlayer'.default.bUseDefaultScoreboard=!ch_UseScoreBoard.IsChecked(); break;
        case ch_TransSwitch: class'Translauncher'.default.bPrevWeaponSwitch=ch_TransSwitch.IsChecked(); break;
        case ch_WepStats:  class'UTComp_Scoreboard'.default.bDrawStats=ch_WepStats.IsChecked();
                           BS_xPlayer(PlayerOwner()).SetBStats(class'UTComp_Scoreboard'.default.bDrawStats);break;
        case ch_PickupStats:  class'UTComp_Scoreboard'.default.bDrawPickups=ch_PickupStats.IsChecked(); break;
        case ch_FootSteps: class'UTComp_xPawn'.default.bPlayOwnFootSteps=ch_FootSteps.IsChecked(); break;
        case ch_MatchHudColor:  class'UTComp_HudSettings'.default.bMatchHudColor=ch_MatchHudColor.IsChecked(); break;
        case ch_UseNewNet:  class'BS_xPlayer'.default.bEnableEnhancedNetCode=ch_UseNewNet.IsChecked();
                            BS_xPlayer(PlayerOwner()).TurnOffNetCode(); break;
    }
    class'UTComp_Overlay'.static.StaticSaveConfig();
    class'BS_xPlayer'.static.StaticSaveConfig();
    class'UTComp_Scoreboard'.static.StaticSaveConfig();
    class'UTComp_xPawn'.static.StaticSaveConfig();
    class'UTComp_HudCDeathMatch'.Static.StaticSaveConfig();
    class'UTComp_HudSettings'.static.StaticSaveConfig();
    BS_xPlayer(PlayerOwner()).MakeSureSaveConfig();
    BS_xPlayer(PlayerOwner()).MatchHudColor();

}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x1B)
        return false;
    return true;
}

defaultproperties
{
     Begin Object Class=GUILabel Name=ScoreboardLabel
         Caption="----------Scoreboard----------"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.310309
         WinLeft=0.250000
     End Object
     l_ScoreboardTitle=GUILabel'utcompvSrc.UTComp_Menu_Miscellaneous.ScoreboardLabel'

     Begin Object Class=GUILabel Name=InfoLabel
         Caption="--------Information Box--------"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.487629
         WinLeft=0.250000
     End Object
     l_InfoTitle=GUILabel'utcompvSrc.UTComp_Menu_Miscellaneous.InfoLabel'

     Begin Object Class=GUILabel Name=GenericLabel
         Caption="----Generic UT2004 Settings----"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.579382
         WinLeft=0.250000
     End Object
     l_GenericTitle=GUILabel'utcompvSrc.UTComp_Menu_Miscellaneous.GenericLabel'

     Begin Object Class=GUILabel Name=NewNetLabel
         Caption="-----------Net Code-----------"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.697833
         WinLeft=0.250000
     End Object
     l_NewNet=GUILabel'utcompvSrc.UTComp_Menu_Miscellaneous.NewNetLabel'

     Begin Object Class=moCheckBox Name=ScoreboardCheck
         Caption="Use UTComp enhanced scoreboard."
         OnCreateComponent=ScoreboardCheck.InternalOnCreateComponent
         WinTop=0.360000
         WinLeft=0.250000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_UseScoreBoard=moCheckBox'utcompvSrc.UTComp_Menu_Miscellaneous.ScoreboardCheck'

     Begin Object Class=moCheckBox Name=TransCheck
         Caption="Enable trans. switch"
         OnCreateComponent=TransCheck.InternalOnCreateComponent
         WinTop=0.633196
         WinLeft=0.250000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_TransSwitch=moCheckBox'utcompvSrc.UTComp_Menu_Miscellaneous.TransCheck'

     Begin Object Class=moCheckBox Name=StatsCheck
         Caption="Show weapon stats on scoreboard."
         OnCreateComponent=StatsCheck.InternalOnCreateComponent
         WinTop=0.410000
         WinLeft=0.250000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_WepStats=moCheckBox'utcompvSrc.UTComp_Menu_Miscellaneous.StatsCheck'

     Begin Object Class=moCheckBox Name=PickupCheck
         Caption="Show pickup stats on scoreboard."
         OnCreateComponent=PickupCheck.InternalOnCreateComponent
         WinTop=0.460000
         WinLeft=0.250000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_PickupStats=moCheckBox'utcompvSrc.UTComp_Menu_Miscellaneous.PickupCheck'

     Begin Object Class=moCheckBox Name=InfoCheck
         Caption="Show UTComp info box on connect."
         OnCreateComponent=InfoCheck.InternalOnCreateComponent
         WinTop=0.543505
         WinLeft=0.250000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_InfoBox=moCheckBox'utcompvSrc.UTComp_Menu_Miscellaneous.InfoCheck'

     Begin Object Class=moCheckBox Name=HudColorCheck
         Caption="Match Hud Color To Skins"
         OnCreateComponent=HudColorCheck.InternalOnCreateComponent
         WinTop=0.675774
         WinLeft=0.250000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_MatchHudColor=moCheckBox'utcompvSrc.UTComp_Menu_Miscellaneous.HudColorCheck'

     Begin Object Class=moCheckBox Name=NewNetCheck
         Caption="Enable Enhanced Netcode"
         OnCreateComponent=NewNetCheck.InternalOnCreateComponent
         WinTop=0.751134
         WinLeft=0.250000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_UseNewNet=moCheckBox'utcompvSrc.UTComp_Menu_Miscellaneous.NewNetCheck'

}
