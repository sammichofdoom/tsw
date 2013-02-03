//Imports
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.Components.ItemSlot;
import com.Utils.LDBFormat;
import gfx.controls.Button;
import gfx.core.UIComponent;
import com.Utils.Signal;
import com.Utils.ID32;
import mx.utils.Delegate;

//Class
class GUI.NeedGreed.AcceptItemPromptWindow extends UIComponent
{
    //Constants
    private static var PROMPT_MESSAGE:String = LDBFormat.LDBGetText("MiscGUI", "MasterLooterOfferTitle");
    private static var OK_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Accept");
    private static var CANCEL_LABEL:String = LDBFormat.LDBGetText("GenericGUI", "Cancel");
    
    //Properties
    public var SignalPromptResponse:Signal;
    
    private var m_Background:MovieClip;
    private var m_Message:TextField;
    private var m_OKButton:Button;
    private var m_CancelButton:Button;
    private var m_IconSlot:MovieClip;
    private var m_ItemSlot:ItemSlot;
    
    private var m_MaxDragX;
    private var m_MinDragX;
    private var m_MaxDragY;
    private var m_MinDragY;
    
    //Constructor
    public function AcceptItemPromptWindow()
    {
        super();
        SignalPromptResponse = new Signal;
    }
    
    private function SetData(lootBagId:ID32, itemPosition:Number):Void
    {
        var inventory:Inventory = new Inventory(lootBagId);
        
        var item:InventoryItem = inventory.GetItemAt(itemPosition);
        
        if (!m_ItemSlot)
        {
            m_ItemSlot = new ItemSlot(lootBagId, itemPosition, m_IconSlot);
        }
        m_ItemSlot.SetData(item);
    }
    
    //Config UI
    private function configUI():Void
    {
        super.configUI();
        
        m_Message.htmlText = PROMPT_MESSAGE;
        m_Message.autoSize = "center";
        
        m_OKButton.label = OK_LABEL;
        m_OKButton.disableFocus = true;
        m_OKButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_CancelButton.label = CANCEL_LABEL;
        m_CancelButton.disableFocus = true;
        m_CancelButton.addEventListener("click", this, "ResponseButtonEventHandler");
        
        m_Background.onPress =  Delegate.create(this, MoveDrag);
        m_Background.onRelease = m_Background.onReleaseOutside  = Delegate.create(this, MoveDragRelease);
        
        var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];
        _x = (visibleRect.width  - m_Background._width) / 2;
        _y = (visibleRect.height - m_Background._height) / 2;
        
        CorrectPostion();
    }
    
    
    private function CheckPositionLimits() : Void
    {
        m_MaxDragX = Stage["visibleRect"].x + Stage["visibleRect"].width - m_Background._width;
        m_MinDragX = Stage["visibleRect"].x;
        m_MaxDragY = Stage["visibleRect"].y + Stage["visibleRect"].height - m_Background._height;
        m_MinDragY = Stage["visibleRect"].y;
    }
    
    public function CorrectPostion() : Void
    {
        CheckPositionLimits();
        if (_x < m_MinDragX)
        {
            _x = m_MinDragX;
        }
        else if (_x > m_MaxDragX)
        {
            _x = m_MaxDragX
        }
        
        if (_y < m_MinDragY)
        {
            _y = m_MinDragY;
        }
        else if (_y > m_MaxDragY)
        {
            _y = m_MaxDragY
        }        
    }
    
    //Response Button Event Handler
    private function ResponseButtonEventHandler(event:Object):Void
    {
        SignalPromptResponse.Emit(event.target == m_OKButton, m_ItemSlot.GetInventoryID(), m_ItemSlot.GetSlotID());
        Clear();
    }

    private function MoveDrag()
    {
        this.startDrag();
        m_Background.onMouseMove = Delegate.create(this, DragPositionCheck);
    }
    
    private function MoveDragRelease()
    {
        this.stopDrag();
        m_Background.onMouseMove  = function(){};
        CorrectPostion();
    }
    
    private function DragPositionCheck()
    {
        if (_x < m_MinDragX)
        {
            _x = m_MinDragX;
            MoveDragRelease();
        }
        else if (_x > m_MaxDragX)
        {
            _x = m_MaxDragX
            MoveDragRelease();
        }
        
        if (_y < m_MinDragY)
        {
            _y = m_MinDragY;
            MoveDragRelease();
        }
        else if (_y > m_MaxDragY)
        {
            _y = m_MaxDragY
            MoveDragRelease();
        }
    }
    
    public function Clear():Void
    {
        if (m_ItemSlot)
        {
            m_ItemSlot.Clear();
        }
        this.removeMovieClip();
    }
}
