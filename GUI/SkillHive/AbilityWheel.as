import GUI.SkillHive.ClusterClip;
import GUI.SkillHive.CellClip;
import GUI.SkillHive.SkillHiveDrawHelper;
import GUI.SkillHive.SkillhiveCellTooltip;

import com.Utils.Signal;
import com.Utils.LDBFormat;
import com.Utils.Colors;

import com.GameInterface.SkillWheel.Cell;
import com.GameInterface.SkillWheel.Cluster;

import com.GameInterface.Game.Character;
import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;
import com.GameInterface.Log;

import flash.geom.Point;
import flash.geom.Matrix;
import flash.filters.DropShadowFilter;
import mx.transitions.easing.*;
import mx.utils.Delegate;

class GUI.SkillHive.AbilityWheel extends MovieClip
{
	private var m_Id:Number;
	private var m_Name:String;
	private var m_ShortName:String;
	private var m_Character:Character;
	private var m_ButtonName:String;
	
	public var SignalCellSelected:Signal;
	public var SignalCellAbilitySelected:Signal;
	public var SignalAnimateWheel:Signal;
	
	private var m_IsInitialized:Boolean;
	
	//Objects containing clusters/cells
	private var m_Clusters:Array;
	private var m_StartClusterList:Object;
	private var m_ClusterLookup:Object;
	private var m_CellArray:Array;
	private var m_LeafClusterIdArray:Array;
	private var m_ParentClusterIdArray:Array;
	
	private var m_SelectedCellClip:CellClip;
	
	//Wheel properties
	private var m_ClusterDistance:Number;
	
	private var m_WheelBackground:MovieClip;
	private var m_TemplateFilter:MovieClip;
	private var m_RingInnerRadius:Number;
	private var m_BackgroundInnerRadius:Number;
	private var m_DrawShadow:Boolean;
	
	//Tooltips
	private var m_HoveredCell:CellClip;
	private var m_CellTooltip:MovieClip;
	private var m_ClusterTooltip:MovieClip;
	private var m_HoveringTooltip:Boolean;
	private var m_DrawClusterTooltip:MovieClip;
	
	//Animation
	private var m_ZoomedClusterStack:Array;
	private var m_AnimationClip:MovieClip;//An empty clip controlling the animation of the wheel
	private var m_AnimatedCluster:MovieClip; // The cluster we are currently zooming into
	private var m_IsAnimating:Boolean; //Are we in an animation
	
	//Properties with completion
	private var m_NumAbilities:Number; //Holds the number of abilities in the skillhive
	private var m_TrainedAbilities:Number
	
	//Template Properties
	var m_TemplateFilterClips:Array; //An array that holds all the textfields used to show cell names in a template (For easier cleanup)
	var m_TemplateFilterArray:Array;
	
	public function AbilityWheel()
	{
		super();
		m_IsInitialized = false;
		m_ButtonName = "";
		
		SignalCellSelected = new Signal();
		SignalCellAbilitySelected = new Signal();
		SignalAnimateWheel = new Signal();
		
		m_ClusterLookup = new Object();
		m_CellArray = [];
		m_LeafClusterIdArray = [];
		m_ParentClusterIdArray = [];
		
		m_ClusterDistance = 75;
		
		m_SelectedCellClip = undefined;
		m_HoveredCell = undefined;
		m_CellTooltip = undefined;
		m_ClusterTooltip = undefined;
		m_HoveringTooltip = undefined;
		
		m_ZoomedClusterStack = [];
		m_AnimatedCluster = undefined;
		m_IsAnimating = false;
		
		m_NumAbilities = 0;
		m_RingInnerRadius = 0;
		m_BackgroundInnerRadius = 0;		
		m_DrawShadow = true;
		
		m_TemplateFilterClips = [];
		m_TemplateFilterArray = [];
		
		//Cannot do onenterframe on this, as we tween
		var onEnterFrameClip:MovieClip = createEmptyMovieClip("AnimateClip", getNextHighestDepth());
		onEnterFrameClip.onEnterFrame = Delegate.create(this, AnimateWheel);
		
		m_AnimationClip = createEmptyMovieClip("AnimateClip", getNextHighestDepth());
		m_AnimationClip.m_ZoomPos = 0
	}
	
	public function InitializeWheel()
	{
		m_IsInitialized = true;
				
		for (var featID in FeatInterface.m_FeatList )
		{
			var featData:FeatData = FeatInterface.m_FeatList[featID];
			if (featData != undefined)
			{ 
				var cell:Cell = FindCell(featData.m_ClusterIndex, featData.m_CellIndex+1);
				if (cell == undefined)
				{
					cell = new Cell(featData.m_CellIndex+1, featData.m_ClusterIndex);
					var cluster:Cluster = FindCluster(featData.m_ClusterIndex);
					if (cluster != undefined)
					{
						cluster.m_Cells[featData.m_CellIndex] = cell;
					}
				}
				
				cell.m_Abilities[featData.m_AbilityIndex] = featData.m_Id;
				
				
			}
		}
		
		CalculateNumAbilities();
		CalculateCompletion();
		
		for( var cat in m_StartClusterList )
		{
			var data = m_StartClusterList[cat];
			var clip:MovieClip = MakeCluster( data.clusterId, data.angle, data.radius, data.startAngle, undefined );
			clip.Draw();
		}	
	}
	
	/** Accessors **/
	
	public function SetId(id:Number)
	{
		m_Id = id;
	}
	
	public function SetName(name:String)
	{
		m_Name = name;
	}
	
	public function SetShortName(name:String)
	{
		m_ShortName = name;
	}
	
	public function GetId() : Number
	{
		return m_Id;
	}
	
	public function GetName(): String
	{
		return m_Name;
	}
	
	public function GetShortName(): String
	{
		return m_ShortName;
	}
	
	public function SetButtonName(buttonName)
	{
		m_ButtonName = buttonName;
	}
	
	public function GetButtonName() : String
	{
		return m_ButtonName;
	}
	
	public function SetStartClusters(clusters:Object)
	{
		m_StartClusterList = clusters;
	}
	
	public function SetClusters(clusters:Array )
	{
		m_Clusters = clusters;
	}
	
	public function SetCharacter(character:Character)
	{
		m_Character = character;
	}
	
