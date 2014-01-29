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

class UTComp_Menu_BrightSkins extends UTComp_Menu_MainMenu;

var automated moCheckBox ch_EnemySkins;

var automated GUIComboBox co_TeamSelect;
var automated GUIComboBox co_TypeSkinSelect;
var automated GUIComboBox co_ModelSelect;
var automated GUIComboBox co_EpicSkinSelect;
var automated GUIImage SpinnyDudeBounds;

var automated GUIEditBox eb_ClanSkin;

var automated GUISlider sl_RedSkin, sl_GreenSkin, sl_BlueSkin;
var automated moCheckBox ch_ForceThisModel, ch_DarkSkins, ch_EnemyModels;

var automated GUIButton bu_DeleteClanSkin, bu_AddClanSkin;

var automated GUILabel l_SkinHeader, lModelHeader;
var automated GUILabel l_RedSkin, l_BlueSkin, l_GreenSkin;

var bool InitializationComplete;
var bool bUpdatingCrap;

var UTComp_SpinnyWeap				SpinnyDude; // MUST be set to null when you leave the window
var (SpinnyDude)	vector	SpinnyDudeOffset;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
    local UTComp_ServerReplicationInfo RepInfo;


    Super.InitComponent(myController,MyOwner);

    ch_EnemySkins.Checked(class'UTComp_xPawn'.default.bEnemyBasedSkins);
    ch_EnemyModels.Checked(class'UTComp_xPawn'.default.bEnemyBasedModels);

    //Team Select Combobox
    if(ch_EnemySkins.IsChecked())
    {
        if(!ch_EnemyModels.IsChecked())
        {
            co_TeamSelect.AddItem("Teammates(Skins), Red(Models)");
            co_TeamSelect.AddItem("Enemies(Skins), Blue(Models)");
        }
        else
        {
            co_TeamSelect.AddItem("Teammates");
            co_TeamSelect.AddItem("Enemies");
        }
    }
    else
    {
        if(ch_EnemyModels.IsChecked())
        {
            co_TeamSelect.AddItem("Red(Skins), Teammates(Models)");
            co_TeamSelect.AddItem("Blue(Skins), Enemies(Models)");
        }
        else
        {
            co_TeamSelect.AddItem("Red Team");
            co_TeamSelect.AddItem("Blue Team");
        }
    }
    for(i=0; i<class'UTComp_xPawn'.default.ClanSkins.Length; i++)
        co_TeamSelect.AddItem(class'UTComp_xPawn'.default.ClanSkins[i].PlayerName);

    //Type Skin Select Combobox
    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    //Model Select Combobox
    AddComboBoxItems(co_ModelSelect);

    if(RepInfo == none || RepInfo.EnableBrightSkinsMode>=1)
    co_EpicSkinSelect.AddItem("DM Skin");
    co_EpicSkinSelect.AddItem("Red Skin");
    co_EpicSkinSelect.AddItem("Blue Skin");
    if(RepInfo == none || RepInfo.EnableBrightSkinsMode>1)
        co_EpicSkinSelect.AddItem("Purple Skin");
    else
        co_EpicSkinSelect.AddItem("Purple Skin (Server Disabled)");
    co_EpicSkinSelect.AddItem("Brighter DM Skin");
    co_EpicSkinSelect.AddItem("Brighter Red Skin");
    co_EpicSkinSelect.AddItem("Brighter Blue Skin");
    if(RepInfo == none || RepInfo.EnableBrightSkinsMode>1)
        co_EpicSkinSelect.AddItem("Brighter Purple Skin");
    else
        co_EpicSkinSelect.AddItem("Brighter Purple Skin (Server Disabled)");

    ch_DarkSkins.Checked(class'UTComp_xPawn'.default.bEnableDarkSkinning);

    UpdateAllComponents();

    co_EpicSkinSelect.ReadOnly(True);
    co_TypeSkinSelect.ReadOnly(True);
    co_TeamSelect.ReadOnly(True);

    InitializationComplete=True;

}

event Opened(guicomponent sender)
{
    local UTComp_ServerReplicationInfo RepInfo;
    local int Temp;
    super.Opened(Sender);

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    InitializationComplete=False;
    co_TeamSelect.SetIndex(0);
    Temp=class'UTComp_xPawn'.default.ClientSkinModeRedTeammate;

    co_TypeSkinSelect.Clear();
    co_TypeSkinSelect.AddItem("Epic Style");
    if(RepInfo==None || RepInfo.EnableBrightSkinsMode>1)
        co_TypeSkinSelect.AddItem("Brighter Epic Style");
    else
        co_TypeSkinSelect.AddItem("Brighter Epic Style(Server Disabled)");
    if(RepInfo==None || RepInfo.EnableBrightSkinsMode>2)
        co_TypeSkinSelect.AddItem("UTComp Style");
    else
        co_TypeSkinSelect.AddItem("UTComp Style(Server Disabled)");
    co_TypeSkinSelect.SetIndex(Temp-1);

   InitializeSpinnyDude();
   UpdateAllComponents();
   InitializationComplete=True;
}

function InitializeSpinnyDude()
{
    local vector X,Y,Z;
    local vector X2,Y2;
    local rotator R2;
    local vector  V;
    local rotator R;

    // Spawn spinning character actor
	if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'UTComp_SpinnyWeap');
    if(SpinnyDude!=None)
    {
        SpinnyDude.SetDrawType(DT_Mesh);
	    SpinnyDude.SetDrawScale(0.9);
	    SpinnyDude.SpinRate = 4000;
	    SpinnyDude.AmbientGlow=45;

    R=PlayerOwner().Rotation;

    GetAxes(R,X,Y,Z);
    R2.Yaw=32768;   //32768 = pi in uRotational
    V=vector(R2);
    X2=V.X*X + V.Y*Y;
    Y2=V.X*Y - V.Y*X;

    R2=OrthoRotation(X2,Y2,Z);

	SpinnyDude.SetRotation(R2);
	}
}


