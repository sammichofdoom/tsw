import com.Utils.Colors;
import com.Components.MultiStateButton;
import mx.utils.Delegate;

class GUI.Patcher.PromptContainer extends MovieClip
{
    private var m_PromptContainer:MovieClip;
    /// center the mc 
    public function PromptContainer( text:String, acceptText:String, declineText:String, handler:Function, scope:Object, name:String, height:Number, width:Number, buttonHeight:Number)
    {
      //  parent.tabChildren = false;
        m_PromptContainer = scope.createEmptyMovieClip(name, scope.getNextHighestDepth());  
        
        var corner:Number = 8;
        
        var x:Number = 0;
        var y:Number = 0;
        
        var alpha:Number = 80;
        var lineThickness:Number = 2;
        
        com.Utils.Draw.DrawRectangle( m_PromptContainer, x, y, width, height, Colors.e_ColorPanelsBackground, alpha, [corner, corner, corner, corner], 1, Colors.e_ColorPanelsLine);
    
            /// goal info
        var textFormat:TextFormat = new TextFormat;
        textFormat.font = "_StandardFont";
        textFormat.size = 14;
        textFormat.color = 0xFFFFFF;
        textFormat.align = "center";
        
        var textField:TextField = m_PromptContainer.createTextField("i_Text", m_PromptContainer.getNextHighestDepth(), corner, corner+20, width - (2 * corner), height - (corner + buttonHeight + 20));
        textField.wordWrap = true;
        textField.autoSize = "center";
        textField.html = true;
        textField.htmlText = text;
        //textField.text = text;
          textField.setTextFormat(textFormat);
        
        var promptButton:MovieClip = MultiStateButton.CreateButton( m_PromptContainer, "promptButton", width, buttonHeight, 2, acceptText, declineText, corner );
        promptButton._y = height - buttonHeight;
        promptButton.SignalSelected.Connect( handler, scope)
    }

    public function Close()
    {
        m_PromptContainer.removeMovieClip();
    }
    
    public function Get() : MovieClip
    {
        return m_PromptContainer;
    }
}