	public function SetClusterDistance(clusterDistance:Number)
	{
		m_ClusterDistance = clusterDistance;
	}
	
	public function GetClusterDistance() : Number
	{
		return m_ClusterDistance;
	}
	
	public function SetDrawShadow(drawShadow:Boolean)
	{
		m_DrawShadow = drawShadow;
		if (m_IsInitialized)
		{
			Redraw();
		}
	}
	
	public function SetWheelRadius(ringInnerRadius:Number, backgroundInnerRadius:Number)
	{
		m_RingInnerRadius = ringInnerRadius;
		m_BackgroundInnerRadius = backgroundInnerRadius;
	}
	
	public function SetTemplateFilterArray(templateArray:Array)
	{
		m_TemplateFilterArray = templateArray;
	}
	
	public function SetWheelBackground(background:MovieClip)
	{
		m_WheelBackground = background;
	}
	
	public function SetTemplateFilterClip(templateFilterClip:MovieClip)
	{
		m_TemplateFilter = templateFilterClip;
	}
	
	function FindCell(clusterID:Number, cellID:Number):Cell
	{
		return FindCluster(clusterID).m_Cells[cellID-1];
	}
	
	function FindCluster(clusterID:Number):Cluster
	{
		for (var i in m_Clusters)
		{
			if (m_Clusters[i].m_Id == clusterID)
			{
				return m_Clusters[i];
			}
		}
		return undefined;
	}
	
	public function HasCluster(clusterId:Number):Boolean
	{
		return FindCluster(clusterId) != undefined;
	}
	
	public function GetCellClip(clusterIdx:Number, cellIdx:Number):CellClip
	{
		for (var i:Number = 0; i < m_CellArray.length; i++)
		{
			if (cellIdx == m_CellArray[i].GetID() && clusterIdx == m_CellArray[i].GetParentClusterID())
			{
				return m_CellArray[i];
			}
		}    
        return undefined;
	}
	
	public function GetCompletionText() : String
	{
		var completionText = "";
		if (m_ZoomedClusterStack.length == 0)
		{
			completionText = LDBFormat.LDBGetText("GenericGUI", "Total");
		}
		else
		{
			completionText =  m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster.m_Cluster.m_Name.toUpperCase();
		}
		return LDBFormat.Printf(LDBFormat.LDBGetText("GenericGUI", "PowerWheelCompletion"), completionText);
	}
	
	public function GetTotalCompletion() : String
	{
		var totalCompletion:Number = 0;
		var trainedAbilities:String;
		if (m_ZoomedClusterStack.length == 0)
		{
			totalCompletion = m_TrainedAbilities / m_NumAbilities;
		}
		else
		{
			var numAbilities:Number = GetNumClusterAbilities(m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster.m_Cluster.m_Id);
			totalCompletion = m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster.m_Cluster.m_TrainedAbilities / numAbilities;
		}
		return com.Utils.Format.Printf( "%.1f", totalCompletion * 100) + "%";
	}
	
	public function GetTotalAbilities() : String
	{
		var trainedAbilities:String;
		if (m_ZoomedClusterStack.length == 0)
		{
			trainedAbilities = m_TrainedAbilities+"/" + m_NumAbilities;
		}
		else
		{
			var numAbilities:Number = GetNumClusterAbilities(m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster.m_Cluster.m_Id);
			trainedAbilities = m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster.m_Cluster.m_TrainedAbilities+"/" + numAbilities;
		}
		return trainedAbilities;
	}
	
	public function GetBreadcrumbArray(breadcrumbContent:MovieClip)
	{
		var breadcrumbLabelArray:Array = new Array();
		var currentCluster = m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster;
		var numLabels = 0;
		while (currentCluster != undefined)
		{
			if (numLabels > 0)
			{
				var splitLabel = breadcrumbContent.attachMovie("BreadcrumbLabel", "", breadcrumbContent.getNextHighestDepth());
				splitLabel.text = " / ";
				splitLabel.autoSize = "center";
				breadcrumbLabelArray.push(splitLabel);
			}
			var bcLabel = breadcrumbContent.attachMovie("BreadcrumbLabel", "", breadcrumbContent.getNextHighestDepth());
			bcLabel.text = currentCluster.m_Cluster.m_Name.toUpperCase();
			bcLabel.autoSize = "center";
			bcLabel.SetLinkedMovieClip(currentCluster);
			breadcrumbLabelArray.push(bcLabel);
			currentCluster = currentCluster.m_ParentCluster;
			numLabels++;
		}
		return breadcrumbLabelArray;
	}
	
	public function GetSelectedCell() : Cell
	{
		if (m_SelectedCellClip != undefined)
		{
			return m_SelectedCellClip.GetCell();
		}
		return undefined;
	}
	
	public function GetSelectedCellClip() : CellClip
	{
		return m_SelectedCellClip;
	}
	
	public function SetSelectedCellFromIndex(clusterIndex:Number, cellIndex:Number)
	{
		var cellClip:CellClip = GetCellClip(clusterIndex, cellIndex);
		if (cellClip != undefined)
		{
            //cellClip = m_CellArray[0];
            SelectCell(cellClip);
		}
	}
	
	public function IsAnimating() : Boolean
	{
		return m_IsAnimating;
	}
	
	/** DRAWING FUNCTIONALITY **/
	
