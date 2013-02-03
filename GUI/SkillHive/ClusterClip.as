import com.GameInterface.SkillWheel.Cluster;
import com.GameInterface.Game.Character;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.Utils.Signal;
import GUI.SkillHive.SkillHiveDrawHelper;
import mx.utils.Delegate;

class GUI.SkillHive.ClusterClip extends MovieClip
{
    private var CLUSTER_COLOR_RANGED:Number = 0x795656;
    private var CLUSTER_COLOR_RANGED_PROGRESS:Number = 0xcd4b4b;
    private var CLUSTER_COLOR_RANGED_FULL:Number = 0xff5a5a;
    private var CLUSTER_COLOR_RANGED_LIGHT:Number = 0xff8174;

    private var CLUSTER_COLOR_MELEE:Number = 0x715d46;
    private var CLUSTER_COLOR_MELEE_PROGRESS:Number = 0xbb7a2f;
    private var CLUSTER_COLOR_MELEE_FULL:Number = 0xd97d14;
    private var CLUSTER_COLOR_MELEE_LIGHT:Number = 0xe08824;

    private var CLUSTER_COLOR_MAGIC:Number = 0x4a6e92;
    private var CLUSTER_COLOR_MAGIC_PROGRESS:Number = 0x2c99de;
    private var CLUSTER_COLOR_MAGIC_FULL:Number = 0x27abff;
    private var CLUSTER_COLOR_MAGIC_LIGHT:Number = 0x71ceff;

    private var CLUSTER_COLOR_MISC:Number = 0x487145;
    private var CLUSTER_COLOR_MISC_PROGRESS:Number = 0x487145;
    private var CLUSTER_COLOR_MISC_FULL:Number = 0x487145;
    private var CLUSTER_COLOR_MISC_LIGHT:Number = 0x487145;
	
    private var CLUSTER_COLOR_AUXILLIARY:Number = 0x315762;
    private var CLUSTER_COLOR_AUXILLIARY_PROGRESS:Number = 0x315762;
    private var CLUSTER_COLOR_AUXILLIARY_FULL:Number = 0x315762;
    private var CLUSTER_COLOR_AUXILLIARY_LIGHT:Number = 0x315762;
    
    public static var CLUSTER_ANGLE_DISTANCE = 3;
    public static var CELL_ANGLE_DISTANCE = 1;
    
    private var m_Cluster:Cluster;
    public var m_Angle:Number;
    public var m_Radius:Number;
    public var m_StartAngle:Number;
    public var m_ParentCluster:ClusterClip;
    public var m_Character:Character;
	public var m_ClusterDistance:Number;
	
	public var m_DrawShadow:Boolean;
    
    private var m_SubClusterClips:Array;
    
    private var m_EmptyColor:Number;
    private var m_ProgressColor:Number;
    private var m_FullColor:Number;
    private var m_LightColor:Number;
    
    public var SignalClick:Signal;
    public var SignalRollOver:Signal;
    public var SignalRollOut:Signal;
    
    private var m_NameLabel:MovieClip;
    private var m_DrawClip:MovieClip;
    //private var m_CompletionClip:MovieClip;
    private var m_Lock:MovieClip;
    
    public var m_IsLocked:Boolean;
    
    public var m_Alpha:Number
    
    //Draw variables
    private var m_Thickness:Number
    
    public function ClusterClip()
    {
        super();
        
        m_SubClusterClips = new Array();
        
        var shadowClip:MovieClip = createEmptyMovieClip("m_Shadow", getNextHighestDepth() ); // the clip where we draw the shadow, 
        m_DrawClip = createEmptyMovieClip( "m_DrawClip", getNextHighestDepth() ); // This so other things under cluClip can be buttons.
        //m_CompletionClip = createEmptyMovieClip( "m_CompletionClip", getNextHighestDepth() ); // This so other things under cluClip can be buttons.
        m_NameLabel = createEmptyMovieClip( "m_Label", getNextHighestDepth() );
        m_Lock = attachMovie("LockIcon", "m_Lock", getNextHighestDepth());
        m_Lock._xscale = 40;
        m_Lock._yscale = 40;
        
        m_NameLabel.attachMovie("ClusterLabel", "m_Text", m_NameLabel.getNextHighestDepth());
        m_NameLabel.m_Text.autoSize = "center";
        
        SignalClick = new Signal();
        SignalRollOver = new Signal();
        SignalRollOut = new Signal();
        
        m_NameLabel.onPress = function() { };
        m_DrawClip.onPress = function() { };
        //m_CompletionClip.onPress = function() { };
        
        m_NameLabel.onRollOver = Delegate.create(this, SlotRollOver);
        m_DrawClip.onRollOver = Delegate.create(this, SlotRollOver);
        //m_CompletionClip.onRollOver = Delegate.create(this, SlotRollOver);
        
        m_NameLabel.onRollOut = Delegate.create(this, SlotRollOut);
        m_DrawClip.onRollOut = Delegate.create(this, SlotRollOut);
        //m_CompletionClip.onRollOut = Delegate.create(this, SlotRollOut);
        
        m_NameLabel.onMousePress = Delegate.create(this, SlotClick);
        m_DrawClip.onMousePress = Delegate.create(this, SlotClick);
        //m_CompletionClip.onMousePress = Delegate.create(this, SlotClick);
        
        m_Thickness = 20;
        m_Alpha = 100;
		
		m_DrawShadow = true;
    }
    