function InternalOnChange( GUIComponent C )
{
    local byte Team;

    Team=co_TeamSelect.GetIndex();

    if(!InitializationComplete)
        return;
    Switch(C)
    {
        case ch_EnemySkins:  class'UTComp_xPawn'.default.bEnemyBasedSkins=ch_EnemySkins.IsChecked();
                             ChangeComboBoxCaption();
                             if(!bUpdatingCrap)
                                 UpdateAllComponents(); break;

        case ch_EnemyModels: class'UTComp_xPawn'.default.bEnemyBasedModels=ch_EnemyModels.IsChecked();
                             ChangeComboBoxCaption();
                             if(!bUpdatingCrap)
                                 UpdateAllComponents(); break;
        case co_TeamSelect:  if(!bUpdatingCrap)
                                  UpdateAllComponents();
                             break;
        case sl_RedSkin:  if(Team==0)
                              class'UTComp_xPawn'.default.RedTeammateUTCompSkinColor.R=sl_RedSkin.Value;
                          else if(Team==1)
                              class'UTComp_xPawn'.default.BlueEnemyUTCompSkinColor.R=sl_RedSkin.Value;
                          else if(Team>=2 && class'UTComp_xPawn'.default.ClanSkins.Length>Team-2)
                              class'UTComp_xPawn'.default.ClanSkins[Team-2].PlayerColor.R=sl_RedSkin.Value;
                              if(!bUpdatingCrap)
                                  UpdateSpinnyDude(); break;

        case sl_GreenSkin:  if(Team==0)
                              class'UTComp_xPawn'.default.RedTeammateUTCompSkinColor.G=sl_GreenSkin.Value;
                          else if(Team==1)
                              class'UTComp_xPawn'.default.BlueEnemyUTCompSkinColor.G=sl_GreenSkin.Value;
                          else if(Team>=2 && class'UTComp_xPawn'.default.ClanSkins.Length>Team-2)
                              class'UTComp_xPawn'.default.ClanSkins[Team-2].PlayerColor.G=sl_GreenSkin.Value;
                              if(!bUpdatingCrap)
                                  UpdateSpinnyDude(); break;

        case sl_BlueSkin: if(Team==0)
                              class'UTComp_xPawn'.default.RedTeammateUTCompSkinColor.B=sl_BlueSkin.Value;
                          else if(Team==1)
                              class'UTComp_xPawn'.default.BlueEnemyUTCompSkinColor.B=sl_BlueSkin.Value;
                          else if(Team>=2 && class'UTComp_xPawn'.default.ClanSkins.Length>Team-2)
                              class'UTComp_xPawn'.default.ClanSkins[Team-2].PlayerColor.B=sl_BlueSkin.Value;
                              if(!bUpdatingCrap)
                                  UpdateSpinnyDude(); break;

       case co_EpicSkinSelect:  if(Team==0 && co_EpicSkinSelect.GetIndex()>=0)
                                    class'UTComp_xPawn'.default.PreferredSkinColorRedTeammate=co_EpicSkinSelect.GetIndex();
                                else if(Team==1 && co_EpicSkinSelect.GetIndex()>=0)
                                    class'UTComp_xPawn'.default.PreferredSkinColorBlueEnemy=co_EpicSkinSelect.GetIndex();
                                if(!bUpdatingCrap)
                                    UpdateAllComponents();
                                if(!bUpdatingCrap)
                                    UpdateSpinnyDude(); break;
       case co_TypeSkinSelect:  if(Team==0)
                                    class'UTComp_xPawn'.default.ClientSkinModeRedTeammate=co_TypeSkinSelect.GetIndex()+1;
                                else if(Team==1)
                                    class'UTComp_xPawn'.default.ClientSkinModeBlueEnemy=co_TypeSkinSelect.GetIndex()+1;
                                if(!bUpdatingCrap)
                                    UpdateAllComponents();
                                break;
       case ch_ForceThisModel:
                                if(Team==0)
                                    class'UTComp_xPawn'.default.bRedTeammateModelsForced=ch_ForceThisModel.IsChecked();
                                else if(Team==1)
                                    class'UTComp_xPawn'.default.bBlueEnemyModelsForced=ch_ForceThisModel.IsChecked();
                                if(Ch_ForceThisModel.IsChecked())
                                    co_ModelSelect.EnableMe();
                                else
                                    co_ModelSelect.DisableMe();
                                break;
       case ch_DarkSkins:  class'UTComp_xPawn'.default.bEnableDarkSkinning=ch_DarkSkins.IsChecked(); break;

       case co_ModelSelect:
       if(bUpdatingCrap)
            break;
        if(co_TeamSelect.GetIndex()>=2 && class'UTComp_xPawn'.default.ClanSkins.Length>co_TeamSelect.GetIndex()-2)
        {
            class'UTComp_xPawn'.default.ClanSkins[co_TeamSelect.GetIndex()-2].PlayerName=eb_ClanSkin.GetText();
            class'UTComp_xPawn'.default.ClanSkins[co_TeamSelect.GetIndex()-2].ModelName = co_ModelSelect.GetText();
        }
    else if(co_TeamSelect.GetIndex()==0)
        class'UTComp_xPawn'.default.RedTeammateModelName=co_ModelSelect.GetText();
    else if(co_TeamSelect.GetIndex()==1)
        class'UTComp_xPawn'.default.BlueEnemyModelName=co_ModelSelect.GetText();
        if(!bUpdatingCrap)
           UpdateSpinnyDude(); break;
    }

    BS_xPlayer(PlayerOwner()).ReSkinAll();
    BS_xPlayer(PlayerOwner()).MatchHudColor();
    BS_xPlayer(PlayerOwner()).MakeSureSaveConfig();
    class'UTComp_xPawn'.static.StaticSaveConfig();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x1B)
        return false;

    if( Key==8 && eb_ClanSkin.bHasFocus) // Process Backspace
	{
		if ( eb_ClanSkin.CaretPos>0)
		{
			if ( eb_ClanSkin.bAllSelected )
			{
				eb_ClanSkin.TextStr = "";
				eb_ClanSkin.CaretPos = 0;
				eb_ClanSkin.bAllSelected = False;
				eb_ClanSkin.TextChanged();
			}
			else
			{
				eb_ClanSkin.CaretPos--;
				eb_ClanSkin.DeleteChar();
			}
		}
	}

    if(co_TeamSelect.GetIndex()>=2 && class'UTComp_xPawn'.default.ClanSkins.Length>co_TeamSelect.GetIndex()-2)
    {
        class'UTComp_xPawn'.default.ClanSkins[co_TeamSelect.GetIndex()-2].PlayerName = eb_ClanSkin.GetText();
        class'UTComp_xPawn'.default.ClanSkins[co_TeamSelect.GetIndex()-2].ModelName = co_ModelSelect.GetText();
    }
    else if(co_TeamSelect.GetIndex()==0)
        class'UTComp_xPawn'.default.RedTeammateModelName=co_ModelSelect.GetText();
    else if(co_TeamSelect.GetIndex()==1)
        class'UTComp_xPawn'.default.BlueEnemyModelName=co_ModelSelect.GetText();
    ChangeComboBoxCaption();
    class'UTComp_xPawn'.static.StaticSaveConfig();
    UpdateSpinnyDude();

    return true;
}


