import com.GameInterface.LoreNode;
import com.GameInterface.Lore;
import flash.geom.Point;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import gfx.core.UIComponent;

class GUI.Achievement.ViewPanelBase extends UIComponent
{
    private var m_SimpleProgressSize:Point;
    private var m_Data:LoreNode;
    private var m_MainText:MovieClip
    private var m_Width:Number
    private var m_Height:Number
    private var m_Panel:MovieClip;
    private var m_Content:MovieClip;
    private var m_ContentY:Number;
    private var m_HasMedia:Boolean;
    public var ID:Number;
    public var SignalClicked:Signal;
    public var SignalMediaAdded:Signal;
    private var m_HasAchievementEntries:Boolean;

    private var m_SuperInitialized:Boolean = false;
    
    public function ViewPanelBase()
    {
        SignalMediaAdded = new Signal();
    }
    
    public function SetData(data:LoreNode)
    {
        m_Data = Lore.GetFirstNonLeafNode(data);
        ID = data.m_Id;
        m_HasMedia = false;
        m_ContentY = 25;
        if (initialized)
        {
            SetMedia()
        }
        
    }

    private function SetMedia()
    {
        if (this["m_Media"] != undefined)
        {
            this["m_Media"].removeMovieClip();
        }
        if (ID != undefined)
        {
            var mediaId:Number = Lore.GetMediaId(ID, _global.Enums.LoreMediaType.e_Image )
            if (mediaId > 0)
            {
                var container:MovieClip = this.createEmptyMovieClip("m_Media", this.getNextHighestDepth());
                LoadImage(container, mediaId);
                m_HasMedia = true;
            }
        }
    }
    
    public function SetSize(width:Number, height:Number)
    {
        m_Width = width;
        m_Height = height;
      
        if (m_Content != undefined)
        {
            m_Content._y = m_ContentY;
        }
        
        if (m_HasAchievementEntries)
        {
            for (var i:Number = 0; i < m_Data.m_Children.length; i++ )
            {
                var loreNode:LoreNode = m_Data.m_Children[i];

                if (loreNode.m_Type != _global.Enums.LoreNodeType.e_AchievementCategory)
                {
                    m_Content["achievement_" + loreNode.m_Id].SetWidth( width );
                }
            }
        }        
        
        RepositionProgressMeters()
    }
    
    private function LoadImage(container:MovieClip, mediaId:Number)
    {
		var imageLoader:MovieClipLoader = new MovieClipLoader();
        
        var path = com.Utils.Format.Printf( "rdb:%.0f:%.0f", _global.Enums.RDBID. e_RDB_GUI_Image, mediaId );
	
		imageLoader.addListener( this );
		imageLoader.loadClip( path, container );
    }

	private function onLoadInit( target:MovieClip )
    {
        target._y = 40;
        
        var imagePadding:Number = 4
        var h:Number = target._height;
        var w:Number = target._width;
        
        target.lineStyle(2, 0xFFFFFF);
        target.moveTo( -imagePadding, -imagePadding);
        target.lineTo( w + imagePadding, -imagePadding);
        target.lineTo( w + imagePadding, h + imagePadding);
        target.lineTo( -imagePadding, h + imagePadding);
        target.lineTo( -imagePadding, -imagePadding);
        
        target._x =  10  //; ( m_Width - target._width ) * 0.5;
        m_ContentY = target._y + target._height + 20;
        m_Content._y = m_ContentY;
        SignalMediaAdded.Emit();
       
    }
    
    private function onLoadError(target:MovieClip, errorcode:String)
    {
        trace("failed loading image with error: " + errorcode);
    }
    
    private function UpdateProgressMeters()
    {
        m_Data = Lore.GetDataNodeById(m_Data.m_Id); // refresh data
        for (var i:Number = 0; i < m_Data.m_Children.length; i++)
        {
            var dataNode:LoreNode = m_Data.m_Children[i];
            var simpleProgress:MovieClip = m_Content["progress_" + dataNode.m_Id];
            if (simpleProgress != undefined)
            {
                simpleProgress.removeMovieClip();
            }
        }
        DrawProgressMeters();
    }
    
    private function DrawProgressMeters()
    {
        for (var i:Number = 0; i < m_Data.m_Children.length; i++)
        {
            var dataNode:LoreNode = m_Data.m_Children[i];
            var simpleProgress:MovieClip = m_Content.attachMovie("SimpleProgress", "progress_" + dataNode.m_Id, m_Content.getNextHighestDepth());
            if (m_SimpleProgressSize == undefined)
            {
                m_SimpleProgressSize = new Point(simpleProgress._width, simpleProgress._height) ;
            }
           
            SetProgress(simpleProgress.m_ProgressBar, simpleProgress.m_ProgressText, dataNode.m_HasCount, dataNode.m_TargetCount);            
            
            simpleProgress.m_Headline.text = dataNode.m_Name;
            simpleProgress.ref = this;
            simpleProgress.id = dataNode.m_Id;
            simpleProgress.onRelease = function()
            {
                this["ref"].ProgressMeterClickHandler(this.id);
            }
            if (dataNode.m_Locked && dataNode.m_HasCount == 0)
            {
                simpleProgress._alpha = 25;
                simpleProgress.m_Headline._x = 15;
                simpleProgress.m_ProgressText.filters = [];
                var lock:MovieClip = simpleProgress.attachMovie( "_Icon_Modifier_Lock", "lock", simpleProgress.getNextHighestDepth());
                lock._xscale = 45;
                lock._yscale = 45;
                lock._x = 6;
                lock._y = 5;
            }
        }
        
        RepositionProgressMeters();
    }
    
    public function GetYPos(id:Number)
    {
        if (m_Content["progress_" + id] != undefined)
        {
            return m_Content["progress_" + id]._y + m_Content["progress_" + id]._height*2/3;
        }
        return 0;
    }
    
    private function RepositionProgressMeters()
    {
        var ypos:Number = 0;
        var itemCount:Number = 0;
        var numPerLine = Math.floor(m_Width / (m_SimpleProgressSize.x+3));

        for (var i:Number = 0; i < m_Data.m_Children.length; i++)
        {
            var dataNode:LoreNode = m_Data.m_Children[i];
            var progressItem:MovieClip = m_Content["progress_" + dataNode.m_Id];
            
            if(progressItem != undefined)
            {
                progressItem._x = 3 + (((itemCount % numPerLine)) * (m_SimpleProgressSize.x + 3));
                progressItem._y = ypos;
                itemCount++;
                ypos = Math.floor(itemCount / numPerLine) * (m_SimpleProgressSize.y + 3);
            }
        }
    }
    
    private function GetBreadCrumbs(data:LoreNode) : String
    {
        /// breadcrumb display   
        var parent:LoreNode = data.m_Parent;
        var outputArray:Array = [];
        while ( parent.m_Parent != null)
        {
            outputArray.push( parent.m_Name );
            parent = parent.m_Parent;
        }
        outputArray.reverse();
        var outputString:String = outputArray.join("   ");
        return outputString.toUpperCase();
    }
    
    
    private function ProgressMeterClickHandler(id:Number)
    {
        DistributedValue.SetDValue("achievement_window_focus", id);
    }
    
    private function SetProgress(progressBar:MovieClip, progressText:TextField, current:Number, max:Number)
    {
        progressText.text = current + "/" + max;
        var percent:Number = current / max * 100;
        progressBar._xscale = percent;
    }
}