	function MakeCluster( id:Number, angle:Number, radius:Number, startAngle:Number, parentCluster:MovieClip ) : MovieClip
	{
		var cluster:Cluster = FindCluster(id);
		var clusterClip:ClusterClip = m_ClusterLookup[id];
        if (clusterClip == undefined)
        {
            clusterClip = ClusterClip(attachMovie( "ClusterClip", "m_Cluster" + cluster.m_Id, getNextHighestDepth() ));
            clusterClip.SignalRollOver.Connect(SlotRollOverCluster, this);
            clusterClip.SignalRollOut.Connect(SlotRollOutCluster, this);
            clusterClip.SignalClick.Connect(SlotClickCluster, this);
    
        }
        // Set the data.
        clusterClip.SetCluster(cluster);
		clusterClip.m_Angle = angle;
		clusterClip.m_Radius = radius;
		clusterClip.m_StartAngle = startAngle;
		clusterClip.m_ParentCluster = ClusterClip(parentCluster);
		clusterClip.m_Character = m_Character;
		clusterClip.m_DrawShadow = m_DrawShadow;
		clusterClip.m_ClusterDistance = m_ClusterDistance;

		m_ClusterLookup[id] = clusterClip;
		
		//Special case for misc clusters
		if (cluster.m_Clusters != undefined || id == 2001 || id == 2002 || id == 2003)
		{
			m_ParentClusterIdArray.push(id); 
		}
		else
		{
			m_LeafClusterIdArray.push(id);
		}
		// If it has subclusters, then make those.
		if( cluster.m_Clusters != undefined )
		{
			m_ParentClusterIdArray.push(id);  
			var subAngle:Number = angle / cluster.m_Clusters.length;
			for( var i=0; i!= cluster.m_Clusters.length; i++ )
			{
				var startAngle = startAngle + i * subAngle
				if (i != 0)
				{
					startAngle += ClusterClip.CLUSTER_ANGLE_DISTANCE;
				}
				var subCluster:MovieClip = MakeCluster( cluster.m_Clusters[i], subAngle - ClusterClip.CLUSTER_ANGLE_DISTANCE, radius + m_ClusterDistance, startAngle, clusterClip );
                clusterClip.AddSubClusterClip(subCluster);
			}
		}

		// Make it's cells.
		var cells:Array = cluster.m_Cells;
		var numCells:Number = cells.length;
		var pieceAngle:Number = angle/numCells;

		for( var i=0; i<numCells; i++ )
		{
			//var cellId:Number = cells[i].m_Id;
			var clusterId:Number = cells[i].m_ClusterId;
            var cellClipName:String = "m_Cell" + i + "_" + clusterId;
			var cellClip:CellClip = clusterClip[cellClipName];
            
            if (cellClip == undefined)
            {
                cellClip = CellClip(clusterClip.attachMovie( "CellClip", cellClipName, clusterClip.getNextHighestDepth() ));
                cellClip.SignalClick.Connect(SlotClickCell, this);
                cellClip.SignalRollOut.Connect(SlotRollOutCell, this);
                cellClip.SignalRollOver.Connect(SlotRollOverCell, this);
                m_CellArray.push(cellClip);
            }
			
			cellClip.SetCell(cells[i]);
			cellClip.m_Angle = pieceAngle;
			cellClip.m_Radius = radius + 20;
			cellClip.m_StartAngle = i * pieceAngle;

		}
		
		return clusterClip;
	}
	
	
	function Redraw()
	{
		for( var cat in m_StartClusterList )
		{
			m_ClusterLookup[m_StartClusterList[cat].clusterId].Draw();
		}
	}
	
	function DrawBackground()
	{
		if (m_WheelBackground != undefined)
		{
			 // White ring.
			var innerRingThickness:Number = 2;
			var innerRingColor:Number = 0xEEEEEE;
			var startPoint:Point = new Point(0, 0);

			m_WheelBackground.clear();
			
			//Make the thin rings around
			SkillHiveDrawHelper.MakeArch( m_WheelBackground, m_RingInnerRadius + 70, 360, 1, 0, innerRingColor, 5, 0, 0x999999, false);
			SkillHiveDrawHelper.MakeArch( m_WheelBackground, m_RingInnerRadius + 130, 360, 1, 0, innerRingColor, 5, 0, 0x999999, false);
			SkillHiveDrawHelper.MakeArch( m_WheelBackground, m_RingInnerRadius + 180, 360, 1, 0, innerRingColor, 5, 0, 0x999999, false);
			SkillHiveDrawHelper.MakeArch( m_WheelBackground, m_RingInnerRadius + 300, 360, 1, 0, innerRingColor, 5, 0, 0x999999, false);
			
			//Make all the lines
			for (var i:Number = 0; i < m_CellArray.length; i++)
			{
				if (IsLeafCluster(m_CellArray[i].GetParentClusterID()))
				{
					//Draw the line belonging to this cell (Not the first cell in each cluster, as the cluster draws a thicker line there
					if (m_CellArray[i].m_Id != 1)
					{
						DrawSectorLine(m_WheelBackground, 2, 0xDDDDDD, 2, startPoint, m_CellArray[i].m_StartAngle - ClusterClip.CELL_ANGLE_DISTANCE / 2, m_BackgroundInnerRadius, 480);
					}
				}
				
				if (m_CellArray[i].IsSelected() && m_CellArray[i]._parent._visible)
				{
					var sectorColor:Number = 0xBBBBBB;
					var sectorAlpha:Number = 20;
					
					var startAngle:Number = m_CellArray[i].m_StartAngle;
					var angle:Number = m_CellArray[i].m_Angle;
					var endAngle:Number = startAngle + angle;
					var startPoint:Point = new Point(0, 0);
					
					DrawSector(m_WheelBackground, sectorColor, sectorAlpha, 0, 0xFFFFFF, 0, startPoint, startAngle, endAngle, m_BackgroundInnerRadius, 500, true);
				}            
			}
			for (var prop in m_ClusterLookup)
			{
				var startAngle = m_ClusterLookup[prop].m_StartAngle;
				var endAngle = m_ClusterLookup[prop].m_StartAngle + m_ClusterLookup[prop].m_Angle;
				if (IsParentCluster(m_ClusterLookup[prop].GetID()) || IsLeafCluster(m_ClusterLookup[prop].GetID()))
				{
					DrawSectorLine(m_WheelBackground, 2, 0xDDDDDD, 10, startPoint, startAngle - ClusterClip.CLUSTER_ANGLE_DISTANCE / 2 , m_BackgroundInnerRadius, 480);
				}
			}
		}
	}
	
	public function DrawTemplates()
	{
		if (m_TemplateFilter != undefined)
		{
			m_TemplateFilter.clear();
			
			ClearTemplateFilterClips();
			
			for (var i:Number = 0; i < m_CellArray.length; i++)
			{
				if (m_CellArray[i]._parent._visible)
				{
					//Draw the sector for this cell
					DrawCellTemplate(m_CellArray[i]);
				}
			}
		}
	}
	
	public function ClearTemplateFilterClips()
	{
		for (var i:Number = 0; i < m_TemplateFilterClips.length; i++)
		{
			m_TemplateFilterClips[i].removeMovieClip();
		}
		m_TemplateFilterClips = [];
	}
	