function bool InternalOnClick( GUIComponent Sender )
{
    local int n, i;

    switch (Sender)
    {
        case bu_AddClanSkin:   InitializationComplete=False;
                               n=Class'UTComp_xPawn'.default.ClanSkins.Length;
                               Class'UTComp_xPawn'.default.ClanSkins.Length=n+1;
                               Class'UTComp_xPawn'.default.ClanSkins[n].PlayerColor.G=128;
                               Class'UTComp_xPawn'.default.ClanSkins[n].ModelName="Arclite";
                               Class'UTComp_xPawn'.default.ClanSkins[n].PlayerName="Player"$n;
                               co_TeamSelect.ReadOnly(False);
                               co_TeamSelect.Clear();
                               if(ch_EnemySkins.IsChecked())
                                {
                                     co_TeamSelect.AddItem("Teammates");
                                     co_TeamSelect.AddItem("Enemies");
                                }
                                else
                                {
                                    co_TeamSelect.AddItem("Red Team");
                                    co_TeamSelect.AddItem("Blue Team");
                                }
                                for(i=0; i<class'UTComp_xPawn'.default.ClanSkins.Length; i++)
                                    co_TeamSelect.AddItem(class'UTComp_xPawn'.default.ClanSkins[i].PlayerName);
                               co_TeamSelect.ReadOnly(True);

                               co_TeamSelect.SetIndex(n+2);
                               InitializationComplete=True;
                               break;


         case bu_DeleteClanSkin:

                               InitializationComplete=False;
                               n=co_TeamSelect.GetIndex();
                               Class'UTComp_xPawn'.default.ClanSkins.Remove(n-2,1);
                               co_TeamSelect.ReadOnly(False);
                               co_TeamSelect.Clear();
                               if(ch_EnemySkins.IsChecked())
                                {
                                     co_TeamSelect.AddItem("Teammates");
                                     co_TeamSelect.AddItem("Enemies");
                                }
                                else
                                {
                                    co_TeamSelect.AddItem("Red Team");
                                    co_TeamSelect.AddItem("Blue Team");
                                }
                                for(i=0; i<class'UTComp_xPawn'.default.ClanSkins.Length; i++)
                                    co_TeamSelect.AddItem(class'UTComp_xPawn'.default.ClanSkins[i].PlayerName);
                               co_TeamSelect.ReadOnly(True);
                               co_TeamSelect.SetIndex(0);
                               InitializationComplete=True; break;
    }

    UpdateAllComponents();
    return super.InternalOnClick(Sender);
}


function ChangeComboBoxCaption()
{
    local byte Team;
    local int i;
    InitializationComplete=False;

    Team=co_TeamSelect.GetIndex();

    co_TeamSelect.Clear();
    //Team Select Combobox
    if(ch_EnemySkins.IsChecked())
    {
        if(!ch_EnemyModels.IsChecked())
        {
            co_TeamSelect.AddItem("Teammates(Skins), Red(Models)");
            co_TeamSelect.AddItem("Enemies(Skins), Blue(Models)");
        }
        else
        {
            co_TeamSelect.AddItem("Teammates");
            co_TeamSelect.AddItem("Enemies");
        }
    }
    else
    {
        if(ch_EnemyModels.IsChecked())
        {
            co_TeamSelect.AddItem("Red(Skins), Teammates(Models)");
            co_TeamSelect.AddItem("Blue(Skins), Enemies(Models)");
        }
        else
        {
            co_TeamSelect.AddItem("Red Team");
            co_TeamSelect.AddItem("Blue Team");
        }
    }
    for(i=0; i<class'UTComp_xPawn'.default.ClanSkins.Length; i++)
    {
        if(class'UTComp_xPawn'.default.ClanSkins[i].PlayerName=="")
            co_TeamSelect.AddItem("_");
        else
            co_TeamSelect.AddItem(class'UTComp_xPawn'.default.ClanSkins[i].PlayerName);
    }
    co_TeamSelect.SetIndex(Team);
    InitializationComplete=True;
}