    function Draw()
    {
        if (IsLocked())
        {
            m_Lock._visible = true;
            m_Alpha = 50;
            _alpha = 50;
        }
        else
        {
            m_Lock._visible = false;
            m_Alpha = 100;
            _alpha = m_Alpha;
        }
        
        m_DrawClip.clear();
        SkillHiveDrawHelper.MakeArch( m_DrawClip, m_Radius, m_Angle, m_Thickness, m_StartAngle, m_EmptyColor, 100, 0, 0x999999, m_DrawShadow && GetCluster().m_Cells.length > 0, m_LightColor );
        
        //Dont draw the completion for the new design (Keep it though)
        /*
        m_CompletionClip.clear();
        var completion:Number = m_Cluster.m_Completion;
        if (completion != NaN && completion > 0 && completion != undefined && m_CompletionClip != undefined)
        {
			var color:Number = m_ProgressColor;
			if (completion >= 1)
			{
				color = m_FullColor;
			}
            SkillHiveDrawHelper.MakeArch( m_CompletionClip, m_Radius+0.2, m_Angle * completion, m_Thickness - 0.2, m_StartAngle, color, 100, 0, 0x999999, false);
        }*/
        
        UpdateLabel();
        
        // Draw any subclusters.
        if( m_Cluster.m_Clusters != undefined)
        {
            var startAngle:Number = m_StartAngle;
            var subAngle:Number = (m_Angle - (CLUSTER_ANGLE_DISTANCE * (m_Cluster.m_Clusters.length-1))) / m_Cluster.m_Clusters.length;
            var radius:Number = m_Radius + m_ClusterDistance;
            
            for( var i = 0; i != m_Cluster.m_Clusters.length; i++ )
            {
                var subClusterClip:MovieClip = GetSubClusterClip( m_Cluster.m_Clusters[i] );
                if (subClusterClip != undefined)
                {
                    subClusterClip.m_Angle = subAngle;
                    subClusterClip.m_Radius = radius;
                    subClusterClip.m_StartAngle = startAngle;
                    
                    subClusterClip.Draw();
                    
                    startAngle += (subAngle + CLUSTER_ANGLE_DISTANCE)
                }
            }
        }
        
        DrawCells();
    }
    
    function DrawCells()
    {
        var cells:Array = m_Cluster.m_Cells;
        var numCells:Number = cells.length;
        
        var startAngle:Number = m_StartAngle;
        var subAngle:Number = (m_Angle - (CELL_ANGLE_DISTANCE * (numCells-1))) / numCells;
        var radius:Number = m_Radius + 25
        
        for( var i = 0; i < numCells; i++ )
        {
            var cellClipName:String = "m_Cell" + i + "_" + GetID();
            var cellClip:MovieClip = this[cellClipName];
            
            if (cellClip)
            {
                cellClip.m_Angle = subAngle;
                cellClip.m_Radius = radius;
                cellClip.m_StartAngle = startAngle;
                
                cellClip.Draw();
            }
            
            startAngle += (subAngle + CELL_ANGLE_DISTANCE)
            
        }
    }
    
    
    function UpdateLabel( )
    {
      // Make text.
      var textAngle:Number = m_StartAngle + m_Angle / 2;
      var midAngleRad:Number = Math.PI*textAngle/180;
      var radius:Number = m_Radius;
      m_NameLabel._x = Math.sin(midAngleRad) * (radius + (m_Thickness/2));
      m_NameLabel._y = -Math.cos(midAngleRad) * (radius + (m_Thickness/2));
      //We dont want to read backwards, so turn 180 degrees
      if (textAngle >= 90 && textAngle <= 270)
      {
          textAngle -= 180;
      }
      m_NameLabel._rotation = textAngle;
      
      // Lock pos/angle
      var lockAngle:Number = m_StartAngle + m_Angle / 5;
      var midAngleRad:Number = Math.PI*lockAngle/180;
      var radius:Number = m_Radius;
      m_Lock._x = Math.sin(midAngleRad) * (radius + (m_Thickness/2));
      m_Lock._y = -Math.cos(midAngleRad) * (radius + (m_Thickness/2));
      //We dont want to read backwards, so turn 180 degrees
      if (lockAngle >= 90 && lockAngle <= 270)
      {
          lockAngle -= 180;
      }
      m_Lock._rotation = lockAngle;
    }
    