	function IsLeafCluster( clusterID ):Boolean
	{
		for (var i:Number = 0; i < m_LeafClusterIdArray.length; i++)
		{
			if (m_LeafClusterIdArray[i] == clusterID)
			{
				return true;
			}
		}
		return false;
	}

	function IsParentCluster(clusterID):Boolean
	{
		for (var i:Number = 0; i < m_ParentClusterIdArray.length; i++)
		{
			if (m_ParentClusterIdArray[i] == clusterID)
			{
				return true;
			}
		}
		return false;
	}
	
	function DrawSectorLine(parentClip:MovieClip, lineThickness:Number, lineColor:Number, lineAlpha:Number, startPoint:Point, startAngle:Number, startDistance:Number, endDistance:Number)
	{
		parentClip.lineStyle(lineThickness, 0xDDDDDD, lineAlpha);
		var p:Point = CalculatePointOnCircumference(startPoint, startDistance, startAngle);
		parentClip.moveTo(p.x, p.y);
		p = CalculatePointOnCircumference(startPoint, endDistance, startAngle);
		parentClip.lineTo(p.x, p.y);
	}

	function CalculatePointOnCircumference(centerPoint:Point, distance:Number, angle:Number):Point
	{
		var radAngle:Number = (angle - 90) * Math.PI / 180.0;
		var p:Point = new Point;
		p.x = centerPoint.x + distance * Math.cos(radAngle);
		p.y = centerPoint.y + distance * Math.sin(radAngle);
		return p;
	}
	
	function DrawCellTemplate(cellClip:CellClip)
	{
		var abilitiesInTemplate:Array = GetAbilitiesInTemplate(cellClip.GetParentClusterID(), cellClip.GetID());
		if (abilitiesInTemplate.length > 0)
		{
			var startAngle:Number = cellClip.m_StartAngle;
			var angle:Number = cellClip.m_Angle;
			var startPoint:Point = new Point(0, 0);
			var numOwned:Number = 0;
			var canTrain:Boolean = false;
			for (var i:Number = 0; i < abilitiesInTemplate.length; i++)
			{
				if (FeatInterface.m_FeatList[abilitiesInTemplate[i]] != undefined )
				{
					if (FeatInterface.m_FeatList[abilitiesInTemplate[i]].m_Trained)
					{
						numOwned++;
					}
					if (FeatInterface.m_FeatList[abilitiesInTemplate[i]].m_CanTrain)
					{
						canTrain = true;
					}
				}
			}
			var templateFilterClip:MovieClip = m_TemplateFilter.attachMovie("CellTemplateFilter", "m_TemplateFilter_" + cellClip.GetID(), m_TemplateFilter.getNextHighestDepth());
			var templateFilterLabelClip:MovieClip = m_TemplateFilter.attachMovie("CellTemplateFilterLabel", "m_TemplateFilterLabel_" + cellClip.GetID(), m_TemplateFilter.getNextHighestDepth());
			templateFilterLabelClip.m_Text.text = abilitiesInTemplate.length;
            
			if (numOwned >= abilitiesInTemplate.length)
			{
				Colors.ApplyColor(templateFilterClip.m_Background, 0x0E9D00);
				Colors.ApplyColor(templateFilterClip.m_Stroke, 0x00FF00);
			}
			else if (numOwned > 0)
			{
				Colors.ApplyColor(templateFilterClip.m_Background, 0xE28001);
				Colors.ApplyColor(templateFilterClip.m_Stroke, 0xFFFFFF);            
			}
			else
			{
				Colors.ApplyColor(templateFilterClip.m_Background, 0xBF0700);
				Colors.ApplyColor(templateFilterClip.m_Stroke, 0xFFFFFF);
			}
			
			if (canTrain)
			{
				Colors.ApplyColor(templateFilterClip.m_Stroke, 0xFFFF00); 
			}
			
			var filterAngle = (startAngle + angle / 2);
			
			var p:Point = CalculatePointOnCircumference(startPoint, cellClip.m_Radius + cellClip.m_Thickness, filterAngle);
			templateFilterClip._x = p.x;
			templateFilterClip._y = p.y;
			templateFilterClip._rotation = filterAngle - 90;
			p = CalculatePointOnCircumference(startPoint, cellClip.m_Radius + cellClip.m_Thickness + 14, filterAngle);
			templateFilterLabelClip._x = p.x;
			templateFilterLabelClip._y = p.y;
			m_TemplateFilterClips.push(templateFilterClip);
			m_TemplateFilterClips.push(templateFilterLabelClip);
		}
	}

