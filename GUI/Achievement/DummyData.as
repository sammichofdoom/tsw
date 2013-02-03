import com.GameInterface.LoreNode

var m_Data:LoreNode;

function CreateLoreNode(id:Number, name:String, isLocked:Boolean, children:Array, hascount:Number, targetcount:Number ) : LoreNode
{
    var lnode:LoreNode = new LoreNode();
    lnode.m_Id = id;
    lnode.m_Name = name;
	lnode.m_Type = 1;
	lnode.m_Locked = isLocked;
    lnode.m_Children = children;
    lnode.m_HasCount = hascount;
	lnode.m_TargetCount = targetcount;
    lnode.m_Parent = null;
    for (var i = 0; i < children.length; i++ )
    {
        children[i].m_Parent = lnode;
    }
    
    return lnode;
}


function onLoad()
{

    var gl_mine:LoreNode = CreateLoreNode(32, "Blue Ridge Mine", false, [], 30, 50);
    var gl_hotel:LoreNode = CreateLoreNode(33, "Overlook Hotel", false, [], 30, 50);
    var gl_chapter:LoreNode = CreateLoreNode(34, "Chapter", true, [], 30, 50);
    var gl_lighthouse:LoreNode = CreateLoreNode(35, "The Lighthouse", false, [], 30, 50);
  
    var el_mine:LoreNode = CreateLoreNode(36, "Blue Ridge Mine", false, [], 30, 50);
    var el_hotel:LoreNode = CreateLoreNode(37, "Overlook Hotel", false, [], 30, 50);
    var el_chapter:LoreNode = CreateLoreNode(38, "Chapter", true, [], 30, 50);
    var el_lighthouse:LoreNode = CreateLoreNode(39, "The Lighthouse", false, [], 30, 50);
  
    
    var se_mine:LoreNode = CreateLoreNode(20, "Blue Ridge Mine", true, [], 30, 50);
    var se_hotel:LoreNode = CreateLoreNode(21, "Overlook Hotel", false, [], 30, 50);
    var se_chapter:LoreNode = CreateLoreNode(22, "Chapter", true, [], 30, 50);
    var se_lighthouse:LoreNode = CreateLoreNode(23, "The Lighthouse", true, [], 30, 50);
    
    var sm_mine:LoreNode = CreateLoreNode(16, "Blue Ridge Mine", true, [], 30, 50);
    var sm_hotel:LoreNode = CreateLoreNode(17, "Overlook Hotel", true, [], 30, 50);
    var sm_chapter:LoreNode = CreateLoreNode(18, "Chapter", true, [], 30, 50);
    var sm_lighthouse:LoreNode = CreateLoreNode(19, "The Lighthouse", true, [], 30, 50);
    
    var sh_mine:LoreNode = CreateLoreNode(12, "Blue Ridge Mine", true, [], 30, 50);
    var sh_hotel:LoreNode = CreateLoreNode(13, "Overlook Hotel", true, [], 30, 50);
    var sh_chapter:LoreNode = CreateLoreNode(14, "Chapter", false, [], 30, 50);
    var sh_lighthouse:LoreNode = CreateLoreNode(15, "The Lighthouse", false, [], 30, 50);
    
    var sl_mine:LoreNode = CreateLoreNode(8, "Blue Ridge Mine", false, [], 30, 50);
    var sl_hotel:LoreNode = CreateLoreNode(9, "Overlook Hotel", false, [], 30, 50);
    var sl_chapter:LoreNode = CreateLoreNode(10, "Chapter", true, [], 30, 50);
    var sl_lighthouse:LoreNode = CreateLoreNode(11, "The Lighthouse", false, [], 30, 50);
    
    var s_history:LoreNode = CreateLoreNode(4, "History", false, [sh_mine, sh_hotel, sh_chapter, sh_lighthouse], 30, 50);
    var s_locations:LoreNode = CreateLoreNode(5, "Locations", false, [sl_mine, sl_hotel, sl_chapter, sl_lighthouse], 30, 50);
    var s_myths:LoreNode = CreateLoreNode(6, "Myths & Legends", false, [sm_mine, sm_hotel, sm_chapter, sm_lighthouse], 30, 50);
    var s_events:LoreNode = CreateLoreNode(7, "Recent Events", false, [se_mine, se_hotel, se_chapter, se_lighthouse], 30, 50);
    
    var g_history:LoreNode = CreateLoreNode(24, "History", true, [], 30, 50);
    var g_locations:LoreNode = CreateLoreNode(25, "Locations", false, [gl_mine, gl_hotel, gl_chapter, gl_lighthouse], 30, 50);
    var g_myths:LoreNode = CreateLoreNode(26, "Myths & Legends", true, [], 30, 50);
    var g_events:LoreNode = CreateLoreNode(27, "Recent Events", true, [], 30, 50);
    
    var e_history:LoreNode = CreateLoreNode(28, "History", true, [], 30, 50);
    var e_locations:LoreNode = CreateLoreNode(29, "Locations", false, [el_mine, el_hotel, el_chapter, el_lighthouse], 30, 50);
    var e_myths:LoreNode = CreateLoreNode(30, "Myths & Legends", true, [], 30, 50);
    var e_events:LoreNode = CreateLoreNode(31, "Recent Events", true, [], 30, 50);
    
    var summary:LoreNode = CreateLoreNode(1,"Summary",false,[s_history, s_locations, s_myths, s_events], 228, 900)
    var global:LoreNode = CreateLoreNode(2,"Global",false,[g_history, g_locations, g_myths, g_events], 23, 350)
    var egypt:LoreNode = CreateLoreNode(3,"Egypt",false,[e_history, e_locations, e_myths, e_events], 45, 200)
    
    m_Data = CreateLoreNode(0,"Toplevel",false,[summary, global, egypt], 228, 900);
    
    trace("loaded " + m_Data);
    
    var treeview:MovieClip = this.attachMovie("Treeview", "m_Treeview", this.getNextHighestDepth());
    treeview.SetData( m_Data, true);
}

onLoad()