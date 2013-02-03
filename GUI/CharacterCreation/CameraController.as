import com.GameInterface.MathLib.Vector3;
import com.GameInterface.Game.Camera;
import com.GameInterface.Game.Character;
import com.GameInterface.CharacterCreation.CharacterCreation;
import com.Utils.Interpolator;
import mx.transitions.easing.*;

class GUI.CharacterCreation.CameraController
{
    public static var e_ModeBody = 0;
    public static var e_ModeFace = 1;
    public static var e_ModeTop  = 2;
    public static var e_ModeLegs = 3;
    public static var e_ModeFeet = 4;

    public function CameraController( startZoomMode:Number )
    {
        m_CameraHeight   = new Interpolator;
        m_CameraDistance = new Interpolator;

        m_IsAnimating = false;
        m_IsInteractive = false;
        m_LockPosUpdate = false;

        m_AnimStartTime = getTimer() / 1000;
        m_AnimEndTime   = m_AnimStartTime;

        m_CameraHeight.Start( 0, 0.3, 0.3 );
        m_CameraDistance.Start( 0.5, 0.5, 0 );

        m_CameraMinDistance = 0.5;
        m_CameraMaxDistance = 2.5;


        m_TargetHeadPos   = new Vector3( 0, 0, 0 );
        m_TargetGroundPos = new Vector3( 0, 0, 0 );

        SetZoomMode( startZoomMode );
    }

    public function SetCameraPosition( pos:Vector3 ) : Void
    {
        m_CameraPosition = pos;
    }

    public function SetLockPosUpdate(val:Boolean):Void
    {
        m_LockPosUpdate = val;
    }
    
    public function UpdateTargetPositions( character:Character ) : Void
    {
        if(!m_LockPosUpdate)
        {
            var targetHeadPos = character.GetPosition( _global.Enums.AttractorPlace.e_Ground );//character.GetPosition( _global.Enums.AttractorPlace.e_Head);
            var targetGroundPos = character.GetPosition( _global.Enums.AttractorPlace.e_Ground );
            
            if ( targetHeadPos.y - targetGroundPos.y < 0.5 )
            {
                targetHeadPos.y = targetGroundPos.y + 1.9;
            }
            if ( targetHeadPos != m_TargetHeadPos || targetGroundPos != m_TargetGroundPos )
            {
                m_TargetHeadPos   = targetHeadPos;
                m_TargetGroundPos = targetGroundPos;

            }
        }
    }
    
    public function SetZoomMode( mode:Number, animTime:Number ) : Void
    {
        var height:Number = 0.5;
        var zoom:Number = 0.5;
        switch( mode )
        {
          case e_ModeFace:
              height = 0.7;
              zoom   = 0.15;
              break;
          case e_ModeTop:
              height = 0.5;
              zoom   = 0.5;
              break;
          case e_ModeBody:
              height = 0.4;
              zoom   = 0.8;
              break;
          case e_ModeLegs:
              height = 0.2;
              zoom   = 0.4;
              break;
          case e_ModeFeet:
              height = 0.1;
              zoom   = 0.3;
              break;
        }
        m_CameraHeight.SetEndValue( 0.3, height );
        m_CameraDistance.SetEndValue( 0.3, zoom );
    }

    public function SetCameraHeight( height:Number ) : Void
    {
        if(!m_LockPosUpdate)
        {
            m_CameraHeight.SetEndValue( 0.05, Math.max( 0, Math.min( 1, height ) ) );
        }
    }

    public function GetCameraHeight() : Number
    {
        return m_CameraHeight.GetEndValue();
    }
    

    function PlaceCamera( camPos:Vector3, targetPos:Vector3, up:Vector3 )
    {
        if(!m_LockPosUpdate)
        {
            if (up == undefined)
            {
                up = new Vector3(0,1,0);
            }
            Camera.PlaceCamera( camPos.x, camPos.y, camPos.z, targetPos.x, targetPos.y, targetPos.z, up.x, up.y, up.z );
            Camera.SetFOV( 60 * 2 * Math.PI / 360 /*fov*/ );
        }
    }

    public function FrameProcess()
    {
        var curTime:Number = getTimer() / 1000;
        var cameraDirection:Vector3 = Vector3.Sub( m_CameraPosition, m_TargetGroundPos );
        var cameraAngle:Number      = Math.atan2( cameraDirection.z, cameraDirection.x );
            
        var cameraHeight:Number   = m_CameraHeight.GetTimeValue( curTime );
        var zoomLevel:Number      = m_CameraDistance.GetTimeValue( curTime );
        var cameraDistance:Number = m_CameraMinDistance + (m_CameraMaxDistance - m_CameraMinDistance) * zoomLevel;

        var camPos:Vector3 = new Vector3(0,0,0);
        var targetPos:Vector3 = new Vector3(0,0,0);

        var heightRange:Number = (m_TargetHeadPos.y - m_TargetGroundPos.y) * 1.2;
        camPos.x = m_TargetGroundPos.x + Math.cos( cameraAngle ) * cameraDistance;
        camPos.z = m_TargetGroundPos.z + Math.sin( cameraAngle ) * cameraDistance;
        camPos.y = m_TargetGroundPos.y + heightRange * Math.max( 0.3, cameraHeight );

        targetPos.x = m_TargetGroundPos.x;
        targetPos.z = m_TargetGroundPos.z;
        targetPos.y = m_TargetGroundPos.y + heightRange * Math.min( 0.7, cameraHeight );

        camPos.y = targetPos.y + (camPos.y - targetPos.y) * cameraDistance / m_CameraMaxDistance;
        
        PlaceCamera( camPos, targetPos );
    }

    public function MouseWheel( delta:Number )
    {
        if(!m_LockPosUpdate)
        {
            m_CameraDistance.SetEndValue( 0.1, Math.max( 0, Math.min( 1, m_CameraDistance.GetEndValue() - delta * 0.1 ) ) );
        }
    }

    private var m_CameraMinDistance:Number;
    private var m_CameraMaxDistance:Number;

    private var m_MinDistances:Array;
    private var m_MaxDistances:Array;

    private var m_CameraPosition:Vector3;

    private var m_TargetHeadPos:Vector3;
    private var m_TargetGroundPos:Vector3;

    private var m_CameraHeight:Interpolator;
    private var m_CameraDistance:Interpolator;
    
    private var m_IsAnimating:Boolean;
    private var m_IsInteractive:Boolean;
    private var m_AnimStartTime:Number;
    private var m_AnimEndTime:Number;
    private var m_LockPosUpdate:Boolean;
}