function ResetComboBox()
{

}

function UpdateAllComponents()
{
    local byte Team;
    local byte SkinStyle;
    local UTComp_ServerReplicationInfo RepInfo;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    Team=co_TeamSelect.GetIndex();
    bUpdatingCrap=True;
    if(Team<2)
       bu_DeleteClanSkin.DisableMe();
    else
       bu_DeleteClanSkin.EnableMe();

    if(Team==0)
    {
        co_TypeSkinSelect.EnableMe();
        co_ModelSelect.EnableMe();
        eb_ClanSkin.DisableMe();

        co_TypeSkinSelect.SetIndex(class'UTComp_xPawn'.default.ClientSkinModeRedTeammate-1);

        SkinStyle=co_TypeSkinSelect.GetIndex();

        if(SkinStyle<2)
        {
            co_EpicSkinSelect.SetIndex(class'UTComp_xPawn'.default.PreferredSkinColorRedTeammate);
            co_EpicSkinSelect.EnableMe();
            sl_RedSkin.DisableMe();
            sl_GreenSkin.DisableMe();
            sl_BlueSkin.DisableMe();

        }
        else
        {
            co_EpicSkinSelect.DisableMe();
            sl_RedSkin.EnableMe();
            sl_GreenSkin.EnableMe();
            sl_BlueSkin.EnableMe();
            co_EpicSkinSelect.SetIndex(-1);

            sl_RedSkin.SetValue(class'UTComp_xPawn'.default.RedTeammateUTCompSkinColor.R);
            sl_GreenSkin.SetValue(class'UTComp_xPawn'.default.RedTeammateUTCompSkinColor.G);
            sl_BlueSkin.SetValue(class'UTComp_xPawn'.default.RedTeammateUTCompSkinColor.B);
        }
        co_ModelSelect.SetIndex(co_ModelSelect.FindIndex(class'UTComp_xPawn'.default.RedTeammateModelName));
        ch_ForceThisModel.EnableMe();
        if(ch_EnemyModels.IsChecked())
            ch_ForceThismodel.mylabel.Caption="Force Teammate Models";
        else
            ch_ForceThismodel.mylabel.Caption="Force Red Models";
        ch_ForceThisModel.Checked(class'UTComp_xPawn'.default.bRedTeammateModelsForced);
    }
    else if(Team==1)
    {
        co_TypeSkinSelect.EnableMe();
        co_ModelSelect.EnableMe();
        eb_ClanSkin.DisableMe();

        co_TypeSkinSelect.SetIndex(class'UTComp_xPawn'.default.ClientSkinModeBlueEnemy-1);

        SkinStyle=co_TypeSkinSelect.GetIndex();

        if(SkinStyle<2)
        {
            co_EpicSkinSelect.SetIndex(class'UTComp_xPawn'.default.PreferredSkinColorBlueEnemy);
            co_EpicSkinSelect.EnableMe();
            sl_RedSkin.DisableMe();
            sl_GreenSkin.DisableMe();
            sl_BlueSkin.DisableMe();

        }
        else
        {
            co_EpicSkinSelect.DisableMe();
            sl_RedSkin.EnableMe();
            sl_GreenSkin.EnableMe();
            sl_BlueSkin.EnableMe();

            sl_RedSkin.SetValue(class'UTComp_xPawn'.default.BlueEnemyUTCompSkinColor.R);
            sl_GreenSkin.SetValue(class'UTComp_xPawn'.default.BlueEnemyUTCompSkinColor.G);
            sl_BlueSkin.SetValue(class'UTComp_xPawn'.default.BlueEnemyUTCompSkinColor.B);
        }
        co_ModelSelect.SetIndex(co_ModelSelect.FindIndex(class'UTComp_xPawn'.default.BlueEnemyModelName));
        ch_ForceThisModel.EnableMe();
        if(ch_EnemyModels.IsChecked())
            ch_ForceThismodel.mylabel.Caption="Force Enemy Models";
        else
            ch_ForceThismodel.mylabel.Caption="Force Blue Models";
        ch_ForceThisModel.Checked(class'UTComp_xPawn'.default.bBlueEnemyModelsForced);
    }
    else if(Team>=2)
    {
        co_ModelSelect.EnableMe();
        co_TypeSkinSelect.SetIndex(2);
        co_TypeSkinSelect.DisableMe();
        co_EpicSkinSelect.DisableMe();
        co_EpicSkinSelect.SetIndex(-1);

        eb_ClanSkin.EnableMe();
        if(class'UTComp_xPawn'.default.ClanSkins.Length > Team-2)
           eb_ClanSkin.SetText(class'UTComp_xPawn'.default.ClanSkins[Team-2].PlayerName);

        sl_RedSkin.EnableMe();
        sl_GreenSkin.EnableMe();
        sl_BlueSkin.EnableMe();

        if(class'UTComp_xPawn'.default.ClanSkins.Length > Team-2)
        {
            sl_RedSkin.SetValue(class'UTComp_xPawn'.default.ClanSkins[Team-2].PlayerColor.R);
            sl_GreenSkin.SetValue(class'UTComp_xPawn'.default.ClanSkins[Team-2].PlayerColor.G);
            sl_BlueSkin.SetValue(class'UTComp_xPawn'.default.ClanSkins[Team-2].PlayerColor.B);

            co_ModelSelect.SetIndex(co_ModelSelect.FindIndex(class'UTComp_xPawn'.default.ClanSkins[Team-2].ModelName));
        }
        ch_ForceThismodel.mylabel.Caption="Force This Model";
        ch_ForceThisModel.DisableMe();
    }
    else
    {
        sl_RedSkin.DisableMe();
        sl_GreenSkin.DisableMe();
        sl_BlueSkin.DisableMe();
        co_EpicSkinSelect.DisableMe();
        ch_ForceThisModel.DisableMe();
        co_ModelSelect.DisableMe();
        eb_ClanSkin.DisableMe();
        co_TypeSkinSelect.DisableMe();
    }

    if(ch_ForceThisModel.IsChecked())
        co_ModelSelect.EnableMe();
    else
        co_ModelSelect.DisableMe();
	UpdateSpinnyDude();
	bUpdatingCrap=False;
}



