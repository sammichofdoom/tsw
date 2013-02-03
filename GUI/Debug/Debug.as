
class GUI.Debug.Debug
{
  static public var m_Instance:Number = 0;

  /// Loads a new instance of a debug window.
  static function OpenDebugWindow()
  {
      trace(m_Instance++);
      _root.LoadFlash( "DebugWindow.swf", "DebugWindow_" + m_Instance++, false, _global.Enums.ViewLayer.e_ViewLayerTooltip, 0 );
  }


  /// Trace an object from chatline.
  /// Ex.1  /aseval com.Utils.Debug.TraceObject _root 6 movieclip
  /// This will show all movieclips and their childs down to a depth of 6. Will show movieclip x,y,w,h,vis,alp.
  /// Ex.2  /aseval com.Utils.Debug.TraceObject _global.Game.Quests.m_PlayerTiers 2
  /// Will show 2 layers of the playertiers objects.
  ///
  /// path   - Full path to the object.
  /// depth  - Number of depths to show.
  /// type   - "movieclip" or nothing.
  static function TraceObject( path:String, depth:Number, type:String )
  {
    if( !depth )
    {
      depth = 1;
    }
    trace( path + ":");
    RecurseObject( path, eval(path), depth, type );
  }

  /// Use TraceObject(..) if you can.
  /// Recurse an object to show all it's properties.
  /// Internal function, but can be used when debugging code if you don't have the full path to the object and TraceObject can't be used.
  ///
  /// path   - Full path to the object.
  /// depth  - Number of depths to show.
  /// type   - "movieclip" or nothing.
  static function RecurseObject( name:String, root:Object, depth:Number, type:String )
  {
    ////_global.ASSetPropFlags(root,null,6,true);   // For showing functions as well.
    //_global.ASSetPropFlags(root,null,0,1);

    var value = root;
    if( typeof( root ) == "movieclip" )
    {
      value = "MovieClip x:"+root._x +" y:"+root._y+" w:"+root._width +" h:"+root._height+" vis:"+root._visible+" alp:"+root._alpha+" rot:"+root._rotation;
    }
    else if( typeof( root ) == "string" )
    {
      value = "\""+ value + "\"";
    }
    trace( name + " = " + value );

    if( depth > 0 )
    {
      for( var prop in root)
      {
        if( prop != "__proto__" && prop != "__constructor__" && prop != "constructor" && prop != "m_SignalGroup" )
        {
          var obj = root[prop];
          var newname;
          if ( typeof( obj ) == "Array" )
          {
            newname = name +"["+ prop + "]";
          }
          else
          {
            newname = name + "." + prop;
          }

          if( !type || (type == "movieclip" && typeof( obj ) == "movieclip") )
          {
            RecurseObject( newname, obj, depth-1, type );
          }
        }
      }
    }
  }



  /// Checks what object the mouse is currently over and traces it's full path.
  ///
  static function TraceHitTest()
  {
    RecurseHitTest( "_root", _root );
  }

  /// Use TraceObject(..) if you can.
  /// Recurse an object to show all it's properties.
  /// Internal function, but can be used when debugging code if you don't have the full path to the object and TraceObject can't be used.
  ///
  /// name   - The name of the object.
  /// root   - The object
  static function RecurseHitTest( name:String, root:Object )
  {
    if( typeof( root ) == "movieclip" )
    {
      var hit = root.hitTest( _root._xmouse, _root._ymouse, false );
      if( hit )
      {
        var value = "MovieClip x:"+root._x +" y:"+root._y+" w:"+root._width +" h:"+root._height+" vis:"+root._visible+" alp:"+root._alpha+" rot:"+root._rotation;
        trace( name + " = " + value );
      }

      for( var prop in root)
      {
        var obj = root[prop];
        if( typeof( obj ) == "movieclip" )
        {
          var newname = name + "." + prop;
          RecurseHitTest( newname, obj );
        }
      }
    }
  }


}