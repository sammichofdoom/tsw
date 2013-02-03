import com.Components.ItemSlot;
import com.Components.ItemComponent;
import com.Utils.DragObject;
import flash.geom.Point;


class com.Utils.DragManager
{
    public static function StartDragItem(dragOwner:MovieClip, itemSlot:ItemSlot, stackSize:Number) : DragObject
    {
        var dragObject:DragObject = new DragObject();
        dragObject.type = itemSlot.GetDragItemType();
        dragObject.inventory_id = itemSlot.GetInventoryID();
        dragObject.inventory_slot = itemSlot.GetSlotID();
        dragObject.stack_size = stackSize;
        if (stackSize < itemSlot.GetData().m_StackSize)
        {
            dragObject.split = true;
        }
        
        var originalIcon:MovieClip = itemSlot.GetIcon();
        
        var dragMovieClip:MovieClip = dragOwner.attachMovie(itemSlot.GetIconTemplateName(), "m_DragClip", dragOwner.getNextHighestDepth());
        dragMovieClip.topmostLevel = true;
        dragMovieClip.hitTestDisable = true;
        var dragClip:ItemComponent = ItemComponent(gfx.managers.DragManager.instance.startDrag( originalIcon, dragMovieClip, dragObject, dragObject, originalIcon, false ));
        dragClip.SetData(itemSlot.GetData() );
        dragClip.SetStackSize( stackSize );
				
		dragClip._xscale = dragClip._yscale = com.GameInterface.DistributedValue.GetDValue( "GUIScaleInventory" );
        
        dragObject.SetDragClip(dragClip);
        
        var mainIconPos:Point = new Point(originalIcon._x, originalIcon._y );
        originalIcon.localToGlobal( mainIconPos );
        originalIcon.SetAlpha(50);
		
        gfx.managers.DragManager.instance.removeTarget = true;
        
        return dragObject;
    }
}