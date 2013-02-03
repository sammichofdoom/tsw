import gfx.controls.ListItemRenderer;
import gfx.controls.CheckBox;

class com.Components.ListItemRendererCheckBox extends ListItemRenderer
 {
// UI Elements:
   public var chkBox:CheckBox;
//Variables   
   public var isLoaded:Boolean;
	
// Initialization:
   private function ListItemRendererCheckBox() {
     super();
	 isLoaded = false;
   }
   
   	private function onLoad():Void {
		super.onLoad();
		isLoaded = true;
		updateUI();
	}

// Public Methods:
   public function setData( dataObj:Object ) {
     super.setData( dataObj );
     updateUI();
   }

// Private Methods:
   private function updateAfterStateChange() : Void {
     super.updateAfterStateChange();
     updateUI();
   }

   private function updateUI() : Void {
     if (data == undefined) {
       this._visible = false;
     } else if(isLoaded) {
       this._visible = true; 
       chkBox.label = data.label;
       chkBox.selected = data.activated;
       chkBox.disabled = data.disabled;
       this.disabled = data.disabled;
     }
   }
}
