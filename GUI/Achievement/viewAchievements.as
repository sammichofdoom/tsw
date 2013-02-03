import com.Components.TreeViewDataProvider;
import com.Components.TreeViewConstants;
import gfx.managers.DragManager;

var treeMenuData:Object = 
{
	label: "TOTAL",
		nodes: [ 
				{label: "SUMMARY" },
				{label: "GLOBAL" },
				{label: "REGIONAL", nodes:[ {label: "Regional 1"}, {label: "Regional 2"}, {label: "Regional 3"}, {label: "Regional 4"} ]},
				{label: "MISSIONS"},
				{label: "DUNGEONS & RAIDS"},
				{label: "PLAYERS VS. PLAYERS"},
				{label: "CRAFTING"},
				{label: "EXPLORATION"},
				{label: "FACTION"},
				{label: "CABAL"},
				{label: "LORE"}
			   ]
};

var treeMenuList:TreeViewDataProvider = new TreeViewDataProvider(treeMenuData);

m_MenuListTree.dataProvider = treeMenuList;
m_MenuListTree.selectedIndex = 0;

m_MenuListTree.addEventListener("focusIn", this, "RemoveFocus");

function RemoveFocus():Void
{
	Selection.setFocus(null);
};

function ExpandMenu(e:Object):Void {
	if (e.item && e.item.type!=TreeViewConstants.TYPE_LEAF) {
		// flip open/closed state
		e.item.type = ( e.item.type == TreeViewConstants.TYPE_OPEN )? TreeViewConstants.TYPE_CLOSED:TreeViewConstants.TYPE_OPEN;
		treeMenuList.validateLength();
		m_MenuListTree.invalidateData();
	}
}
m_MenuListTree.addEventListener("itemClick", this, "ExpandMenu");
stop();