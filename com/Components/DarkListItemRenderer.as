import gfx.controls.ListItemRenderer;

class com.Components.DarkListItemRenderer extends ListItemRenderer
{
    // Variables   
    public var isLoaded:Boolean;
	
    // Constructor
    private function DarkListItemRenderer()
    {
        super();
        isLoaded = true;
        
//REMOVE THIS AFTER TESTING
        textField.borderColor = 0xFF0000;
        textField.border = true;
//-------------------------
    }
    
    // Initialization
    private function onLoad():Void
    {
        super.onLoad();
        isLoaded = true;
    }

    // Update After Stage Change
    private function updateAfterStateChange():Void
    {
        super.updateAfterStateChange();
        UpdateUI();
    }
    
    // Update UI
    private function UpdateUI():Void
    {
        if (data != undefined && isLoaded)
        {
            Truncate(textField);
        }
    }
   
    // Truncate
    private function Truncate(textField:TextField):Void
    {
        var margin:Number = 5;
        
        if (textField.textWidth < textField._width - margin)
        {
            return;
        }
        
        var clippedString:String = textField.text;
        
        while (clippedString.length > 0 && textField.textWidth >= textField._width - margin)
        {
            clippedString = clippedString.substr(0, clippedString.length - 1);
            textField.text = clippedString + "...";
        }
    }
}