    function SetCluster(cluster:Cluster)
    {
        m_Cluster = cluster;
		
		m_IsLocked = cluster.m_OverrideLocked;
        
        m_NameLabel.m_Text.text = m_Cluster.m_Name;
        m_NameLabel.m_Text._y = -m_NameLabel.m_Text._height/2;
        m_NameLabel.m_Text._x = -m_NameLabel.m_Text._width / 2;
        
        UpdateColors();
    }
        
    function UpdateColors()
    {
        if (m_Cluster.m_Id < 100)
        {
            m_EmptyColor = CLUSTER_COLOR_MELEE;
            m_ProgressColor = CLUSTER_COLOR_MELEE_PROGRESS;
            m_FullColor = CLUSTER_COLOR_MELEE_FULL;
            m_LightColor = CLUSTER_COLOR_MELEE_LIGHT;
        }
        else if (m_Cluster.m_Id < 200)
        {
            m_EmptyColor = CLUSTER_COLOR_MAGIC;
            m_ProgressColor = CLUSTER_COLOR_MAGIC_PROGRESS;
            m_FullColor = CLUSTER_COLOR_MAGIC_FULL;
            m_LightColor = CLUSTER_COLOR_MAGIC_LIGHT;
        }
        else if (m_Cluster.m_Id < 300)
        {
            m_EmptyColor = CLUSTER_COLOR_RANGED;
            m_ProgressColor = CLUSTER_COLOR_RANGED_PROGRESS;
            m_FullColor = CLUSTER_COLOR_RANGED_FULL;
            m_LightColor = CLUSTER_COLOR_RANGED_LIGHT;
        }
        else if (m_Cluster.m_Id >= 2000 && m_Cluster.m_Id < 2100)
        {
            m_EmptyColor = CLUSTER_COLOR_MISC;
            m_ProgressColor = CLUSTER_COLOR_MISC_PROGRESS;
            m_FullColor = CLUSTER_COLOR_MISC_FULL;
            m_LightColor = CLUSTER_COLOR_MISC_LIGHT;
        }
        else if (m_Cluster.m_Id >= 2100 && m_Cluster.m_Id < 2190)
        {
            m_EmptyColor = CLUSTER_COLOR_AUXILLIARY;
            m_ProgressColor = CLUSTER_COLOR_AUXILLIARY_PROGRESS;
            m_FullColor = CLUSTER_COLOR_AUXILLIARY_FULL;
            m_LightColor = CLUSTER_COLOR_AUXILLIARY_LIGHT;
        }
        else if (m_Cluster.m_Id >= 2190 && m_Cluster.m_Id < 2200)
        {
            m_EmptyColor = 0x527d87;
            m_ProgressColor = 0x527d87;
            m_FullColor = 0x527d87;
            m_LightColor = 0x527d87;
        }
        else// if (m_Cluster.m_Id >= 2200 && m_Cluster.m_Id < 2399)
        {
            m_EmptyColor = CLUSTER_COLOR_AUXILLIARY;
            m_ProgressColor = CLUSTER_COLOR_AUXILLIARY_PROGRESS;
            m_FullColor = CLUSTER_COLOR_AUXILLIARY_FULL;
            m_LightColor = CLUSTER_COLOR_AUXILLIARY_LIGHT;
        }
    }
    
    function GetCluster():Cluster
    {
        return m_Cluster;
    }
    
    function GetID()
    {
        return m_Cluster.m_Id;
    }
    
    function GetColor():Number
    {
        return m_FullColor;
    }
    
    function AddSubClusterClip(subClusterClip:MovieClip)
    {
        m_SubClusterClips.push(subClusterClip);
    }
    
    function GetSubClusterClip(clusterID:Number)
    {
        for (var i:Number = 0; i < m_SubClusterClips.length; i++)
        {
            if (m_SubClusterClips[i].GetID() == clusterID)
            {
                return m_SubClusterClips[i];
            }
        }
        return undefined;
    }
    
    public function IsLocked():Boolean
    {
		if (m_IsLocked != undefined)
		{
			return m_IsLocked;
		}
		if (!HasData())
		{
			return false;
		}
		
		var feat:FeatData = FeatInterface.m_FeatList[m_Cluster.m_Cells[0].m_Abilities[0]];
		return !feat.m_CanTrain && !feat.m_Trained
		
		
    }
    
    function SlotClick()
    {
		//Shouldnt be able to click if there is no data in this cluster
        if (!HasData())
		{
			return;
		}
		SignalClick.Emit(this);
		
    }
	
	function HasData()
	{
        return FeatInterface.m_FeatList[m_Cluster.m_Cells[0].m_Abilities[0]] != undefined;
	}
    
    function SlotRollOver()
    {
        SignalRollOver.Emit(this);
    }
    
    function SlotRollOut()
    {
        SignalRollOut.Emit(this);
    }
}