
MovieClip.prototype.Box = function(x,y,w,h,c,a)
{
  this.beginFill( c, a );
  this.moveTo( x,y)
  this.lineTo( x+w, y );
  this.lineTo( x+w, y+h  );
  this.lineTo( x, y+h );
  this.endFill();
}

MovieClip.prototype.BoxAll = function(c,a)
{
  this.Box(0,0,this._width,this._height,c,a);
}

instance = 0;
Init()

function Init()
{
  this.m_ShowClips = true;
  this.m_ShowVariables = true;
  this.m_ShowFunctions = true;
  this.m_ShowProperties = true;
  this.m_Scroll = 0;  // Defines the top line to print of the childs.
  this.m_ShowRoot = true;
  this.m_RootSelfName = "_root";
  this.m_GlobalSelfName = "_global";

  m_Style = new TextFormat;
  m_Style.font = "_StandardFont";
  m_Style.size = 11;
  m_Style.color = 0x0;

  m_Frame = 0;
  m_UpdateOnFrame = 10;


  // Create the drag button / border. It can't be this as that will stop any button events from going to the childs..
  var border = createEmptyMovieClip( "border", getNextHighestDepth() );

  var that = this;
  border.onPress = function()
  {
    // This shit is weird. If I use 'this', then it refers to the border, but if I use nothing, it refers to this for this .as .
    startDrag( that );
  }

  border.onRelease = border.onReleaseOutside = function()
  {
    stopDrag();
  }

  onEnterFrame = function()
  {
    m_Frame++;
  }

  border.onEnterFrame = function()
  {
    // Resize every frame based on parent.
    this.clear();
    this.Box(0,0,_width+20,_height+20,0x7777ff, Key.isDown( Key.SHIFT) ? 100 : 30 )
  }

  onMouseWheel = function(delta)
  {
    m_Scroll -= delta;
    ShowTarget( m_SelfName, m_Scroll );
  }
  Mouse.addListener(this);



  // Add global/root button.
  var clip = createEmptyMovieClip( "rootButton", getNextHighestDepth() );
  clip._x = 15;
  clip._y = 5;

  clip.createTextField("label", clip.getNextHighestDepth(), 0, 0, 0, 0);
  clip.label.setNewTextFormat(m_Style);
  clip.label.autoSize = "left";
  clip.label.text = "_root/_global";

  clip.onRelease = function()
  {
    m_ShowRoot = !m_ShowRoot;
    ShowTarget( (m_ShowRoot ? m_RootSelfName : m_GlobalSelfName), 0 );
  }

  clip.onEnterFrame = function()
  {
    // Hightlight button if over.
    this.clear();
    this.BoxAll( 0xffffff, (this.hitTest( _root._xmouse, _root._ymouse, false) ? 60 : 20 ) )
  }


  // Add close button.
  clip = createEmptyMovieClip( "closeButton", getNextHighestDepth() );
  clip._x = 15+ 190;
  clip._y = 5;

  clip.createTextField("label", clip.getNextHighestDepth(), 0, 0, 0, 0);
  clip.label.setNewTextFormat(m_Style);
  clip.label.autoSize = "left";
  clip.label.text = "Close";

  clip.onRelease = function()
  {
    // Delete all.
    _root.UnloadFlash( _name )
  }

  clip.onEnterFrame = function()
  {
    // Hightlight button if over.
    this.clear();
    this.BoxAll( 0xffffff, (this.hitTest( _root._xmouse, _root._ymouse, false) ? 60 : 20 ) )
  }


  ShowTarget( "_root", 0 );
}


function ResizeHandler( w, h ,x, y )
{
  var visibleRect = Stage["visibleRect"];
  _x = visibleRect.x + 420;
  _y = visibleRect.y + 60;
}

function onUnload()
{
  RemoveDebugframe();
}

function RemoveDebugframe()
{
  if( _root.debugFrame )
  {
    _root.debugFrame.removeMovieClip();
  }
}

function EvalVariable( path:String )
{
  // Eval() fails for some names so I made this function.
  // Walk the path until it finds the variable.
  var names = path.split(".");
  var variable;
  for( var i=0; i!=names.length; i++ )
  {
    variable = (variable ? variable[names[i]] : eval(names[i]) )
  }
  return variable;
}