	function DrawSector(parentClip:MovieClip, fillColor:Number, fillAlpha:Number, lineThickness:Number, lineColor:Number, lineAlpha:Number, startPoint:Point, startAngle:Number, endAngle:Number, startDistance:Number, endDistance:Number, useGradient:Boolean)
	{
		var firstOuterPoint:Point = CalculatePointOnCircumference(startPoint, endDistance, startAngle);
		var secondOuterPoint:Point = CalculatePointOnCircumference(startPoint, endDistance, endAngle);
		if (useGradient)
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(endDistance*2, endDistance*2, 0, -500, -500);
			var colors = [0xFFFFFF, 0xFFFFFF,0xFFFFFF, 0xFFFFFF];
			var alphas = [0,0, 10, 0];
			var ratios = [0, 60, 160, 255];
			parentClip.beginGradientFill("radial", colors, alphas, ratios, matrix);
		}
		else
		{
			parentClip.beginFill(fillColor, fillAlpha);
		}
		parentClip.lineStyle(lineThickness, lineColor, lineAlpha);
		var p:Point = CalculatePointOnCircumference(startPoint, startDistance, startAngle);
		parentClip.moveTo(p.x, p.y);
		parentClip.lineTo(firstOuterPoint.x, firstOuterPoint.y);
		parentClip.lineTo(secondOuterPoint.x, secondOuterPoint.y);
		p = CalculatePointOnCircumference(startPoint, startDistance, endAngle);
		parentClip.lineTo(p.x, p.y);
		parentClip.endFill();
	}
	
	
	/** Template Functionality **/
	function GetAbilitiesInTemplate(clusterId:Number, cellId:Number):Array 
	{
		var returnArray:Array = [];
		for( var i:Number = 0; i < m_TemplateFilterArray.length; i++ )
		{
		   if (clusterId == m_TemplateFilterArray[i].cluster && cellId == (m_TemplateFilterArray[i].cell+1))
		   {
			   returnArray.push(m_TemplateFilterArray[i].ability);
		   }
		}
		return returnArray;
	}
	
	function IsFeatInTemplate(featID:Number)
	{
		if (m_TemplateFilterArray != undefined)
		{
			for (var i = 0; i < m_TemplateFilterArray.length; i++)
			{
				if (m_TemplateFilterArray[i].ability == featID)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	/** MOUSE EVENTS **/
	
	function SlotRollOverCluster(cluster:ClusterClip)
	{
		if (!m_IsAnimating && cluster.GetCluster() != undefined && cluster.IsLocked() && cluster.GetCluster().m_DependenyCells != undefined && cluster.GetCluster().m_DependenyCluster != undefined)
		{
			m_ClusterTooltip = MakeClusterTooltip( cluster );
		}
	}
	function SlotRollOutCluster(cluster:ClusterClip)
	{
		if (m_ClusterTooltip != undefined)
		{
			RemoveClusterTooltip();
		}
	}

	function SlotClickCluster(cluster:ClusterClip)
	{
		ZoomTo( cluster );
	}
	
	function SlotClickCell(cell:CellClip)
	{
		SlotCellPressed(cell);
	}

	function SlotRollOutCell(cell:CellClip)
	{
		_global['setTimeout']( Delegate.create( this, CheckRemoveCellTooltip ), 300);
	}

    function SlotRollOverCell(cell:CellClip)
    {
        if (m_HoveredCell == cell) return;
        
        //Make sure cell is not under the tooltip
        if ( (m_CellTooltip == undefined || !m_CellTooltip.hitTest(_root._xmouse, _root._ymouse, true)) )
        {
            if (!m_IsAnimating && !m_ClusterLookup[cell.GetParentClusterID()].IsLocked())
            {
                if (m_HoveredCell != undefined)
                {
                    m_HoveredCell.SetHovered(false);
                }
                
                m_HoveredCell = cell;
                
                //Do not glow if it is selected
                if (m_HoveredCell != m_SelectedCellClip)
                {
                    m_HoveredCell.SetHovered(true);
                }
                OpenCellTooltip();
            }
        }
	}
		
		
	///A slot function that is called whenever a cell in the skillwheel has been clicked
	///@param the cell movieclip that was pressed in the wheel
	public function SlotCellPressed(cellClip:CellClip)
	{
		SelectCell(cellClip);
	}
	
	public function SelectCell(clip:CellClip)
	{
        if (m_SelectedCellClip != undefined && clip != m_SelectedCellClip)
        {
            m_SelectedCellClip.SetSelected(false);
            m_SelectedCellClip.SetHovered(false);
        }
        
		if (clip != undefined && m_SelectedCellClip != clip)
		{
            m_SelectedCellClip = clip;
            
			// Move it to front so glow will be on top of neighbour cells.
			clip.swapDepths( clip._parent.getNextHighestDepth() );
			
			clip.SetSelected(true);
			
			SignalCellSelected.Emit(clip.GetCell());
		}
	}
	
		
	/** CELL/CLUSTER TOOLTIPS **/
	function OpenCellTooltip()
	{
		if (m_HoveredCell != undefined && m_HoveredCell.hitTest(_root._xmouse, _root._ymouse, true))
		{
			// Move it to front so glow will be on top of neighbour cells.
			m_HoveredCell.swapDepths( m_HoveredCell._parent.getNextHighestDepth() );
			
			if (m_CellTooltip != undefined)
			{
				m_CellTooltip.removeMovieClip();
                m_CellTooltip = undefined;
			}
			
			m_CellTooltip = MakeCellTooltip( m_HoveredCell );
		}
	}

	function CheckRemoveCellTooltip()
	{
		if ( this!=undefined && (!m_HoveringTooltip && (m_HoveredCell == undefined || !m_HoveredCell.hitTest(_root._xmouse, _root._ymouse, true)) ) )
		{
			RemoveCellTooltip();
			m_HoveredCell = undefined;
		}
	}
	 
	function RemoveCellTooltip()
	{
		//Do not remove glow if it is selected, as it should have another glow
		if (m_HoveredCell != undefined)
		{
			m_HoveredCell.SetHovered(false);
		}
		m_HoveredCell = undefined;
		
		if (m_CellTooltip != undefined)
		{
			m_CellTooltip.removeMovieClip();
		}
		m_CellTooltip = undefined;
	}

	function RemoveClusterTooltip()
	{
		m_ClusterTooltip.removeMovieClip();
		m_ClusterTooltip = undefined;
		m_DrawClusterTooltip.removeMovieClip();
	}

	function MakeClusterTooltip(clusterClip:ClusterClip):MovieClip
	{
		m_DrawClusterTooltip = this.createEmptyMovieClip("m_DrawClusterTooltip", this.getNextHighestDepth() );
		var clip:MovieClip = this.createEmptyMovieClip( "m_CellTooltip", this.getNextHighestDepth() );
		var start:Number = Math.PI*(clusterClip.m_StartAngle+clusterClip.m_Angle/2)/180;
		var color:Number = 0xffffff;

		// Move clip to center of cell.
		clip._x = Math.floor(Math.sin(start) * clusterClip.m_Radius);
		clip._y = Math.floor( -Math.cos(start) * clusterClip.m_Radius);

		// Make the dot.
		SkillHiveDrawHelper.MakeArch( clip, 2, 360, 4, 0, color, 100, 0, 0x999999, false);

		// Move it a little bit in.
		var x:Number = Math.floor(clip._x * - 0.25);
		var y:Number = Math.floor(clip._y * - 0.15);
		clip.lineStyle( 4, color, 100 );
		clip.moveTo( 0,0);
		clip.lineTo( x, y );
				
		var tooltipClip = clip.attachMovie("SkillhiveClusterTooltip", "m_Tooltip", clip.getNextHighestDepth());
		tooltipClip.m_Title.text = LDBFormat.LDBGetText("SkillhiveGUI", "LockedCluster");
		
		var unlockCellsText:String = LDBFormat.LDBGetText("SkillhiveGUI", "UnlockCluster");
		
		var color:Number = clusterClip.GetColor();
		var neededCells:String = "<font color='#" + color.toString(16) + "'>";
		if (clusterClip.GetCluster().m_DependenyCells != undefined)
		{
			for (var i:Number = 0; i < clusterClip.GetCluster().m_DependenyCells.length; i++)
			{
				neededCells += FindCell(clusterClip.GetCluster().m_DependenyCluster, clusterClip.GetCluster().m_DependenyCells[i]).m_Name;
				
                if (i != clusterClip.GetCluster().m_DependenyCells.length - 1)
				{
					neededCells += ", ";
				}
			}
		}
    
		neededCells += "</font>";
		tooltipClip.m_Text.htmlText = "<font size='12'>" + LDBFormat.Printf(unlockCellsText, neededCells) +"</font>";
		
		var firstCell:CellClip = GetCellClip(clusterClip.GetCluster().m_DependenyCluster, clusterClip.GetCluster().m_DependenyCells[0])
		var lastCell:CellClip = GetCellClip(clusterClip.GetCluster().m_DependenyCluster, clusterClip.GetCluster().m_DependenyCells[clusterClip.GetCluster().m_DependenyCells.length - 1]);
		var cluster:ClusterClip = m_ClusterLookup[clusterClip.GetCluster().m_DependenyCluster];
		
		var startAngle:Number = firstCell.m_StartAngle;
		var angle:Number = (lastCell.m_StartAngle + lastCell.m_Angle) - startAngle;
		var endAngle:Number = lastCell.m_StartAngle + lastCell.m_Angle;
		var startPoint:Point = new Point(0, 0);
		
		m_DrawClusterTooltip.clear();
		m_DrawClusterTooltip.lineStyle(3, cluster.GetColor(), 80);
		var p = CalculatePointOnCircumference(startPoint, firstCell.m_Radius + 2 + 20, startAngle);
		m_DrawClusterTooltip.moveTo(p.x, p.y);
		p = CalculatePointOnCircumference(startPoint, firstCell.m_Radius + 10 + 20, startAngle);
		m_DrawClusterTooltip.lineTo(p.x, p.y);
		p = CalculatePointOnCircumference(startPoint, firstCell.m_Radius + 10 + 20, endAngle);
		m_DrawClusterTooltip.moveTo(p.x, p.y);
		p = CalculatePointOnCircumference(startPoint, firstCell.m_Radius + 2 + 20, endAngle);
		m_DrawClusterTooltip.lineTo(p.x, p.y);
		p = CalculatePointOnCircumference(startPoint, firstCell.m_Radius + 10 + 20 + 2, lastCell.m_StartAngle);
		m_DrawClusterTooltip.moveTo(p.x, p.y);
		p = CalculatePointOnCircumference(startPoint, firstCell.m_Radius + 2 + 20 + 20, lastCell.m_StartAngle);
		m_DrawClusterTooltip.lineTo(p.x, p.y);
		if (angle != NaN)
		{
			SkillHiveDrawHelper.MakeArch( m_DrawClusterTooltip, firstCell.m_Radius + 10 + 20, angle, 3, startAngle, cluster.GetColor(), 90, 0, cluster.GetColor(), false);
		}
		
		tooltipClip._x = x;
		tooltipClip._y = y;
		
		if (tooltipClip._x < 0)
		{
			tooltipClip._x = tooltipClip._x - tooltipClip._width + 10;
		}
		else
		{
			tooltipClip._x -= 10;  
		}
		if (tooltipClip._y < 0)
		{
			tooltipClip._y = tooltipClip._y - tooltipClip._height + 10;
		}
		else
		{
			tooltipClip._y -= 10;
		}
		
		// Shadow.
		var shadow = new DropShadowFilter( 1, 35, 0x000000, 0.7, 6, 6, 2, 1, false, false, false );
		clip.filters = [ shadow ];
		
		clip._xscale = 90;
		clip._yscale = 90;
		
		return clip;
	}

	function MakeCellTooltip( cellClip:CellClip ):MovieClip
	{
		var clip:MovieClip = this.createEmptyMovieClip( "m_CellTooltip", this.getNextHighestDepth() );
		var start:Number = Math.PI*(cellClip.m_StartAngle+cellClip.m_Angle/2)/180;
		var color:Number = 0xffffff;

		// Move clip to center of cell.
		clip._x = Math.floor(Math.sin(start) * cellClip.m_Radius);
		clip._y = Math.floor( -Math.cos(start) * cellClip.m_Radius);

		// Make the dot.
		SkillHiveDrawHelper.MakeArch( clip, 2, 360, 4, 0, color, 100, 0, 0x999999, false);

		// Move it a little bit in.
		var x:Number = Math.floor(clip._x*-0.25);
		var y:Number = Math.floor(clip._y*-0.15);
		clip.lineStyle( 4, color, 100 );
		clip.moveTo( 0,0);
		clip.lineTo( x, y );
		
		var tooltipClip:MovieClip = clip.attachMovie("SkillhiveCellTooltip", "i_Tooltip", clip.getNextHighestDepth());
		tooltipClip.SetName(cellClip.GetCell().m_Name);
		
		
		tooltipClip._x = x;
		tooltipClip._y = y;
		
		if (tooltipClip._x < 0)
		{
			tooltipClip._x = tooltipClip._x - tooltipClip._width + 10;
		}
		else
		{
			tooltipClip._x -= 10;  
		}
		if (tooltipClip._y < 0)
		{
			tooltipClip._y = tooltipClip._y - tooltipClip._height + 10;
		}
		else
		{
			tooltipClip._y -= 10;
		}
	  
		// The abilities.
		var cell:Cell = cellClip.GetCell();
		if (cell.m_Abilities != undefined)
		{
			for( var idx=0; idx!=cell.m_Abilities.length; idx++ )
			{
				var abilityId:Number = cell.m_Abilities[idx];
				var feat:FeatData = FeatInterface.m_FeatList[abilityId];
				if (feat != undefined)
				{
					tooltipClip.SetAbility(feat, idx, IsFeatInTemplate(abilityId));// idx, feat.m_Name, filterName, symbolName, feat.m_Spell);
				}
				else
				{
					Log.Error("SkillHive", "Trying to add unknown feat to tooltip: " + abilityId);
				} 
			}
		}
		
		clip.onRollOver = Delegate.create(this, onRollOverTooltip);
		clip.onRollOut = Delegate.create(this, onRollOutTooltip);
        clip.onPress = Delegate.create(this, onPressTooltip);
        tooltipClip.SignalAbilityPressed.Connect(SlotTooltipAbilityPressed, this)
		
		// Shadow.
		var shadow = new DropShadowFilter( 1, 35, 0x000000, 0.7, 6, 6, 2, 1, false, false, false );
		clip.filters = [ shadow ];
			
		clip._xscale = 90;
		clip._yscale = 90;
		
		return clip;
	}

    function onRollOverTooltip():Void
    {
        m_HoveringTooltip = true;
    }
    
    function onRollOutTooltip():Void
    {
        m_HoveringTooltip = false;
        _global['setTimeout']( Delegate.create( this, CheckRemoveCellTooltip), 300);
    }
    
    function onPressTooltip():Void
    {
        SlotCellPressed(m_HoveredCell);
    }
    
	function SlotTooltipAbilityPressed(abilityIndex:Number)
	{
		//Select the hovered cell and the pressed ability
		SlotCellPressed(m_HoveredCell);
		SignalCellAbilitySelected.Emit(abilityIndex);
	}
	
	/** COMPLETION/SKILLPOINTS **/

	function CalculateNumAbilities()
	{
		var numAbilities:Number = 0;
		var numAbilities:Number = 0;
		for( var cat in m_StartClusterList )
		{
			numAbilities += GetNumClusterAbilities( Number(m_StartClusterList[cat].clusterId));
		}
		
		m_NumAbilities = numAbilities;
	}

	function GetNumClusterAbilities(clusterID:Number) :Number
	{
		var cluster:Cluster = FindCluster(clusterID);
		var numAbilities:Number = 0;
		
		// If it has subclusters, calculate these
		if( cluster.m_Clusters )
		{
			for( var i=0; i!= cluster.m_Clusters.length; i++ )
			{
			  numAbilities += GetNumClusterAbilities(cluster.m_Clusters[i]);
			}
		}
		if( cluster.m_Cells )
		{
			var completion:Number = 0;
			for( var i:Number = 0; i < cluster.m_Cells.length; i++ )
			{
			   numAbilities += cluster.m_Cells[i].m_Abilities.length;
			}
		}
		return numAbilities; 
	}
	
	function CalculateCompletion()
	{
		m_TrainedAbilities = 0;
		for( var cat in m_StartClusterList )
		{
			CalculateClusterCompletion( Number(m_StartClusterList[cat].clusterId));
			m_TrainedAbilities += FindCluster(Number(m_StartClusterList[cat].clusterId)).m_TrainedAbilities;
		}
	}

	function CalculateCellCompletion(cell:Cell):Number
	{
		if (cell != undefined)
		{
			var numPowers:Number = cell.m_Abilities.length;
			var completed:Number = 0;
			for (var i:Number = 0; i < numPowers; i++)
			{
				var feat:FeatData = FeatInterface.m_FeatList[cell.m_Abilities[i]];
				if (feat != undefined)
				{
					if (feat.m_Trained) completed++;
				}
			}
			cell.m_TrainedAbilities = completed;
			cell.m_Completion = completed / numPowers;
			return cell.m_Completion;
		}
		return 0;
	}

	function CalculateClusterCompletion(clusterID:Number)
	{
		var cluster:Cluster = FindCluster(clusterID);
		var numAbilities:Number = 0;
		
		// If it has subclusters, calculate these
		if( cluster.m_Clusters )
		{
			for( var i=0; i!= cluster.m_Clusters.length; i++ )
			{
			  CalculateClusterCompletion(cluster.m_Clusters[i]);
			  numAbilities += FindCluster(cluster.m_Clusters[i]).m_TrainedAbilities;
			}
		}
		
		var clusterCompletion = 0;
		if( cluster.m_Cells )
		{
			var completion:Number = 0;
			for( var i:Number = 0; i < cluster.m_Cells.length; i++ )
			{
			   completion += CalculateCellCompletion(cluster.m_Cells[i]);
			   numAbilities += cluster.m_Cells[i].m_TrainedAbilities;
			}
			clusterCompletion = completion / cluster.m_Cells.length;
		}
		cluster.m_TrainedAbilities = numAbilities
		cluster.m_Completion = clusterCompletion;
	}
	
	/** ANIMATION FUNCTIONALITY **/
	function AnimateWheel()
	{
		if (m_IsInitialized)
		{
			 // Animate the whole thing.
			if( m_AnimatedCluster != undefined && m_IsAnimating)
			{
				if (m_ClusterTooltip != undefined)
				{
					RemoveClusterTooltip();
				}
				// Stop animation if done.
				var clusterClip:MovieClip = m_AnimatedCluster;
				if( m_AnimationClip.m_ZoomPos >= 1 || m_AnimationClip.m_ZoomPos <= 0 )
				{
					m_AnimationClip.m_ZoomPos = Math.round( m_AnimationClip.m_ZoomPos );
					m_AnimatedCluster = undefined;
					m_IsAnimating = false;
					DrawBackground();
					DrawTemplates();
					m_WheelBackground.tweenTo(1.0, { _alpha:100 }, Regular.easeOut);
				}
				// TODO: Move this into Draw
				// Update the animating values based on m_AnimationClip.m_ZoomPos.
				var last:MovieClip = m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1];
				clusterClip.m_Angle = last.angle + (360-last.angle) * m_AnimationClip.m_ZoomPos;
				clusterClip.m_StartAngle = last.startAngle - (clusterClip.m_Angle-last.angle)/2;
				clusterClip.m_Radius = (last.startRadius + ((m_RingInnerRadius - last.startRadius) * m_AnimationClip.m_ZoomPos));

				clusterClip.Draw();

				if( m_AnimationClip.m_ZoomPos <= 0 )
				{
					m_ZoomedClusterStack.pop();
					SignalAnimateWheel.Emit();
				}
			}
		}
	}

	function ZoomOut()
	{
		if (m_ZoomedClusterStack.length > 0)
		{
			ZoomTo(m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster);
		}
	}
	
	public function ZoomToCluster(clusterClip:ClusterClip)
	{
		if (!m_IsAnimating)
		{
			if (clusterClip == undefined)
			{
				if (m_ZoomedClusterStack.length > 0)
				{
					//Zooming out to main
					m_ZoomedClusterStack.splice(0, m_ZoomedClusterStack.length - 1);
					SnapToCluster(undefined);
					ZoomTo(m_ZoomedClusterStack[m_ZoomedClusterStack.length -1].cluster);
				}
				return;
			}
			if (clusterClip != m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster)
			{
				m_ZoomedClusterStack.splice(0, m_ZoomedClusterStack.length - 1, { cluster:clusterClip, angle:clusterClip.m_Angle, radius:clusterClip.m_Radius, startAngle:clusterClip.m_StartAngle, startRadius:clusterClip.m_Radius });
				SnapToCluster(clusterClip);
				ZoomTo(m_ZoomedClusterStack[m_ZoomedClusterStack.length -1].cluster);
				return;
			}
		}
	}

	function ZoomTo( clusterClip:ClusterClip )
	{
		//If we are already zooming, do nothing
		if( m_IsAnimating )
		{
			return;
		}
		m_AnimatedCluster = clusterClip;
		
		var newMainCluster:MovieClip = clusterClip;
		var zoomingToMain:Boolean = false;
		
		// If there is something on the stack and that is the same as new clusterClip, then we go back. Else we put it on the stack and move inward.
		if( (m_ZoomedClusterStack.length == 0 || m_ZoomedClusterStack[m_ZoomedClusterStack.length-1].cluster != clusterClip ))
		{
			// Tween the zoomer. This will be used in oneenterframe.
			m_AnimationClip.m_ZoomPos = 0.0001;
			m_AnimationClip.tweenTo( 1, { m_ZoomPos:1 }, Regular.easeOut);
			
			// Put on stack.
			m_ZoomedClusterStack.push( { cluster:clusterClip, angle:clusterClip.m_Angle, radius:clusterClip.m_Radius, startAngle:clusterClip.m_StartAngle, startRadius:clusterClip.m_Radius } );
			SignalAnimateWheel.Emit();
		}
		else
		{
			// Move back out.
			m_AnimationClip.m_ZoomPos = 0.999;
			m_AnimationClip.tweenTo( 1, { m_ZoomPos:0 }, Regular.easeOut);
			
			if (m_ZoomedClusterStack[m_ZoomedClusterStack.length-2] != undefined)
			{
				newMainCluster = m_ZoomedClusterStack[m_ZoomedClusterStack.length-2].cluster;
			}
			else
			{
				zoomingToMain = true;
			}
			
		}
		
		//Shared functionality
		m_IsAnimating = true;
		RemoveCellTooltip();
		
		m_Character.AddEffectPackage( "sound_fxpackage_GUI_power_wheel_movement.xml" );
		
		//Tween the background (with templates and lines) out while animating
		m_WheelBackground.tweenTo(0.5, { _alpha:0 }, Regular.easeOut);
		
		// Go through all the clusters and decide if they should be shown or not
		// Also update the leaf and parentcluster list
		m_ParentClusterIdArray = [];
		m_LeafClusterIdArray = [];

		for (var prop in m_ClusterLookup)
		{
			var clip:MovieClip = m_ClusterLookup[prop];
			
			if(!IsInFamily(clip, newMainCluster) && !zoomingToMain)
			{
				if (clip._visible)
				{
					//This cluster should not be shown
					clip.tweenTo( 0.5, { _alpha:0 }, Regular.easeOut);
							
					clip.onTweenComplete = function()
					{
						this._visible = false;
					}
				}
			}
			else
			{
				//This cluster should be shown
				if (clip.m_Cluster.m_Clusters == undefined && clip.m_Cluster.m_Id != 2001 && clip.m_Cluster.m_Id != 2002 && clip.m_Cluster.m_Id != 2003)
				{
					//This is a leafcluster
					m_LeafClusterIdArray.push(clip.m_Cluster.m_Id);
				}
				else
				{
					//This is a parentcluster
					m_ParentClusterIdArray.push(clip.m_Cluster.m_Id);
				}
				
				if(!clip._visible)
				{
					clip._visible = true;
					clip.tweenTo( 2.5, { _alpha:clip.m_Alpha }, Regular.easeOut);
					clip.onTweenComplete = undefined;
				}
			}
		}
	}

	//If we want to jump several steps up, we need to snap to that state before starting the animation
	function SnapToCluster(clusterClip:MovieClip)
	{
		if (clusterClip != undefined)
		{
			SnapCluster(clusterClip, 0, 360, m_RingInnerRadius);
		}
		else
		{
			for( var cat in m_StartClusterList)
			{
				var data = m_StartClusterList[cat];
				SnapCluster(m_ClusterLookup[data.clusterId], data.startAngle, data.angle, data.radius );
			}
		}
	}

	function SnapCluster(clusterClip:MovieClip, startAngle:Number, angle:Number, radius:Number)
	{
		//Do not snap the one animating
		if (clusterClip == m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].cluster)
		{        
			m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].startAngle = startAngle;
			m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].angle = angle;
			m_ZoomedClusterStack[m_ZoomedClusterStack.length - 1].radius = radius;
			return;
		}
		clusterClip.m_StartAngle = startAngle;
		clusterClip.m_Angle = angle;
		clusterClip.m_Radius = radius;
		clusterClip.Draw();
		
		if( clusterClip.m_Cluster.m_Clusters != undefined )
		{
			var subAngle:Number = angle/clusterClip.m_Cluster.m_Clusters.length;
			for( var i=0; i< clusterClip.m_Cluster.m_Clusters.length; i++ )
			{
				SnapCluster(m_ClusterLookup[clusterClip.m_Cluster.m_Clusters[i]], startAngle + (i * subAngle), subAngle, radius + 15 + 60);
			}
		}
	}

	function IsInFamily(childCluster:MovieClip, parentCluster:MovieClip):Boolean
	{
		if (childCluster == parentCluster)
		{
			return true;
		}
		var newParent:MovieClip = childCluster.m_ParentCluster
		while (newParent != undefined)
		{
			if (newParent == parentCluster)
			{
				return true;
			}
			newParent = newParent.m_ParentCluster;
		}
		
		return false;
	}
}