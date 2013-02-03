import gfx.core.UIComponent;
import mx.transitions.easing.*;
import com.Utils.LDBFormat;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.Utils;

import gfx.controls.Button;

dynamic class GUI.CharacterCreation.FactionSelector extends UIComponent
{
	public var SignalFactionSelected:Signal;
	public var visibleRect:flash.geom.Rectangle;
	
	private var m_NavigationBar:MovieClip;
	private var m_BackButton:MovieClip;
	private var m_Title:MovieClip;
	private var m_PlayButtonIlluminati:MovieClip;
	private var m_PlayButtonTemplars:MovieClip;
	private var m_PlayButtonDragon:MovieClip;
	private var m_BgImg:MovieClip;
	private var m_Background:MovieClip;
    private var m_IlluminatiSelector:MovieClip;
    private var m_DragonSelector:MovieClip;
    private var m_TemplarsSelector:MovieClip;
	private var m_VideoPlayer:MovieClip;
	
	private var m_VideoPlayerIsOpen:Boolean;
	private var imgURL:String;
	private var distanceBetweenFactionSlots:Number = 50;
	private var playButtonDistanceFromBottom:Number = 15;
	private var w:Number;
	private var h:Number;
	
    public function FactionSelector()
    {
		visibleRect = Stage["visibleRect"];
		
		m_PlayButtonIlluminati["faction"] = _global.Enums.Factions.e_FactionIlluminati;
		m_PlayButtonTemplars["faction"] = _global.Enums.Factions.e_FactionTemplar;
		m_PlayButtonDragon["faction"] = _global.Enums.Factions.e_FactionDragon;
		
        SignalFactionSelected = new Signal;
		
		LayoutHandler();
    }
	
	private function SetLabels()
	{
		m_BackButton.m_Label.text = LDBFormat.LDBGetText( "GenericGUI", "Back" );
		m_PlayButtonIlluminati.label = LDBFormat.LDBGetText( "MiscGUI", "PlayVideo" );
		m_PlayButtonTemplars.label = LDBFormat.LDBGetText( "MiscGUI", "PlayVideo" );
		m_PlayButtonDragon.label = LDBFormat.LDBGetText( "MiscGUI", "PlayVideo" );
		
		m_Title.textField.
		m_Title.text = LDBFormat.LDBGetText( "CharCreationGUI", "SelectAlliance" );
        
		m_IlluminatiSelector.textField.htmlText = LDBFormat.LDBGetText( "FactionNames", "Illuminati" );
        m_IlluminatiSelector.m_tagline.htmlText = '"' + LDBFormat.LDBGetText( "FactionNames", "factiontagline_Illuminati" ) + '"';
        m_TemplarsSelector.textField.htmlText = LDBFormat.LDBGetText( "FactionNames", "Templars" );
        m_TemplarsSelector.m_tagline.htmlText = '"' + LDBFormat.LDBGetText( "FactionNames", "factiontagline_Templars" ) + '"';
        m_DragonSelector.textField.htmlText = LDBFormat.LDBGetText( "FactionNames", "Dragon" );
        m_DragonSelector.m_tagline.htmlText = '"' + LDBFormat.LDBGetText( "FactionNames", "factiontagline_Dragon" ) + '"';
	}
	
    private function configUI()
    {
        var dragonEnabled:Number = com.GameInterface.Utils.GetGameTweak("GUIEnableFactionDragon");
        if (dragonEnabled > 0)
        {
            m_PlayButtonDragon.disabled = false;
            m_DragonSelector.disabled = false;
        }
        else
        {
            m_PlayButtonDragon.disabled = true;
            m_DragonSelector.disabled = true;            
        }
        var illuminatiEnabled:Number = com.GameInterface.Utils.GetGameTweak("GUIEnableFactionIlluminati");
        if (illuminatiEnabled > 0)
        {
            m_PlayButtonIlluminati.disabled = false;
            m_IlluminatiSelector.disabled = false;
        }
        else
        {
            m_PlayButtonIlluminati.disabled = true;
            m_IlluminatiSelector.disabled = true;
        }
        var templarsEnabled:Number = com.GameInterface.Utils.GetGameTweak("GUIEnableFactionTemplar");
        if (templarsEnabled > 0)
        {
            m_PlayButtonTemplars.disabled = false;
            m_TemplarsSelector.disabled = false;
        }
        else
        {
            m_PlayButtonTemplars.disabled = true;
            m_TemplarsSelector.disabled = true;
        }
		m_BackButton.disabled = false;
		
		SetLabels();
		
		m_BackButton.m_BackwardArrow._alpha = 100;
        m_BackButton.SignalButtonSelected.Connect(BackToCharacterSelection, this);
		
		m_IlluminatiSelector.addEventListener("click", this, "OnSelectFaction");
		m_TemplarsSelector.addEventListener("click", this, "OnSelectFaction");
		m_DragonSelector.addEventListener("click", this, "OnSelectFaction");
		
		m_PlayButtonIlluminati.addEventListener("click", this, "OpenFactionVideoPlayer");
		m_PlayButtonTemplars.addEventListener("click", this, "OpenFactionVideoPlayer");
		m_PlayButtonDragon.addEventListener("click", this, "OpenFactionVideoPlayer");
    }
	
	private function BackToCharacterSelection()
	{
        Utils.PlayFeedbackSoundEnum(_global.Enums.SoundID.e_SoundButtonClicked);
        this.m_CharacterCreationIF.ExitCharacterCreation();
	}
	
	private function OnSelectFaction(f:Object)
	{		
		switch(f.target)
		{
			case m_IlluminatiSelector:
				Select( _global.Enums.Factions.e_FactionIlluminati );
				break;
			
			case m_TemplarsSelector:
				Select( _global.Enums.Factions.e_FactionTemplar );
				break;
				
			case m_DragonSelector:
				Select( _global.Enums.Factions.e_FactionDragon );
				break;
			default:
			break;
		}
		
		m_IlluminatiSelector.disabled = true;
		m_TemplarsSelector.disabled = true;
		m_DragonSelector.disabled = true;

	}
	
    private function Select( faction:Number )
    {
        SignalFactionSelected.Emit( faction );
    }
   
	private function SetBackgroundImage()
	{
		m_BgImg._alpha = 0;
		
		m_BgImg._width = Stage.width;
		m_BgImg._height = Stage.height;
		m_BgImg._y = -40;
		m_BgImg._x = (Stage.width / 2) - ( m_BgImg / 2 );
		m_BgImg.tweenTo( 5, { _alpha: 100, _y: 0 }, Strong.easeOut );
	}
	
	private function OpenFactionVideoPlayer(event:Object)
	{	
		
		
        if ( m_VideoPlayerIsOpen )
        {
            m_VideoPlayer.removeMovieClip();
        }
		
		m_BackButton.disabled = true;
		
		m_IlluminatiSelector.disabled = true;
		m_TemplarsSelector.disabled = true;
		m_DragonSelector.disabled = true;
		
		m_PlayButtonIlluminati.disabled = true;
		m_PlayButtonTemplars.disabled = true;
		m_PlayButtonDragon.disabled = true;
		
		SetLabels();
		
		faction = event.target.faction;
		
		m_VideoPlayer = attachMovie ( "FactionVideoPlayer", "m_VideoPlayer", this.getNextHighestDepth() );
		m_VideoPlayer._xscale = 200;
		m_VideoPlayer._yscale = 185;
		m_VideoPlayer.m_Title._xscale = m_VideoPlayer.m_Title._yscale = 80;
		m_VideoPlayer.m_Title._x = 3;
		m_VideoPlayer.m_Title._y = 0;
		m_VideoPlayer._alpha = 0;
		m_VideoPlayer._x = (Stage.width / 2) - (m_VideoPlayer._width/2);
		m_VideoPlayer._y = (Stage.height / 2) -  (m_VideoPlayer._height / 2) + 10;
		m_VideoPlayer.tweenTo( 0.5, { _alpha: 100, _y: (Stage.height / 2) -  (m_VideoPlayer._height / 2) }, Strong.easeOut );
			
		m_CloseButton = attachMovie ( "CloseButton", "m_CloseButton", this.getNextHighestDepth() );
		m_CloseButton._xscale = 120;
		m_CloseButton._yscale = 120;
		m_CloseButton.addEventListener("click", this, "CloseFactionVideoPlayer");
		m_CloseButton._alpha = 0;
		m_CloseButton.tweenTo( 0.5, { _alpha: 100 }, Strong.easeOut );
		m_CloseButton._x = m_VideoPlayer._x + m_VideoPlayer._width - (m_CloseButton._width) - 4;
		m_CloseButton._y = m_VideoPlayer._y - 4;	
		
		// language switching
		var languageCode:String = LDBFormat.GetCurrentLanguageCode();
		//trace("CURRENT VIDEO LANGUAGE: " + languageCode);
		switch(languageCode)
		{
			case "en":
				//trace("english");
				m_VideoPlayer.SetSubtitleTrack(0);
				m_VideoPlayer.SetAudioTrack(0);
				break;
			case "fr":
				//trace("french");
				m_VideoPlayer.SetSubtitleTrack(1);
				m_VideoPlayer.SetAudioTrack(1);
				break;
			case "de":
				//trace("german");
				m_VideoPlayer.SetSubtitleTrack(2);
				m_VideoPlayer.SetAudioTrack(2);
				break;
			default:
				trace("unknown language");
		}
		
		switch(faction)
		{
			case _global.Enums.Factions.e_FactionIlluminati:
				m_VideoPlayer.LoadVideo( "rdb:1000635:6885369" );
				m_VideoPlayer.m_Title.text = LDBFormat.LDBGetText( "FactionNames", "Illuminati" );
				break;
			case _global.Enums.Factions.e_FactionTemplar:
				m_VideoPlayer.LoadVideo( "rdb:1000635:6885370" );
				m_VideoPlayer.m_Title.text = LDBFormat.LDBGetText( "FactionNames", "Templars" );
				break;
			case _global.Enums.Factions.e_FactionDragon:
				m_VideoPlayer.LoadVideo( "rdb:1000635:6885367" );
				m_VideoPlayer.m_Title.text = LDBFormat.LDBGetText( "FactionNames", "Dragon" );
				break;
		};
		
		m_VideoPlayerIsOpen = true;
		m_VideoPlayer.SignalStopped.Connect(CloseFactionVideoPlayer, this);
    }
	
	private function CloseFactionVideoPlayer()
	{
		
		m_VideoPlayer.tweenTo( 0.5, { _alpha: 0 }, None.easeInOut );
		m_CloseButton.tweenTo( 0.5, { _alpha: 0 }, None.easeInOut );
		
		m_VideoPlayer.onTweenComplete = Delegate.create( this, RemoveVideoPlayer);
		
		m_BackButton.disabled = false;
		
		m_IlluminatiSelector.disabled = false;
		m_TemplarsSelector.disabled = false;
		m_DragonSelector.disabled = false;
		
		m_PlayButtonIlluminati.disabled = false;
		m_PlayButtonTemplars.disabled = false;
		m_PlayButtonDragon.disabled = false;
		
		SetLabels();
		configUI();
	}
	
	private function RemoveVideoPlayer()
	{
		m_VideoPlayer.removeMovieClip();
		m_CloseButton.removeMovieClip();
		
		m_VideoPlayerIsOpen = false;
	}
	
	private function VideoPlayerLayoutHandler()
	{
		if ( m_VideoPlayerIsOpen )
		{
			m_VideoPlayer._x = (Stage.width / 2) - (m_VideoPlayer._width/2);
			m_VideoPlayer._y = (Stage.height / 2) -  (m_VideoPlayer._height / 2);
			m_CloseButton._x = m_VideoPlayer._x + m_VideoPlayer._width - (m_CloseButton._width) - 4;
			m_CloseButton._y = m_VideoPlayer._y + 6;
		}
		
	}
	
	public function LayoutHandler()
	{		
		w = Stage.width;
		h = Stage.height;
		
		m_Background._width = w;
		m_Background._height = h;
		m_BgImg._width = w;
		m_BgImg._height = h;
		m_Background.onPress = function() { };
		
		m_Background._x = 0;
		m_Background._y = 0;
		
		SetBackgroundImage();
		
		m_BgImg._x = m_Background._x;
		m_BgImg._y = m_Background._y;
		
		m_NavigationBar._width = w+1;
		m_NavigationBar._x = 0;
		m_NavigationBar._y = h - m_NavigationBar._height;
		
		
		m_BackButton._x = 10;
		m_BackButton._y = m_NavigationBar._y + (m_NavigationBar._height / 2) - (m_BackButton._height / 2) + 5;
		
		m_TemplarsSelector._x = ( w/2 ) - ( m_TemplarsSelector._width/2 );
		m_TemplarsSelector._y = ( h/2 ) - ( m_TemplarsSelector._height/2 );
		m_IlluminatiSelector._x = m_TemplarsSelector._x - m_IlluminatiSelector._width - distanceBetweenFactionSlots;
		m_IlluminatiSelector._y = m_TemplarsSelector._y;
		m_DragonSelector._x = m_TemplarsSelector._x + m_DragonSelector._width + distanceBetweenFactionSlots;
		m_DragonSelector._y = m_TemplarsSelector._y;
		
		m_PlayButtonIlluminati._x = m_IlluminatiSelector._x + ( ( m_IlluminatiSelector._width/2 ) - m_PlayButtonIlluminati._width/2);
		m_PlayButtonIlluminati._y = m_IlluminatiSelector._y + m_IlluminatiSelector._height + playButtonDistanceFromBottom;
		m_PlayButtonTemplars._x = m_TemplarsSelector._x + ( ( m_TemplarsSelector._width/2 ) - m_PlayButtonTemplars._width/2);
		m_PlayButtonTemplars._y = m_TemplarsSelector._y + m_TemplarsSelector._height + playButtonDistanceFromBottom;
		m_PlayButtonDragon._x = m_DragonSelector._x + ( ( m_DragonSelector._width/2 ) - m_PlayButtonDragon._width/2);
		m_PlayButtonDragon._y = m_DragonSelector._y + m_DragonSelector._height + playButtonDistanceFromBottom;
		
		VideoPlayerLayoutHandler();
		
		m_Title._x = (w / 2) - (m_Title._width / 2);
		m_Title._y = 20;
	}
}
