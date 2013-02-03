//Imports
import com.Components.MultiColumnList.ColumnData;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.MultiColumnListView;
import com.Components.WindowComponentContent;
import com.Components.RightClickItem;
import com.GameInterface.CharacterLFG;
import com.GameInterface.Friends;
import com.GameInterface.LookingForGroup;
import com.GameInterface.Playfield;
import com.GameInterface.Lore;
import com.GameInterface.LoreNode;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.TeamInterface;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;
import GUI.GroupSearch.GroupSearchPromptWindow;
import gfx.controls.Button;
import gfx.controls.DropdownMenu;
import gfx.controls.ScrollBar;

//Class
class GUI.GroupSearch.GroupSearchContent extends WindowComponentContent
{
    //Constants
    public static var ARCHIVE_SELECTED_ROLES:String = "archiveLFGSelectedRoles";
    public static var ARCHIVE_SELECTED_DIFFICULTY:String = "archiveLFGSelectedDifficulty";
    public static var ARCHIVE_SELECTED_PLAYFIELD:String = "archiveLFGSelectedPlayfield";
    
    private static var ARCHIVE_COLUMN_FACTION_WIDTH:String = "archiveLFGColumnFactionWidth";
    private static var ARCHIVE_COLUMN_PLAYER_WIDTH:String = "archiveLFGColumnPlayerWidth";
    private static var ARCHIVE_COLUMN_TANK_WIDTH:String = "archiveLFGColumnTankWidth";
    private static var ARCHIVE_COLUMN_DPS_WIDTH:String = "archiveLFGColumnDPSWidth";
    private static var ARCHIVE_COLUMN_HEALER_WIDTH:String = "archiveLFGColumnHealerWidth";
    