function ShowTarget( selfName, scroll )
{
  m_Editing = false;
  RemoveDebugframe();

  if( selfName )
  {
    m_SelfName = selfName;
    m_ShowRoot ? (m_RootSelfName=m_SelfName) : (m_GlobalSelfName=m_SelfName);
    var self = EvalVariable( selfName );

    // Remove all existing buttons.
    container.removeMovieClip()
    instance = 0;

    // First add self with parent as target. Button goes backawards.
    AddButton( self, selfName, selfName.substring( 0,selfName.lastIndexOf(".") ) );

    // Then add all childs.
    var list = GetChildNames( self );
    list = SortChilds( self, list )
    m_Scroll = scroll;
    if( m_Scroll > list.length - 16 )
    {
      m_Scroll = list.length - 16;
    }
    if( m_Scroll < 0 )
    {
      m_Scroll = 0;
    }

    for( var idx=m_Scroll; idx != m_Scroll+16 && idx != list.length; idx++ )
    {
      var name = list[idx];
      var variable = self[name];
      // Self and target is the same. Button goes forward.
      AddButton( variable, selfName+"."+name, selfName+"."+name );
    }
  }
}

function GetChildNames( variable )
{
  // Return a list of childs. Sort them as well.
  // Sort order: movieclip, objects, (props/vars), func
  var list = [];
  if( m_ShowProperties && (typeof(variable) == "movieclip" || variable.textWidth != undefined))
  {
    list = ["_x","_y","_z","_width","_height","_alpha","_xscale","_yscale","_visible","_rotation","_xrotation","_yrotation","_xmouse","_ymouse","_currentframe","_totalframes","_name"];
  }
  for( var child in variable )
  {
    if( /*VariableShown( variable[child] ) &&*/ variable[child] != _root.debugFrame )
    {
      list.push( child );
    }
  }
  return list;
}

function SortChilds( variable, list )
{
  // Sort it.
  var final = []
  var order = [ ["movieclip"] , ["object"] , ["string","number","boolean"], ["function"] ];
  for( var i=0; i!=order.length; i++ )
  {
    var temp = [];
    for( child in list )
    {
      for( var n=0; n!=order[i].length; n++ )
      {
        if( typeof(variable[list[child]]) == order[i][n] )
        {
          temp.push( list[child] )
          break;
        }
      }
    }
    temp.sort();
    final = final.concat( temp );
  }

  return final;
}

// not used anymore as it was not needed and needed to optimize.
function VariableShown( variable ) : Boolean
{
  switch( typeof(variable) )
  {
    case "function":
      return m_ShowFunctions;
    case "movieclip":
      return m_ShowClips;
    case "number":
    case "string":
    case "boolean":
    case "object":
      return m_ShowVariables;
  }
  // Let anything else be shown.
  return true
}

