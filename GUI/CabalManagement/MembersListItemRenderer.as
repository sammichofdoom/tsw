import gfx.controls.ListItemRenderer;
import gfx.controls.CheckBox;
import com.GameInterface.Utils;

class GUI.CabalManagement.MembersListItemRenderer extends ListItemRenderer
{	

	private var _disableFocus:Boolean = true;

	public var id:Number;
	public var m_CheckBox:CheckBox;
	public var m_NickName:TextField;
	public var m_Playfield:TextField;
	public var m_GuildRank:TextField;
	
	private function MembersListItemRenderer() { super(); }
	
	public function setData(data:Object):Void
	{
		if (data == undefined) {
        	this._visible = false;
        	return;
      	}
      	this.data = data;
      	this._visible = true; 
		
		this.data = data;
		
		m_CheckBox.selected = data.selected;
		m_CheckBox.disableFocus = true;
		m_NickName.text = data.nickName;
		m_Playfield.text = data.playfield;
		m_GuildRank.text = data.guildRank.toString();
	}
	
private function updateAfterStateChange():Void
{
      if (!initialized) { return;}
     
	  setData(data);
	  validateNow();
      
	 if (constraints != null) {
         constraints.update(width, height);
      }
      dispatchEvent({type:"stateChange", state:state});
   }
}