    private static var DIFFICULTY:String = LDBFormat.LDBGetText("GroupSearchGUI", "difficulty");
    private static var PLAYFIELD:String = LDBFormat.LDBGetText("GroupSearchGUI", "playfield");
    private static var VIEW:String = LDBFormat.LDBGetText("GroupSearchGUI", "view");
    private static var REFRESH:String = LDBFormat.LDBGetText("GroupSearchGUI", "refresh");
    private static var SIGN_UP:String = LDBFormat.LDBGetText("GroupSearchGUI", "signUp");
    private static var LEAVE:String = LDBFormat.LDBGetText("GroupSearchGUI", "leave");
    private static var SIGNED_OUT_FIFO_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "leaveFifoMessage");
    private static var SIGNED_UP_FIFO_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "joinFifoMessage");
    private static var GM_FIFO_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "gmFifoMessage");
    
    private static var DIFFICULTY_NORMAL:String = LDBFormat.LDBGetText("GroupSearchGUI", "normalDifficulty");
    private static var DIFFICULTY_ELITE:String = LDBFormat.LDBGetText("GroupSearchGUI", "eliteDifficulty");
    private static var DIFFICULTY_NIGHTMARE:String = LDBFormat.LDBGetText("GroupSearchGUI", "nightmareDifficulty");
    
    private static var PLAYER_LIST_FOR:String = LDBFormat.LDBGetText("GroupSearchGUI", "playerListForPlayfieldAndDifficulty");
    private static var COLUMN_FACTION_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "columnFactionTitle");
    private static var COLUMN_PLAYER_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "columnPlayerTitle");
    private static var COLUMN_TANK_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "columnTankTitle");
    private static var COLUMN_DPS_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "columnDPSTitle");
    private static var COLUMN_HEALER_TITLE:String = LDBFormat.LDBGetText("GroupSearchGUI", "columnHealerTitle");
    
    private static var QUEUE_INFORMATION:String = LDBFormat.LDBGetText("GroupSearchGUI", "queueInfo");
    
    private static var INVITE_TO_GROUP:String = LDBFormat.LDBGetText("GroupSearchGUI", "inviteToGroup");
    private static var SEND_A_MESSAGE:String = LDBFormat.LDBGetText("GroupSearchGUI", "sendAMessage");
    
    private static var PRESS_SEARCH_BUTTON:String = LDBFormat.LDBGetText("GroupSearchGUI", "helpPressView");
    
    private static var ALL_DUNGEONS:String = LDBFormat.LDBGetText("GroupSearchGUI", "allDungeons");
    private static var ALL_ADVENTURE_PLAYFIELDS:String = LDBFormat.LDBGetText("GroupSearchGUI", "allAdventurePlayfields");
    
    private static var MAX_DROPDOWN_MENU_ROW_COUNT:Number = 21;
    private static var COLUMN_FACTION_ID:Number = 0;
    private static var COLUMN_NAME_ID:Number = 1;
    private static var COLUMN_TANK_ID:Number = 2;
    private static var COLUMN_DPS_ID:Number = 3;
    private static var COLUMN_HEALER_ID:Number = 4;
    private static var LEFT_CLICK_INDEX:Number = 1;
    private static var RIGHT_CLICK_INDEX:Number = 2;
    private static var RIGHT_CLICK_MOUSE_OFFSET:Number = 5;
    
    //Properties    
    private var m_LFGInterface:LookingForGroup;
    
    private var m_DifficultyTextField:TextField;
    private var m_PlayfieldTextField:TextField;
    private var m_DifficultyDropdownMenu:DropdownMenu;
    private var m_PlayfieldDropdownMenu:DropdownMenu;
    private var m_DropdownMenuTarget:DropdownMenu;
    private var m_UpdateInterval:Number;
    //private var m_DisableDropDownInterval:Number;
    private var m_DifficultyData:Array;
    private var m_DifficultySelectedItem:Object;
    private var m_PlayfieldSelectedItem:Object;
    private var m_ViewRefreshButton:Button;
    
    private var m_ListTitleHeader:MovieClip;
    private var m_List:MultiColumnListView;
    private var m_ListScrollBar:ScrollBar;
    private var m_ScrollBarPosition:Number;
    private var m_GroupArray:Array;
    
    private var m_QueueInfo:MovieClip;
    private var m_SignUpLeaveButton:Button;
    private var m_PromptWindow:MovieClip;
    private var m_RightClickMenu:MovieClip;
    private var m_SearchHelptext:TextField;
    
    private var m_Character:Character;
    private var m_SelectedCharacterName:String;
    private var m_SelectedCharacterID:ID32;
    
    private var m_MessageWindow:MovieClip;
    
    private var m_PersistentSelectedRoles:Array;
    private var m_PersistentDifficultyIndex:Number;
    private var m_PersistentPlayfieldIndex:Number
    
    //Constructor
    public function GroupSearchContent()
    {
        super();
        
        m_LFGInterface = new LookingForGroup();
        m_Character = Character.GetClientCharacter();
        
        m_PersistentSelectedRoles = new Array();
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_DifficultyTextField.text = DIFFICULTY;
        m_PlayfieldTextField.text = PLAYFIELD;
        
        m_DifficultyData = new Array();
        m_DifficultyData.push( { label:DIFFICULTY_NORMAL, data:_global.Enums.LFGDifficulty.e_Mode_Normal } );
        if (LookingForGroup.CanCharacterJoinEliteDungeons())
        {
            m_DifficultyData.push( { label:DIFFICULTY_ELITE, data:_global.Enums.LFGDifficulty.e_Mode_Elite } );
        }
        if (LookingForGroup.CanCharacterJoinNightmareDungeons())
        {
            m_DifficultyData.push( { label:DIFFICULTY_NIGHTMARE, data:_global.Enums.LFGDifficulty.e_Mode_Nightmare } );
        }

        m_DifficultyDropdownMenu.dataProvider = m_DifficultyData;
        m_DifficultyDropdownMenu.rowCount = MAX_DROPDOWN_MENU_ROW_COUNT;
        m_DifficultyDropdownMenu.addEventListener("select", this, "DropdownMenuSelectHandler");
        
        var playFieldNames:Array = GetAllPlayfieldsData(_global.Enums.LFGDifficulty.e_Mode_Normal); 
        m_PlayfieldDropdownMenu.dataProvider = playFieldNames;
        m_PlayfieldDropdownMenu.rowCount = Math.min(MAX_DROPDOWN_MENU_ROW_COUNT, playFieldNames.length);
        m_PlayfieldDropdownMenu.addEventListener("select", this, "DropdownMenuSelectHandler");
        m_PlayfieldDropdownMenu.addEventListener("press", this, "DropdownMenuPressHandler");
        
        m_DifficultySelectedItem = m_DifficultyDropdownMenu.selectedItem;
        m_PlayfieldSelectedItem = m_PlayfieldDropdownMenu.selectedItem;

        UpdateDropdownMenuSelection();
        
        m_LFGInterface.SignalSearchResult.Connect(SlotUpdateList, this);
        m_LFGInterface.SignalCharacterCountResult.Connect(SlotUpdatePlayfieldsDropDown, this);
        
        TeamInterface.SignalClientJoinedTeam.Connect(SlotJoinTeam, this);
        TeamInterface.SignalClientLeftTeam.Connect(SlotLeftTeam, this);
        
        m_List.SetItemRenderer("ItemRenderer");
        m_List.SetHeaderSpacing(3);
        m_List.SetShowBottomLine(true);
        m_List.SetScrollBar(m_ListScrollBar);
        m_List.AddColumn(COLUMN_FACTION_ID, COLUMN_FACTION_TITLE, 97, 0, 35);
        m_List.AddColumn(COLUMN_NAME_ID, COLUMN_PLAYER_TITLE, 310, 0);
        m_List.AddColumn(COLUMN_TANK_ID, COLUMN_TANK_TITLE, 65, 0);
        m_List.AddColumn(COLUMN_DPS_ID, COLUMN_DPS_TITLE, 65, 0);
        m_List.AddColumn(COLUMN_HEALER_ID, COLUMN_HEALER_TITLE, 65, 0);
        m_List.SetSize(598, 305);
        m_List.SignalItemClicked.Connect(SlotItemClicked, this);
        m_List.SignalMovieClipAdded.Connect(SlotMovieClipAdded, this);
        m_List.SetSecondarySortColumn(COLUMN_NAME_ID);
        
        m_ScrollBarPosition = 0;
        m_ListScrollBar._height = m_List._height - 13;
        
        m_PromptWindow = attachMovie("GroupSearchPromptWindow", "m_PromptWindow", getNextHighestDepth());
        m_PromptWindow.SignalPromptResponse.Connect(SlotPromptResponse, this);
        
        m_QueueInfo.m_Title.textColor = 0x00FF00;
        
        m_SearchHelptext.text = PRESS_SEARCH_BUTTON;
        
        m_MessageWindow = attachMovie("MessageWindow", "m_MessageWindow", getNextHighestDepth());
        
        var signUpLeaveButtonLabel:String = (LookingForGroup.HasCharacterSignedUp()) ? LEAVE : SIGN_UP;
        var signUpLeaveButtonSelected:Boolean = (LookingForGroup.HasCharacterSignedUp()) ? true : false;
        
        if ( LookingForGroup.HasCharacterSignedUp() )
        {
            var characterSignedData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData(); 
            var playerSignedPlayfield:String = GetPlayfieldName(characterSignedData.m_Playfields).toUpperCase(); 
            var playerSignedDifficulty:String = GetDifficultyName(characterSignedData.m_Mode);
            UpdateQueueInformation(playerSignedPlayfield, playerSignedDifficulty);
        }
        
        SetupButton(m_ViewRefreshButton, false, VIEW, false);
        SetupButton(m_SignUpLeaveButton, true, signUpLeaveButtonLabel, signUpLeaveButtonSelected);
        
        CreateRightClickMenu();
        
        //Wait until Dropdown is loaded to disable it if necessary (can't find better way...)
        //m_DisableDropDownInterval = setInterval(DisableDifficultyDropdown, 50, this);
        
        ToggleDisableControls(false);
        Selection.setFocus(null);
    }
    
    private function GetPlayfieldName(playfieldIds:Array):String
    {
        if (playfieldIds != undefined && playfieldIds.length > 0)
        {
            if (playfieldIds.length == 1 && playfieldIds[0] != undefined)
            {
                return LDBFormat.LDBGetText("Playfieldnames", playfieldIds[0]);
            }
            
            //Check if the first element is a dungeon (the rest will be the same)
            for (var i:Number = 0; i < LookingForGroup.m_DungeonPlayfields.length; ++i )
            {
                if (playfieldIds[0] == LookingForGroup.m_DungeonPlayfields[i].m_InstanceId)
                {
                    return ALL_DUNGEONS;
                }
            }
            
            for (var i:Number = 0; i < LookingForGroup.m_AdventurePlayfields.length; ++i )
            {
                if (playfieldIds[0] == LookingForGroup.m_AdventurePlayfields[i].m_InstanceId)
                {
                    return ALL_ADVENTURE_PLAYFIELDS;
                }
            }
        }
        return "";
    }
    
    //Slot Prompt Response
    private function SlotPromptResponse(mode:String, selectedRolesArray:Array, signOut:Boolean):Void
    {
        switch (mode)
        {
            case GroupSearchPromptWindow.MODE_SELECT_ROLE:      if (!signOut)
                                                                {
                                                                    m_SignUpLeaveButton.label = SIGN_UP;
                                                                    m_SignUpLeaveButton.selected = false;
                                                                }
                                                                else
                                                                {
                                                                    var selectedFields:Array = GetSelectedPlayfields();
                                                                    m_LFGInterface.SignUp(m_DifficultySelectedItem.data, selectedFields, selectedRolesArray);
                                                                    
                                                                    com.GameInterface.Chat.SignalShowFIFOMessage.Emit(SIGNED_UP_FIFO_MESSAGE, 0);
                                                                    
                                                                    if (m_Character.GetStat(_global.Enums.Stat.e_GmLevel) != 0)
                                                                    {
                                                                        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(GM_FIFO_MESSAGE, 0);
                                                                    }
                                                                    
                                                                    m_SignUpLeaveButton.label = LEAVE;
                                                                    m_SignUpLeaveButton.selected = true;
                                                                    
                                                                    UpdateQueueInformation(m_PlayfieldSelectedItem.label, 
                                                                                           m_DifficultySelectedItem.label);
                                                                }
                                                                m_PersistentSelectedRoles = selectedRolesArray;
                                                                
                                                                break;
                                                                
            case GroupSearchPromptWindow.MODE_CONFIRM_LEAVE:    if (signOut)
                                                                {
                                                                    m_SignUpLeaveButton.label = SIGN_UP;
                                                                    m_SignUpLeaveButton.selected = false;
                                                                    
                                                                    SignOut()
                                                                    UpdateListHeaderTitleAndSearch();
                                                                    
                                                                    UpdateQueueInformation();
                                                                }
                                                                else
                                                                {
                                                                    m_SignUpLeaveButton.label = LEAVE;
                                                                    m_SignUpLeaveButton.selected = true;
                                                                }
                                                                
        }

        ToggleDisableControls(false);
    }
    
    private function GetSelectedPlayfields():Array
    {
        var playfieldIds:Array = new Array();
        if (m_PlayfieldSelectedItem.data != undefined)
        {
            playfieldIds.push(m_PlayfieldSelectedItem.data);
        }
        else
        {
            if (m_PlayfieldSelectedItem.label == ALL_DUNGEONS)
            {
                playfieldIds = GetPlayfieldIds(LookingForGroup.m_DungeonPlayfields);
            }
            else
            {
                playfieldIds = GetPlayfieldIds(LookingForGroup.m_AdventurePlayfields);
            }
        }
        
        return playfieldIds;
    }
    
    //playfields is an Array of {label,data} objects
    private function GetLabelIndex(playfields:Array, name:String):Number
    {
        for ( var i:Number = 0; i < playfields.length; ++i )
        {
            if (playfields[i].label == name)
            {
                return i;
            }
        }
        return undefined;
    }
    
    //playfields is an Array of {label,data} objects
    private function GetInstanceIndex(playfields:Array, instanceId:Number):Number
    {
        for ( var i:Number = 0; i < playfields.length; ++i )
        {
            if (playfields[i].data == instanceId)
            {
                return i;
            }
        }
        return undefined;
    }
    
    //Get All Playfield Names Array {label,data}
    private function GetAllPlayfieldsData(difficulty:Number):Array
    {
        var retArray:Array =  new Array();

        retArray.push( { label: ALL_DUNGEONS, data: undefined } );
        var dungeonAdded:Boolean = false;
        for (var i:Number = 0; i < LookingForGroup.m_DungeonPlayfields.length; ++i)
        {
            if (LookingForGroup.m_DungeonPlayfields[i].HasDifficultyMode(difficulty))
            {
                var instanceId:Number = LookingForGroup.m_DungeonPlayfields[i].m_InstanceId;
                retArray.push( { label: "  " + LDBFormat.LDBGetText("Playfieldnames", instanceId).toUpperCase() + "  (0)", data: instanceId } );
                dungeonAdded = true;
            }
        }
        
        if (!dungeonAdded)
        {
            retArray.pop();
        }
        
        retArray.push( { label: ALL_ADVENTURE_PLAYFIELDS, data: undefined } );
        var playfieldAdded:Boolean = false;
        for (var j:Number = 0; j < LookingForGroup.m_AdventurePlayfields.length; ++j)
        {
            if (LookingForGroup.m_AdventurePlayfields[j].HasDifficultyMode(difficulty))
            {
                var instanceId:Number = LookingForGroup.m_AdventurePlayfields[j].m_InstanceId;
                retArray.push( { label: "  " + LDBFormat.LDBGetText("Playfieldnames", instanceId).toUpperCase()+ "  (0)", data: instanceId } );
                playfieldAdded = true;
            }
        }
        
        if (!playfieldAdded)
        {
            retArray.pop();
        }
        
        return retArray;
    }
    
    private function GetPlayfieldIds(playfields:Array):Array
    {
        var retArray:Array =  new Array();
        for (var i:Number = 0; i < playfields.length; ++i)
        {
            var playfield:Playfield = playfields[i];
            retArray.push(playfield.m_InstanceId);
        }
        return retArray;
    }

    //Setup Button
    private function SetupButton(target:Button, toggle:Boolean, label:String, selected:Boolean):Void
    {
        target.addEventListener((toggle) ? "select" : "click", this, "ButtonSelectHandler");
        target.disableFocus = true;
        target.toggle = toggle;
        target.label = label;
        target.selected = selected;
    }
    
    //Button Select Handler
    private function ButtonSelectHandler(event:Object):Void
    {
        if (!event.target.disabled)
        {
            switch (event.target)
            {
                case m_ViewRefreshButton:   if (m_ViewRefreshButton.label == VIEW)
                                            {
                                                m_ViewRefreshButton.label = REFRESH;
                                            }
                                            
                                            UpdateListHeaderTitleAndSearch();
                                            
                                            break;
                                            
                case m_SignUpLeaveButton:   if (LookingForGroup.HasCharacterSignedUp())
                                            {
                                                var characterSignedData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData();
                                                m_PromptWindow.ShowPrompt   (
                                                                            GroupSearchPromptWindow.MODE_CONFIRM_LEAVE,
                                                                            GetPlayfieldName(characterSignedData.m_Playfields),
                                                                            GetDifficultyName(characterSignedData.m_Mode)
                                                                            );
                                                                            
                                                ToggleDisableControls(true);
                                            }
                                            else
                                            {
                                                m_PromptWindow.ShowPrompt(GroupSearchPromptWindow.MODE_SELECT_ROLE);
                                                ToggleDisableControls(true);
                                            }
            }
        }
    }
    
    //Get Difficulty Name
    private function GetDifficultyName(value:Number):String
    {
        var index:Number = GetDifficultyIndex(value);
        
        if (index != undefined)
        {
            return m_DifficultyData[index].label;
        }
        
        return undefined;
    }
    
    private function GetDifficultyIndex(value:Number):Number
    {
        for (var i:Number = 0; i < m_DifficultyData.length; i++)
        {
            if (value == m_DifficultyData[i].data)
            {
                return i;
            }
        }
        
        return undefined;
    }
    
    //Sign Out
    private function SignOut():Void
    {
        m_SignUpLeaveButton.selected = false;
        m_SignUpLeaveButton.label = SIGN_UP;

        m_LFGInterface.SignOff();
        
        com.GameInterface.Chat.SignalShowFIFOMessage.Emit(SIGNED_OUT_FIFO_MESSAGE, 0);
    }
    
    //Update List Header Title And Search
    private function UpdateListHeaderTitleAndSearch():Void
    {
        m_ViewRefreshButton.disabled = true;
        m_ViewRefreshButton.label = REFRESH;
        
        var playfieldName:String = m_PlayfieldSelectedItem.label;
        var indexParenthesis:Number = playfieldName.indexOf("(");
        if (indexParenthesis > 0)
        {
            playfieldName = playfieldName.substring(0,indexParenthesis)
        }
        m_ListTitleHeader.m_Title.text = LDBFormat.Printf(PLAYER_LIST_FOR, playfieldName, m_DifficultySelectedItem.label);
        
        m_LFGInterface.DoSearch( m_DifficultySelectedItem.data, 
                                 GetSelectedPlayfields(), 
                                 [_global.Enums.Class.e_Tank, _global.Enums.Class.e_Damage, _global.Enums.Class.e_Heal], 
                                 true, 0);
    }
    
    //Update Queue Information
    private function UpdateQueueInformation(playfield:String, difficulty:String):Void
    {
        if (playfield == undefined || difficulty == undefined)
        {
            m_QueueInfo.m_Title.text =  "";
        }
        else
        {
            var indexParenthesis:Number = playfield.indexOf("(");
            if (indexParenthesis > 0)
            {
                playfield = playfield.substring(0,indexParenthesis)
            }
            m_QueueInfo.m_Title.text = LDBFormat.Printf(QUEUE_INFORMATION, playfield, difficulty);
        }
    }
    
    private function SlotJoinTeam():Void
    {
        m_SignUpLeaveButton.label = SIGN_UP;
        m_SignUpLeaveButton.disabled = true;
        m_SignUpLeaveButton.selected = false;
        UpdateQueueInformation();
        SlotUpdateList();
    }
    
    private function SlotLeftTeam():Void
    {
        m_SignUpLeaveButton.label = SIGN_UP;
        m_SignUpLeaveButton.disabled = false;
    }

    private function SlotUpdatePlayfieldsDropDown(countByPlayfield:Array, mode:Number):Void
    {
        var playfields:Array = GetAllPlayfieldsData(m_DifficultyDropdownMenu.selectedItem.data);
        var hasToInvalidateData:Boolean = false;
        for (var key:String in countByPlayfield)
        {
            var playfieldId:Number = parseInt(key, 10);
            var playfieldName:String = GetPlayfieldName([playfieldId]);
            var dropDownItemIndex:Number = GetInstanceIndex(playfields, playfieldId);
            m_PlayfieldDropdownMenu.dataProvider[dropDownItemIndex].label = "  "+playfieldName.toUpperCase() + "  (" + countByPlayfield[key]+ ")";
           
            hasToInvalidateData = true;
        }
        if (hasToInvalidateData)
        {
            m_PlayfieldDropdownMenu.invalidateData();
        }
    }
    
    
    //Slot Update List
    private function SlotUpdateList():Void
    {
        m_SearchHelptext._visible = false;
        
        m_GroupArray = new Array();
        
        m_List.RemoveAllItems();

        var characterSignedData:CharacterLFG = LookingForGroup.GetPlayerSignedUpData();
        if (LookingForGroup.HasCharacterSignedUp() && characterSignedData.m_Mode == m_DifficultySelectedItem.data)
        {
            var playerHasSignedUpToPlayfield:Boolean = false;
            var selectedPlayfields:Array = GetSelectedPlayfields();
            
            for (var i:Number = 0; i < characterSignedData.m_Playfields.length && !playerHasSignedUpToPlayfield; ++i)
            {
                for ( var j:Number = 0; j < selectedPlayfields.length; ++j )
                {
                    if (characterSignedData.m_Playfields[i] == selectedPlayfields[j])
                    {
                        playerHasSignedUpToPlayfield = true;
                        break;
                    }
                }
            }
            
            //Add player's character to the list
            if (playerHasSignedUpToPlayfield)
            {
                var characterLFG:CharacterLFG = new CharacterLFG();

                characterLFG.m_Name = m_Character.GetName();
                characterLFG.m_FirstName = m_Character.GetFirstName();
                characterLFG.m_LastName =  m_Character.GetLastName();
                characterLFG.m_FactionRank = m_Character.GetStat( _global.Enums.Stat.e_RankTag );
                characterLFG.m_Id = m_Character.GetID();
                characterLFG.m_Role = characterSignedData.m_Role;
                characterLFG.m_Playfields = characterSignedData.m_Playfields;
                characterLFG.m_Mode = characterSignedData.m_Mode;
                
                AddCharacterToList(characterLFG);
            }
        }
        
        for (var i:Number = 0; i < m_LFGInterface.m_CharactersLookingForGroup.length; ++i) 
        {
            AddCharacterToList(m_LFGInterface.m_CharactersLookingForGroup[i]);
        }
        
        m_List.AddItems(m_GroupArray);
        
        m_ViewRefreshButton.disabled = false;
    }
    
    //Add Character To List
    private function AddCharacterToList(characterLFG:CharacterLFG):Void
    {
        var charItem:MCLItemDefault = new MCLItemDefault(characterLFG);
        var factionRankData:MCLItemValueData = new MCLItemValueData();
        var currentTag:LoreNode = Lore.GetDataNodeById(characterLFG.m_FactionRank);

        var icon:ID32 = new ID32();
        icon.SetType(_global.Enums.RDBID.e_RDB_FlashFile);
        icon.SetInstance(currentTag.m_Icon);
        factionRankData.m_MovieClipRDBID = icon;
        charItem.SetValue(COLUMN_FACTION_ID, factionRankData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_RDB);
        
        var nameValueData:MCLItemValueData = new MCLItemValueData();
        nameValueData.m_Text = characterLFG.m_FirstName + " '" + characterLFG.m_Name +"' " + characterLFG.m_LastName;
        if ( !characterLFG.m_Id.Equal(m_Character.GetID()) )
        {
            nameValueData.m_MovieClipName = "RightClickButton";
        }
        else
        {
            nameValueData.m_MovieClipName = "EmptyClickButton";
        }
        nameValueData.m_MovieClipWidth = 50;
        charItem.SetValue(COLUMN_NAME_ID, nameValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);
        
        var untieIconSortValue:Number = 0; //For icon sorting
        
        var tankValueData:MCLItemValueData = new MCLItemValueData();
        if (characterLFG.HasRole(_global.Enums.Class.e_Tank))
        {
            tankValueData.m_MovieClipName = "TankIconEnabled";
            tankValueData.m_Number = 100; 
            untieIconSortValue += 25;
        }
        else
        {
            tankValueData.m_MovieClipName = "TankIconDisabled";
            tankValueData.m_Number = 0;
        }
        
        var healValueData:MCLItemValueData = new MCLItemValueData();
        if (characterLFG.HasRole(_global.Enums.Class.e_Heal))
        {
            healValueData.m_MovieClipName = "HealerIconEnabled";
            healValueData.m_Number = 100;
            untieIconSortValue += 25;
        }
        else
        {
            healValueData.m_MovieClipName = "HealerIconDisabled";
            healValueData.m_Number = 0;
        }            
        
        var armoredValueData:MCLItemValueData = new MCLItemValueData();
        if (characterLFG.HasRole(_global.Enums.Class.e_Damage))
        {
            armoredValueData.m_MovieClipName = "DPSIconEnabled";
            armoredValueData.m_Number = 100;
            untieIconSortValue += 25;
        }
        else
        {
            armoredValueData.m_MovieClipName = "DPSIconDisabled";
            armoredValueData.m_Number = 0;
        }
        
        //For icon sorting
        tankValueData.m_Number += untieIconSortValue;
        healValueData.m_Number += untieIconSortValue;
        armoredValueData.m_Number += untieIconSortValue;
        
        charItem.SetValue(COLUMN_HEALER_ID, healValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_SYMBOL);
        charItem.SetValue(COLUMN_TANK_ID, tankValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_SYMBOL);
        charItem.SetValue(COLUMN_DPS_ID, armoredValueData, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_SYMBOL);
        
        m_GroupArray.push(charItem);
    }
    
    private function DropdownMenuPressHandler(event:Object):Void
    {
        RequestCharactersCount(m_DifficultyDropdownMenu.selectedItem.data);
    }
    
    //Dropdown Menu Select Handler
    private function DropdownMenuSelectHandler(event:Object):Void
    {   
        if (!event.target.isOpen)
        {
            m_DropdownMenuTarget = event.target;
            m_UpdateInterval = setInterval(DropdownMenuItemSelected, 50, this);
            
            Selection.setFocus(null);
        }
    }

    //Dropdown Menu Item Selected
    private function DropdownMenuItemSelected(scope:Object):Void
    {
        clearInterval(scope.m_UpdateInterval);
        if  (
            (scope.m_DropdownMenuTarget == scope.m_DifficultyDropdownMenu && scope.m_DifficultySelectedItem != scope.m_DropdownMenuTarget.selectedItem) ||
            (scope.m_DropdownMenuTarget == scope.m_PlayfieldDropdownMenu && scope.m_PlayfieldSelectedItem != scope.m_DropdownMenuTarget.selectedItem)
            )
        {
            scope.UpdateDropdownMenuSelection();
        }
    }
    
    //Update Dropdown Menu Selection
    private function UpdateDropdownMenuSelection():Void
    {
        if (m_DifficultySelectedItem.data != m_DifficultyDropdownMenu.selectedItem.data)
        {
            UpdatePlayfieldsDropdown();
        }
        
        m_DifficultySelectedItem = m_DifficultyDropdownMenu.selectedItem;
        m_PlayfieldSelectedItem = m_PlayfieldDropdownMenu.selectedItem;
        
        m_DifficultyDropdownMenu.scrollBar = (m_DifficultyDropdownMenu.dataProvider.length > MAX_DROPDOWN_MENU_ROW_COUNT) ? "ScrollBarDropdownMenu" : undefined;
        m_PlayfieldDropdownMenu.scrollBar = (m_PlayfieldDropdownMenu.dataProvider.length > MAX_DROPDOWN_MENU_ROW_COUNT) ? "ScrollBarDropdownMenu" : undefined;
        
        m_ViewRefreshButton.label = VIEW;
    }
    
    //Get count of characters which are LFG
    private function RequestCharactersCount(difficultyMode:Number):Void
    {
        m_LFGInterface.RequestCharacterCount(difficultyMode);
    }
    
    private function UpdatePlayfieldsDropdown():Void
    {
        RequestCharactersCount(m_DifficultyDropdownMenu.selectedItem.data);
        var playfields:Array = GetAllPlayfieldsData(m_DifficultyDropdownMenu.selectedItem.data); 
        m_PlayfieldDropdownMenu.dataProvider = playfields;
        m_PlayfieldDropdownMenu.rowCount = Math.min(MAX_DROPDOWN_MENU_ROW_COUNT, playfields.length);

        var index:Number = GetLabelIndex(playfields, m_PlayfieldSelectedItem.label);
        if (index != undefined && m_PersistentPlayfieldIndex == undefined)
        {
            m_PlayfieldDropdownMenu.selectedIndex = index;
        }
        
        if ( m_PersistentPlayfieldIndex != undefined )
        {
            m_PlayfieldDropdownMenu.selectedIndex = m_PersistentPlayfieldIndex;
            m_PersistentPlayfieldIndex = undefined;
        }
    }
    
    //Toggle Disable Controls
    private function ToggleDisableControls(disable:Boolean):Void
    {
        m_DifficultyDropdownMenu.disabled = disable;
        m_PlayfieldDropdownMenu.disabled = disable;
        m_ViewRefreshButton.disabled = disable;
        var clientId:ID32 = Character.GetClientCharID();
        m_SignUpLeaveButton.disabled = TeamInterface.IsInTeam(clientId) || disable;
    }
    
    //Create Right Click Menu
    private function CreateRightClickMenu():Void
    {
        m_RightClickMenu = attachMovie("RightClickMenu", "m_RightClickMenu", getNextHighestDepth());
        m_RightClickMenu.width = 250;
        m_RightClickMenu.SetHandleClose(false);
        m_RightClickMenu.SignalWantToClose.Connect(HideRightClickMenu, this);
    }
    
    //Hide Right Click Menu
    private function HideRightClickMenu():Void
    {
        if (m_RightClickMenu)
        {
            m_RightClickMenu.Hide();
        }
    }
    
    //Slot Item Clicked
    private function SlotItemClicked(index:Number, buttonIndex:Number):Void
    {
        var characterLFG:CharacterLFG = m_List.GetItems()[index].GetId();

        var fullName:String = characterLFG.m_FirstName + " '"+ characterLFG.m_Name +"' " + characterLFG.m_LastName;
        RowSelected (
                    buttonIndex,
                    fullName,
                    characterLFG.m_Name,
                    characterLFG.m_Id
                    );
    }
    
    //Slot Movie Clip Added
    private function SlotMovieClipAdded(itemIndex:Number, columnId:Number, movieClip:MovieClip):Void
    {
        if (columnId == COLUMN_FACTION_ID)
        {
            movieClip.gotoAndStop(2);
        }
        
        if (columnId == COLUMN_NAME_ID)
        {
            movieClip.hitTestDisable = false;
            movieClip.m_Index = itemIndex;
            movieClip.m_Ref = this;
            movieClip.onPress = function() { this.m_Ref.SlotItemClicked(this.m_Index, 2); }
        }
    }
    
    //Row Selected
    private function RowSelected(buttonIndex:Number, characterFullName:String, characterName:String, characterID:ID32):Void
    {
        if (!Character.GetClientCharID().Equal(characterID))
        {
            var dataProvider:Array = new Array();
            
            dataProvider.push(new RightClickItem(characterFullName, true, RightClickItem.LEFT_ALIGN));
            dataProvider.push(RightClickItem.MakeSeparator());
            
            var inviteToGroupItem = new RightClickItem(INVITE_TO_GROUP, false, RightClickItem.LEFT_ALIGN);
            inviteToGroupItem.SignalItemClicked.Connect(InviteToGroupEventHandler, this);
            dataProvider.push(inviteToGroupItem);
                
            var sendMessageItem = new RightClickItem(SEND_A_MESSAGE, false, RightClickItem.LEFT_ALIGN);
            sendMessageItem.SignalItemClicked.Connect(SendMessageEventHandler, this);
            dataProvider.push(sendMessageItem);

            m_RightClickMenu.dataProvider = dataProvider;

            m_SelectedCharacterName = characterName;
            m_SelectedCharacterID = characterID;
            
            if (buttonIndex == RIGHT_CLICK_INDEX)
            {
                if (!m_RightClickMenu._visible)
                {
                    PositionRightClickMenu();
                    m_RightClickMenu.Show();
                }
                else 
                {
                    if (m_RightClickMenu.hitTest(_root._xmouse, _root._ymouse))
                    {
                        m_RightClickMenu.Hide();
                    }
                    else
                    {
                        PositionRightClickMenu();
                    }
                }
            }
        }
    }
    
    //Position Right Click Menu
    private function PositionRightClickMenu():Void
    {
        var visibleRect = Stage["visibleRect"];
        
        m_RightClickMenu._x = _xmouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._xmouse + m_RightClickMenu._width - visibleRect.width);
        m_RightClickMenu._y = _ymouse - RIGHT_CLICK_MOUSE_OFFSET - Math.max(0, _root._ymouse + m_RightClickMenu._height - visibleRect.height);
    }
    
    //On Mouse Press
    private function onMousePress(buttonIndex:Number, clickCount:Number):Void
    {
        HideRightClickMenu();
    }

    //Invite To Group Event Handler
    private function InviteToGroupEventHandler():Void
    {
        Friends.InviteToGroup(m_SelectedCharacterID);
    }
    
    //Send Message Event Handler
    private function SendMessageEventHandler():Void
    {
        m_MessageWindow.ShowMessageWindow(m_SelectedCharacterName);
        Selection.setFocus(m_MessageWindow.m_InputText.textField);
    }
    
    //Set Content Persistence
    public function SetContentPersistence(persistence:Archive):Void
    {
        if (persistence == undefined)
        {
            return;
        }

        m_PersistentDifficultyIndex = persistence.FindEntry(ARCHIVE_SELECTED_DIFFICULTY, undefined);
        m_PersistentPlayfieldIndex = persistence.FindEntry(ARCHIVE_SELECTED_PLAYFIELD, undefined);
        
        if ( m_PersistentDifficultyIndex != undefined )
        {
            m_DifficultyDropdownMenu.selectedIndex = m_PersistentDifficultyIndex;
            m_PersistentDifficultyIndex = undefined;
            UpdatePlayfieldsDropdown();
            m_DifficultySelectedItem = m_DifficultyDropdownMenu.selectedItem;
            m_PlayfieldSelectedItem = m_PlayfieldDropdownMenu.selectedItem;
        }
        
        var factionWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_FACTION_WIDTH, undefined);
        var playerWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_PLAYER_WIDTH, undefined);
        var tankWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_TANK_WIDTH, undefined);
        var dpsWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_DPS_WIDTH, undefined);
        var healerWidth:Number = persistence.FindEntry(ARCHIVE_COLUMN_HEALER_WIDTH, undefined);
        
        if (factionWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_FACTION_ID, factionWidth);
        }
        if(playerWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_NAME_ID, playerWidth);
        }
        if (tankWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_TANK_ID, tankWidth);
        }
        if(dpsWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_DPS_ID, dpsWidth);
        }
        if (healerWidth != undefined)
        {
            m_List.SetColumnWidth(COLUMN_HEALER_ID, healerWidth);
        }
        
        var selectedRoles:Array = persistence.FindEntryArray(ARCHIVE_SELECTED_ROLES);
        m_PromptWindow.SetRolePersistence(selectedRoles);
    }
    
    //Get Content Persistence
    public function GetContentPersistence():Archive
    {
        var archive:Archive = new Archive();
        
        archive.AddEntry(ARCHIVE_SELECTED_DIFFICULTY, m_DifficultyDropdownMenu.selectedIndex);
        archive.AddEntry(ARCHIVE_SELECTED_PLAYFIELD, m_PlayfieldDropdownMenu.selectedIndex);
        
        archive.AddEntry(ARCHIVE_COLUMN_FACTION_WIDTH, m_List.GetColumnWidth(COLUMN_FACTION_ID));
        archive.AddEntry(ARCHIVE_COLUMN_PLAYER_WIDTH, m_List.GetColumnWidth(COLUMN_NAME_ID));
        archive.AddEntry(ARCHIVE_COLUMN_TANK_WIDTH, m_List.GetColumnWidth(COLUMN_TANK_ID));
        archive.AddEntry(ARCHIVE_COLUMN_DPS_WIDTH, m_List.GetColumnWidth(COLUMN_DPS_ID));
        archive.AddEntry(ARCHIVE_COLUMN_HEALER_WIDTH, m_List.GetColumnWidth(COLUMN_HEALER_ID));
        
        for (var i:Number = 0; i < m_PersistentSelectedRoles.length; i++)
        {
            archive.AddEntry(ARCHIVE_SELECTED_ROLES, m_PersistentSelectedRoles[i]);
        }
        
        return archive;
    }
} 