function AddComboBoxItems(GUIComboBox Combo)
{
    Combo.AddItem("Abaddon");
    Combo.AddItem("Ambrosia");
    Combo.AddItem("Annika");
    Combo.AddItem("Arclite");
    Combo.AddItem("Aryss");
    Combo.AddItem("Asp");
    Combo.AddItem("Axon");
    Combo.AddItem("Azure");
    Combo.AddItem("Baird");
    Combo.AddItem("Barktooth");
    Combo.AddItem("BlackJack");
    Combo.AddItem("Brock");
    Combo.AddItem("Brutalis");
    Combo.AddItem("Cannonball");
    Combo.AddItem("Cathode");
    Combo.AddItem("ClanLord");
    Combo.AddItem("Cleopatra");
    Combo.AddItem("Cobalt");
    Combo.AddItem("Corrosion");
    Combo.AddItem("Cyclops");
    Combo.AddItem("Damarus");
    Combo.AddItem("Diva");
    Combo.AddItem("Divisor");
    Combo.AddItem("Domina");
    Combo.AddItem("Dominator");
    Combo.AddItem("Drekorig");
    Combo.AddItem("Enigma");
    Combo.AddItem("Faraleth");
    Combo.AddItem("Fate");
    Combo.AddItem("Frostbite");
    Combo.AddItem("Gaargod");
    Combo.AddItem("Garrett");
    Combo.AddItem("Gkublok");
    Combo.AddItem("Gorge");
    Combo.AddItem("Greith");
    Combo.AddItem("Guardian");
    Combo.AddItem("Harlequin");
    Combo.AddItem("Horus");
    Combo.AddItem("Hyena");
    Combo.AddItem("Jakob");
    Combo.AddItem("Kaela");
    Combo.AddItem("Karag");
    Combo.AddItem("Kane");
    Combo.AddItem("Komek");
    Combo.AddItem("Kraagesh");
    Combo.AddItem("Kragoth");
    Combo.AddItem("Lauren");
    Combo.AddItem("Lilith");
    Combo.AddItem("Makreth");
    Combo.AddItem("Malcolm");
    Combo.AddItem("Mandible");
    Combo.AddItem("Matrix");
    Combo.AddItem("Memphis");
    Combo.AddItem("Mekkor");
    Combo.AddItem("Mokara");
    Combo.AddItem("Motig");
    Combo.AddItem("Mr.Crow");
    Combo.AddItem("Nebri");
    Combo.AddItem("Ophelia");
    Combo.AddItem("Othello");
    Combo.AddItem("Outlaw");
    Combo.AddItem("Prism");
    Combo.AddItem("Rae");
    Combo.AddItem("Rapier");
    Combo.AddItem("Ravage");
    Combo.AddItem("Reinha");
    Combo.AddItem("Remus");
    Combo.AddItem("Renegade");
    Combo.AddItem("Riker");
    Combo.AddItem("Roc");
    Combo.AddItem("Romulus");
    Combo.AddItem("Rylisa");
    Combo.AddItem("Sapphire");
    Combo.AddItem("Satin");
    Combo.AddItem("Scarab");
    Combo.AddItem("Selig");
    Combo.AddItem("Siren");
    Combo.AddItem("Skakruk");
    Combo.AddItem("Skrilax");
    Combo.AddItem("Subversa");
    Combo.AddItem("Syzygy");
    Combo.AddItem("Tamika");
    Combo.AddItem("Torch");
    Combo.AddItem("Thannis");
    Combo.AddItem("Thorax");
    Combo.AddItem("Virus");
    Combo.AddItem("Widowmaker");
    Combo.AddItem("Wraith");
    Combo.AddItem("Xan");
    Combo.AddItem("Zarina");
}

// begin spinny dude extra crap

function Free()
{
	Super.Free();

	if ( SpinnyDude != None )
		SpinnyDude.Destroy();
	SpinnyDude = None;
}

function bool InternalOnDraw(canvas Canvas)
{
	local vector CamPos, X, Y, Z;
	local rotator CamRot;
	local float   oOrgX, oOrgY;
	local float   oClipX, oClipY;

   	oOrgX = Canvas.OrgX;
	oOrgY = Canvas.OrgY;
	oClipX = Canvas.ClipX;
	oClipY = Canvas.ClipY;

	Canvas.OrgX =SpinnyDudeBounds.ActualLeft();
	Canvas.OrgY =SpinnyDudeBounds.ActualTop();
	Canvas.ClipX =SpinnyDudeBounds.ActualWidth();
	Canvas.ClipY =SpinnyDudeBounds.ActualHeight();

	canvas.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);

	SpinnyDude.SetLocation(CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));
	canvas.DrawActorClipped(SpinnyDude, false,  SpinnyDudeBounds.ActualLeft(), SpinnyDudeBounds.ActualTop(), SpinnyDudeBounds.ActualWidth(), SpinnyDudeBounds.ActualHeight(), true, 15);
	Canvas.OrgX = oOrgX;
	Canvas.OrgY = oOrgY;
	Canvas.ClipX = oClipX;
	Canvas.ClipY = oClipY;

	return true;

}

