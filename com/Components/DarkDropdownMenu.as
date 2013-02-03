import gfx.controls.DropdownMenu;

class com.Components.DarkDropdownMenu extends DropdownMenu
{
    // Constructor
    private function DarkDropdownMenu()
    {
        super();
        
//REMOVE THIS AFTER TESTING
        textField.borderColor = 0x00FF00;
        textField.border = true;
//-------------------------
    }

    // Update After State Change
    private function updateAfterStateChange():Void
    {
        //super.updateAfterStateChange();
        
        //if i call super's updateAfterStateChange() here, then there is a problem with rendering a new Finished Missions drop down
        //when it suddenly becomes visible again (namely, the drop arrow is stretched).  this is noticible when resizing the mission
        //journal window after having displayed the Finished Missions drop down menu, and then choosing Finished Missions again to
        //display the drop down menu.  resizing the Mission Journal window, clicking on or mousing out of the drop down menu will force
        //the correct display rendering. (??? wtf)
        
        Truncate(textField);
    }
   
    // Truncate
    private function Truncate(textField:TextField):Void
    {
        var margin:Number = 5;
        
        trace("*" + textField.textWidth + " " + textField._width + " " + _width + " " + textField._x);
        
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
        
        trace("**" + textField.text);
    }
}