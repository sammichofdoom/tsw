import com.Utils.Signal;
import com.GameInterface.MathLib.Vector3;

intrinsic class com.GameInterface.Game.Camera
{
  /// These static variables are updated every 0.5 sec with info about cameras current posistion and rotation.
  /// NOTE: You must first call RequestCameraPosRotUpdates( true ) once to start the timer.
  public static var m_Pos:Vector3;
  /// The cameras angle around the y axis. In radians.
  public static var m_AngleY;

  /// The height of one black part of the cinematic letterbox. This number is always up to date.
  public static var m_CinematicStripHeight;

  /// Signal send when cinematic is started or ended.
  /// @param activated:Number       1 if started, 0 if ended.
  public static var SignalCinematicActivated:Signal; // -> OnCinematicActivated( activated:Number )
  
  /// Runs a camerapath.
  /// @param pathName:String                     Path to play.
  /// @param switchToDefaultCamWhenDone:Boolean  Set camera back?
  /// @param initialPosition:Number              Start pos on the path.
  /// @param targetPosition:Number               End pos on the path.
  public static function RunCameraPath( pathName:String, switchToDefaultCamWhenDone:Boolean, initialPosition:Number, targetPosition:Number ) : Void;

  /// Place the cinematic camera at a position looking at something.
  /// @param posX:Number      The new position of the camera in world coordinates.
  /// @param offsetX:Number   The position to look at in world coordinates.
  public static function PlaceCamera( posX:Number, posY:Number, posZ:Number, offsetX:Number, offsetY:Number, offsetZ:Number, upX:Number, upY:Number, upZ:Number ) : Void;

  /// Set field of view for the cinematic camera.
  /// @param fov:Number      The fov. Hopefully reset everytime a new cinematic is started.
  public static function SetFOV( fov:Number ) : Void;

  /// Tell gamecode to start filling m_Pos and m_AngleY every interval.
  /// @param startUpdates:Boolean      True to start it, false to end it.
  public static function RequestCameraPosRotUpdates( startUpdates:Boolean ) : Void;
  
  /// Get the zoom position of the camera
  public static function GetZoom( ) : Number;

}