function UpdateSpinnyDude()
{
	local xUtil.PlayerRecord Rec;
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;
	local string BodySkinName, HeadSkinName, TeamSuffix;


    // Choose the model

    if(ch_ForceThisModel.IsChecked())
    {
        Rec = class'xutil'.static.FindPlayerRecord(class'UTComp_xPawn'.static.IsAcceptable(co_ModelSelect.GetText()));
    }
    else
    {
        if(PlayerOwner().PlayerReplicationInfo!=None)
            Rec = class'xutil'.static.FindPlayerRecord(PlayerOwner().PlayerReplicationInfo.CharacterName);
        else
            Rec =  class'xutil'.static.FindPlayerRecord("Gorge");
    }

	if (Rec.Race ~= "Juggernaut" || Rec.DefaultName~="Axon" || Rec.DefaultName~="Cyclops" || Rec.DefaultName ~="Virus" )
		SpinnyDudeOffset=vect(250.0,1.00,-14.00);
	else
	    SpinnyDudeOffset=vect(250.0,1.00,-24.00);

	PlayerMesh = Mesh(DynamicLoadObject(Rec.MeshName, class'Mesh'));
	if(PlayerMesh == None)
	{
		Log("Could not load mesh: "$Rec.MeshName$" For player: "$Rec.DefaultName);
		return;
	}

	// Get the body skin
	BodySkinName = Rec.BodySkinName;

	// Get the head skin
	HeadSkinName = Rec.FaceSkinName;
	if ( Rec.TeamFace )
		HeadSkinName $= TeamSuffix;

	BodySkin = ChangeColorOfSkin(Material(DynamicLoadObject(BodySkinName, class'Material')), 0);
	if(BodySkin == None)
	{
		Log("Could not load body material: "$Rec.BodySkinName$" For player: "$Rec.DefaultName);
		return;
	}

	HeadSkin = ChangeColorOfSkin(Material(DynamicLoadObject(HeadSkinName, class'Material')), 1);
	if(HeadSkin == None)
	{
		Log("Could not load head material: "$HeadSkinName$" For player: "$Rec.DefaultName);
		return;
	}
/*	if(ch_ForceThisModel.IsChecked())
    {
        if(SpinnyDude.Mesh==PlayerMesh)
           ;
        else
        {
           Log("Destroying spinny dude, making new one");
           SpinnyDude.Destroy();
           InitializeSpinnyDude();
        }
    }   */

	if(SpinnyDude!=None)
	{
	    SpinnyDude.LinkMesh(PlayerMesh);
     	SpinnyDude.Skins[0] = BodySkin;
        SpinnyDude.Skins[1] = HeadSkin;
	    SpinnyDude.LoopAnim( 'Idle_Rest', 1.0/SpinnyDude.Level.TimeDilation );
	}
}



simulated function material ChangeColorOfSkin(material SkinToChange, byte SkinNum)
{
    local byte SkinMode;

    SkinMode=co_TypeSkinSelect.GetIndex();
    switch(SkinMode)
    {
        case 0: SpinnyDude.bUnlit=False;
                return ChangeOnlyColor(SkinToChange);
        case 1: SpinnyDude.bUnlit=True;
                return ChangeColorAndBrightness(SkinToChange, SkinNum);
        case 2: SpinnyDude.bUnlit=True;
                return ChangeToUTCompSkin(SkinToChange, SkinNum);
    }
    return SkinToChange;
}

simulated function material ChangeOnlyColor(material SkinToChange)
{
    local byte ColorMode;
    local byte OtherColorMode;

    if(co_TeamSelect.GetIndex()==1)
    {
        ColorMode=class'UTComp_xPawn'.default.PreferredSkinColorBlueEnemy;
        OtherColorMode=class'UTComp_xPawn'.default.PreferredSkinColorRedTeammate;
    }
    else if(co_TeamSelect.GetIndex()==0)
    {
        ColorMode=class'UTComp_xPawn'.default.PreferredSkinColorRedTeammate;
        OtherColorMode=class'UTComp_xPawn'.default.PreferredSkinColorBlueEnemy;
    }
    else
        return SkinToChange;

    if(ColorMode > 3)
        ColorMode-=4;
    if(OtherColorMode > 3)
        OtherColorMode-=4;

    switch ColorMode
    {
        case 0:  return class'UTComp_xPawn'.static.MakeDMSkin(SkinToChange);
        case 1:  return class'UTComp_xPawn'.static.MakeRedSkin(SkinToChange);
        case 2:  return class'UTComp_xPawn'.static.MakeBlueSkin(SkinToChange);
        case 3:  if(OtherColorMode<2)
                     return class'UTComp_xPawn'.static.MakeBlueSkin(SkinToChange);
                 else
                     return class'UTComp_xPawn'.static.MakeRedSkin(SkinToChange);
    }
    return SkinToChange;
}

simulated function material ChangeColorAndBrightness(material SkinToChange, int SkinNum)
{
    local byte ColorMode;

    if(co_TeamSelect.GetIndex()==1)
        ColorMode=class'UTComp_xPawn'.default.PreferredSkinColorBlueEnemy;
    else if(co_TeamSelect.GetIndex()==0)
        ColorMode=class'UTComp_xPawn'.default.PreferredSkinColorRedTeammate;
    switch ColorMode
    {
        case 0:  return class'UTComp_xPawn'.static.MakeDMSkin(SkinToChange);  break;
        case 1:  return class'UTComp_xPawn'.static.MakeRedSkin(SkinToChange); break;
        case 2:  return class'UTComp_xPawn'.static.MakeBlueSkin(SkinToChange);  break;
        case 3:  return MakePurpleSkin(SkinToChange);  break;
        case 4:  if(SkinNum==1)
                     return class'UTComp_xPawn'.static.MakeDMSkin(SkinToChange);
                 return class'UTComp_xPawn'.static.MakeBrightDMSkin(SkinToChange);  break;
        case 5:  if(SkinNum==1)
                     return class'UTComp_xPawn'.static.MakeRedSkin(SkinToChange);
                 return class'UTComp_xPawn'.static.MakeBrightRedSkin(SkinToChange);  break;
        case 6:  if(SkinNum==1)
                     return class'UTComp_xPawn'.static.MakeBlueSkin(SkinToChange);
                 return class'UTComp_xPawn'.static.MakeBrightBlueSkin(SkinToChange);  break;
        case 7:  if(SkinNum==1)
                     return SkinToChange;
                 return MakeBrightPurpleSkin(SkinToChange); break;
    }
}