function AddButton( self, selfName, targetName )
{
  m_Frame = 0;

  if( !container )
  {
    createEmptyMovieClip( "container", getNextHighestDepth() );
  }

  var clip = container.createEmptyMovieClip( ""+instance++, container.getNextHighestDepth() );

  clip.createTextField("label", clip.getNextHighestDepth(), 0, 0, 0, 0);
  clip.label.setNewTextFormat(m_Style);
  clip.label.autoSize = "left";


  // If this is a editable type, we show a edit field.
  var res = EvalVariable( targetName )

  // Values of string, number and bools can be changed.
  var resType = typeof(res);
  if( resType == "number" || resType == "string" || resType == "boolean" )
  {
    var names = targetName.split(".");
    var variable;
    for( var i=0; i!=names.length; i++ )
    {
      var last = variable;
      variable = (variable ? variable[names[i]] : eval(names[i]) )
    }
    --i;

    // Create value field and handle editing.
    clip.createTextField("value", clip.getNextHighestDepth(), 0, 0, 0, 0);
    clip.value.setNewTextFormat(m_Style);
    clip.value._width = resType=="string" ? 300 : 100;
    clip.value._height = 18;
    clip.value.type = "input";
    clip.value.border = true;

    clip.value.onKeyDown = function()
    {
      if( Key.getCode() == Key.ENTER )
      {
        Selection.setFocus(null)
      }
      else if( Key.getCode() == Key.ESCAPE )
      {
        // Cancel input.
        this.text = this.m_oldText;
        Selection.setFocus(null)
      }
    }

    clip.value.onSetFocus = function( old )
    {
      m_Editing = true;
      this.m_oldText = this.text;
      Key.addListener( this );
    }

    clip.value.onKillFocus = function()
    {
      m_Editing = false;
      Key.removeListener( this );
      if( resType == "boolean" )
      {
        if( this.text == "true" )
          last[names[i]] = true;
        else if( this.text == "false" )
          last[names[i]] = false;
      }
      else
      {
        last[names[i]] = this.text;
      }
    }

  }
  else
  {
    // Not a editable value.
    clip.onRollOver = function()
    {
      m_Frame = 0; // Make it update;
      this.over = true;
      _root.createEmptyMovieClip( "debugFrame", _root.getNextHighestDepth() );
    }

    clip.onRollOut = function()
    {
      this.over = false;
      RemoveDebugframe();
    }

    clip.onReleaseOutside = function()
    {
      this.onRollOut();
    }

    clip.onRelease = function()
    {
      this.onRollOut();
      // Don't show childs if this has a editable value field.
      ShowTarget( targetName, 0 );
    }
  }

  clip.onEnterFrame = function()
  {
    if( m_Frame % m_UpdateOnFrame != 0 && !this.over )
    {
      return;
    }

    // Update content every frame.
    var list = GetChildNames( self );
    var childs = list.length;

    if( m_Editing )
      return

    if( typeof(self) == "movieclip" )
    {
      // For movieclips we show more info and display a transparant box of the area.
      var text = "+"+childs+" "
      text += selfName;
      if( self )
      {
        text += " _x=" + self._x
        text += " _y=" + self._y
        text += " _width=" + self._width
        text += " _height=" + self._height
        if( self._alpha != 100 )
          text += " _alpha=" + self._alpha
        if( self._xscale != 100 )
          text += " _xscale=" + self._xscale
        if( self._yscale != 100 )
          text += " _yscale=" + self._yscale
        if( !self._visible )
          text += " vis=" + self._visible
        text += " depth=" + self.getDepth()
        
        var bounds = self.getBounds(self);
        text += " bminx=" + bounds.xMin;
        text += " bminy=" + bounds.yMin;
        text += " bmaxx=" + bounds.xMax;
        text += " bmaxy=" + bounds.yMax;
        
      }
      else
      {
        text += " (DELETED)"
        var deleted = true;
      }
      this.label.text = text

      if( this.over )
      {
        RemoveDebugframe();
        if( !deleted )
        {
          // Had a lot of trouble getting this to work so I had to do it all from 'scratch'.
          // This replicates the whole tree structure with positions, scale and rotations of all entries.
          // The box had to be drawn using the bounds as some things have negative positions within the movieclip.

          // Find all the parents, then build the same structure from the bottom and up.
          var entry = self;
          var arr = new Array()
          while( entry != _root )
          {
            arr.push( entry )
            entry = entry._parent;
          }
          arr.reverse()

          var tt = _root;
          for( var n=0; n!= arr.length; n++ )
          {
            tt.createEmptyMovieClip( "debugFrame", tt.getNextHighestDepth() );
            tt.debugFrame._x = arr[n]._x;
            tt.debugFrame._y = arr[n]._y;
            tt.debugFrame._xscale = arr[n]._xscale;
            tt.debugFrame._yscale = arr[n]._yscale;
            tt.debugFrame._rotation = arr[n]._rotation;
            tt = tt.debugFrame;
          }

          if( tt != _root )
          {
            var bounds = self.getBounds(self);
            tt.Box( bounds.xMin, bounds.yMin, bounds.xMax - bounds.xMin, bounds.yMax - bounds.yMin, self._visible ? 0xffffff : 0xff0000,30)

            // Draw axis on top.
            tt.lineStyle( 1, 0xFF8888, 100, true, "none","none" );
            tt.moveTo( -100, 0 );
            tt.lineTo( 100, 0 );
            tt.moveTo( 0, -100 );
            tt.lineTo( 0, 100 );
          }
        }
      }
    }
    else
    {
      // Recheck the value each frame. Must fetch it as self is not a pointer for pod types.
      var value = EvalVariable( selfName )

      if( this.value )
      {
        this.label.text = selfName + " = ";
        this.value._x = this.label._width;
        this.value.text = value;
      }
      else
      {
      // Only objects and textfields get here.
        this.label.text = "+" + childs + " " + selfName + " = " + resType;
      }
    }

    // Hightlight button if over.
    this.clear();
    this.BoxAll( 0xffffff, (this.over ? 60 : 20 ) )

    // Position based on numerical name.
    this._x = (this._name==0 ? 10 : 15)
    this._y = 30 + (this._name*20)

  }

  clip.onEnterFrame();
}
