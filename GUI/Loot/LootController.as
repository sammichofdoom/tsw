import com.GlobalSignal;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.Utils.Archive;
import com.Inventory.ItemSlot;
import GUI.Loot.LootWindow;
import com.GameInterface.Loot;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.ID32;

var m_LootBags:Array = [];

function onLoad()
{
    com.Utils.GlobalSignal.SignalLootBagOpened.Connect(SlotLootBagOpened, this);
}

function onUnload()
{
    com.Utils.GlobalSignal.SignalLootBagOpened.Disconnect(SlotLootBagOpened, this);
}

function CreateLootbag(id:ID32 ) : LootWindow
{
    var firstFreeIndex:Number = -1;

    for ( var i:Number = 0 ; i < m_LootBags.length ; ++i )
    {
        if ( m_LootBags[i].m_LootBag == undefined )
        {
            firstFreeIndex = i;
            break;
        }
    }

    if ( firstFreeIndex == -1 )
    {
        firstFreeIndex = m_LootBags.length;
        var lootBagNode:Object = new Object();
        lootBagNode.m_LootBag = undefined;
        lootBagNode.m_Position = new flash.geom.Point( _root._xmouse, _root._ymouse );
        m_LootBags.push( lootBagNode );
    }
    var lootBagNode:Object = m_LootBags[firstFreeIndex];

    var lootbagMC:MovieClip = this.createEmptyMovieClip( "lootbag_" + id, this.getNextHighestDepth() );
    var lootbag:LootWindow = new LootWindow(id, lootbagMC);
    lootBagNode.m_LootBag = lootbag;
    
    lootbag.SignalLootWindowClosed.Connect(SlotLootWindowClosed, this);

    Stage.addListener(lootbagMC); 
	
	var character:Character = Character.GetClientCharacter();
    if (character != undefined) { character.AddEffectPackage( "sound_fxpackage_GUI_loot_bag_open.xml" ); }
    
    return lootbag;
}

function SlotLootBagOpened( id:ID32 )
{
    for (var i:Number = 0; i < m_LootBags.length; i++)
    {
        if (m_LootBags[i].m_LootBag != undefined && m_LootBags[i].m_LootBag.GetID().Equal(id))
        {
            m_LootBags[i].m_LootBag.SetInventory(new Inventory(id));
            return;
        }
    }
    
    var lootBag:LootWindow = CreateLootbag(id);
    lootBag.SetInventory(new Inventory(id));
    lootBag.SetCenterPosition(_root._xmouse, _root._ymouse);
}

function SlotLootWindowClosed( lootBag:LootWindow, lastPosition:flash.geom.Point )
{
    for ( var i:Number = 0 ; i < m_LootBags.length ; ++i )
    {
        var lootBagNode:Object = m_LootBags[i];
        if ( lootBagNode.m_LootBag == lootBag )
        {
            lootBagNode.m_Position = lastPosition;
            lootBagNode.m_LootBag = undefined;
            break;
        }
    }
}