simulated function material ChangeToUTCompSkin(material SkinToChange, byte SkinNum)
{
    local Combiner C;
    local ConstantColor CC;

    if(SkinNum>0)
        return class'UTComp_xPawn'.static.MakeDMSkin(SkinToChange);

    C=New(None)Class'Combiner';
    CC=New(None)Class'ConstantColor';

    C.CombineOperation=CO_Add;
    C.Material1=class'UTComp_xPawn'.static.MakeDMSkin(SkinToChange);
    CC.Color.R=sl_RedSkin.Value;
    CC.Color.G=sl_GreenSkin.Value;
    CC.Color.B=sl_BlueSkin.Value;
    C.Material2=CC;

    if(C!=None)
        return C;
}

simulated function material MakePurpleSkin(material SkinToChange)
{
   local combiner C;
   local combiner C2;

   C=New(None)class'Combiner';
   C2=New(None)class'Combiner';
   C.CombineOperation=CO_Subtract;
   C.Material1=class'UTComp_xPawn'.static.MakeRedSkin(SkinToChange);
   C.Material2=class'UTComp_xPawn'.static.MakeBlueSkin(SkinToChange);
   C2.CombineOperation=CO_Add;
   C2.Material1=C;
   C2.Material2=C.Material1;

   if(C.Material1.IsA('Texture'))
       return C2;
   else
       return ChangeOnlyColor(SkinToChange);
}

simulated function material MakeBrightPurpleSkin(material SkinToChange)
{
    local Combiner C;

    C=New(None)class'Combiner';
    C.CombineOperation=CO_Add;
    C.Material1=class'UTComp_xPawn'.static.MakeRedSkin(SkinToChange);
    C.Material2=class'UTComp_xPawn'.static.MakeBlueSkin(SkinToChange);
    if(C.Material1.IsA('Texture'))
        return C;
    else
        return ChangeOnlyColor(SkinToChange);
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=EnemyBasedSkinCheck
         Caption="Enemy Based Skins"
         OnCreateComponent=EnemyBasedSkinCheck.InternalOnCreateComponent
         WinTop=0.330583
         WinLeft=0.096875
         WinWidth=0.257812
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
     End Object
     ch_EnemySkins=moCheckBox'utcompvSrc.UTComp_Menu_BrightSkins.EnemyBasedSkinCheck'

     Begin Object Class=GUIComboBox Name=TeamSelectCombo
         WinTop=0.375000
         WinLeft=0.096249
         WinWidth=0.421875
         WinHeight=0.035000
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
         OnKeyEvent=TeamSelectCombo.InternalOnKeyEvent
     End Object
     co_TeamSelect=GUIComboBox'utcompvSrc.UTComp_Menu_BrightSkins.TeamSelectCombo'

     Begin Object Class=GUIComboBox Name=TypeSkinSelectCombo
         WinTop=0.491263
         WinLeft=0.096249
         WinWidth=0.423438
         WinHeight=0.035000
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
         OnKeyEvent=TypeSkinSelectCombo.InternalOnKeyEvent
     End Object
     co_TypeSkinSelect=GUIComboBox'utcompvSrc.UTComp_Menu_BrightSkins.TypeSkinSelectCombo'

     Begin Object Class=GUIComboBox Name=ModelSelectCombo
         WinTop=0.737925
         WinLeft=0.100625
         WinWidth=0.417188
         WinHeight=0.035000
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
         OnKeyEvent=UTComp_Menu_BrightSkins.InternalOnKeyEvent
     End Object
     co_ModelSelect=GUIComboBox'utcompvSrc.UTComp_Menu_BrightSkins.ModelSelectCombo'

     Begin Object Class=GUIComboBox Name=EpicSkinSelectCombo
         WinTop=0.537526
         WinLeft=0.097812
         WinWidth=0.420313
         WinHeight=0.035000
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
         OnKeyEvent=EpicSkinSelectCombo.InternalOnKeyEvent
     End Object
     co_EpicSkinSelect=GUIComboBox'utcompvSrc.UTComp_Menu_BrightSkins.EpicSkinSelectCombo'

     Begin Object Class=GUIImage Name=spinnydudeboundsimage
         Image=Texture'2K4Menus.Controls.buttonSquare_b'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         DropShadowX=4
         DropShadowY=4
         WinTop=0.095717
         WinLeft=0.620830
         WinWidth=0.220507
         WinHeight=0.746876
         RenderWeight=0.520000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=UTComp_Menu_BrightSkins.InternalOnDraw
     End Object
     SpinnyDudeBounds=GUIImage'utcompvSrc.UTComp_Menu_BrightSkins.spinnydudeboundsimage'

     Begin Object Class=GUIEditBox Name=ClanSkinEditBox
         WinTop=0.429162
         WinLeft=0.329062
         WinWidth=0.187500
         WinHeight=0.035000
         OnActivate=ClanSkinEditBox.InternalActivate
         OnDeActivate=ClanSkinEditBox.InternalDeactivate
         OnKeyType=ClanSkinEditBox.InternalOnKeyType
         OnKeyEvent=UTComp_Menu_BrightSkins.InternalOnKeyEvent
     End Object
     eb_ClanSkin=GUIEditBox'utcompvSrc.UTComp_Menu_BrightSkins.ClanSkinEditBox'

     Begin Object Class=GUISlider Name=RedSkinSlider
         MaxValue=128.000000
         bIntSlider=True
         WinTop=0.585000
         WinLeft=0.180000
         WinWidth=0.335000
         OnClick=RedSkinSlider.InternalOnClick
         OnMousePressed=RedSkinSlider.InternalOnMousePressed
         OnMouseRelease=RedSkinSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
         OnKeyEvent=RedSkinSlider.InternalOnKeyEvent
         OnCapturedMouseMove=RedSkinSlider.InternalCapturedMouseMove
     End Object
     sl_RedSkin=GUISlider'utcompvSrc.UTComp_Menu_BrightSkins.RedSkinSlider'

     Begin Object Class=GUISlider Name=GreenSkinSlider
         MaxValue=128.000000
         bIntSlider=True
         WinTop=0.625000
         WinLeft=0.180000
         WinWidth=0.335000
         OnClick=GreenSkinSlider.InternalOnClick
         OnMousePressed=GreenSkinSlider.InternalOnMousePressed
         OnMouseRelease=GreenSkinSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
         OnKeyEvent=GreenSkinSlider.InternalOnKeyEvent
         OnCapturedMouseMove=GreenSkinSlider.InternalCapturedMouseMove
     End Object
     sl_GreenSkin=GUISlider'utcompvSrc.UTComp_Menu_BrightSkins.GreenSkinSlider'

     Begin Object Class=GUISlider Name=BlueSkinSlider
         MaxValue=128.000000
         bIntSlider=True
         WinTop=0.665000
         WinLeft=0.180000
         WinWidth=0.335000
         OnClick=BlueSkinSlider.InternalOnClick
         OnMousePressed=BlueSkinSlider.InternalOnMousePressed
         OnMouseRelease=BlueSkinSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
         OnKeyEvent=BlueSkinSlider.InternalOnKeyEvent
         OnCapturedMouseMove=BlueSkinSlider.InternalCapturedMouseMove
     End Object
     sl_BlueSkin=GUISlider'utcompvSrc.UTComp_Menu_BrightSkins.BlueSkinSlider'

     Begin Object Class=moCheckBox Name=ForceThisModelCheck
         Caption="Force This Model"
         OnCreateComponent=ForceThisModelCheck.InternalOnCreateComponent
         WinTop=0.702431
         WinLeft=0.098749
         WinWidth=0.309375
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
     End Object
     ch_ForceThisModel=moCheckBox'utcompvSrc.UTComp_Menu_BrightSkins.ForceThisModelCheck'

     Begin Object Class=moCheckBox Name=DarkSkinCheck
         Caption="Darken Dead Bodies"
         OnCreateComponent=DarkSkinCheck.InternalOnCreateComponent
         WinTop=0.330916
         WinLeft=0.648436
         WinWidth=0.264062
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
     End Object
     ch_DarkSkins=moCheckBox'utcompvSrc.UTComp_Menu_BrightSkins.DarkSkinCheck'

     Begin Object Class=moCheckBox Name=EnemyBasedModelCheck
         Caption="Enemy Based models"
         OnCreateComponent=EnemyBasedSkinCheck.InternalOnCreateComponent
         WinTop=0.330583
         WinLeft=0.367188
         WinWidth=0.273437
         OnChange=UTComp_Menu_BrightSkins.InternalOnChange
     End Object
     ch_EnemyModels=moCheckBox'utcompvSrc.UTComp_Menu_BrightSkins.EnemyBasedModelCheck'

     Begin Object Class=GUIButton Name=DeleteClanSkinButton
         Caption="Delete ClanSkin"
         WinTop=0.445833
         WinLeft=0.095938
         WinWidth=0.208125
         OnClick=UTComp_Menu_BrightSkins.InternalOnClick
         OnKeyEvent=DeleteClanSkinButton.InternalOnKeyEvent
     End Object
     bu_DeleteClanSkin=GUIButton'utcompvSrc.UTComp_Menu_BrightSkins.DeleteClanSkinButton'

     Begin Object Class=GUIButton Name=AddClanSkinButton
         Caption="Add Clanskin"
         WinTop=0.410417
         WinLeft=0.095938
         WinWidth=0.208125
         OnClick=UTComp_Menu_BrightSkins.InternalOnClick
         OnKeyEvent=AddClanSkinButton.InternalOnKeyEvent
     End Object
     bu_AddClanSkin=GUIButton'utcompvSrc.UTComp_Menu_BrightSkins.AddClanSkinButton'

     Begin Object Class=GUILabel Name=RedSkinLabel
         Caption="Red"
         TextColor=(R=255)
         WinTop=0.570000
         WinLeft=0.100000
     End Object
     l_RedSkin=GUILabel'utcompvSrc.UTComp_Menu_BrightSkins.RedSkinLabel'

     Begin Object Class=GUILabel Name=BlueSkinLabel
         Caption="Blue"
         TextColor=(B=255)
         WinTop=0.650000
         WinLeft=0.100000
     End Object
     l_BlueSkin=GUILabel'utcompvSrc.UTComp_Menu_BrightSkins.BlueSkinLabel'

     Begin Object Class=GUILabel Name=GreenSkinLabel
         Caption="Green"
         TextColor=(G=255)
         WinTop=0.610000
         WinLeft=0.100000
     End Object
     l_GreenSkin=GUILabel'utcompvSrc.UTComp_Menu_BrightSkins.GreenSkinLabel'

}
