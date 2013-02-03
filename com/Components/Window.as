import gfx.core.UIComponent;
import gfx.controls.Button;
import gfx.utils.Constraints;
import mx.utils.Delegate;
import com.Utils.Signal;

[InspectableList("title", "_formPadding", "_formSource", "_formType", "allowResize", "_minWidth", "_maxWidth", "_minHeight", "_maxHeight")]
class com.Components.Window extends UIComponent
{
    // Constants
    private var DRAG_PADDING:Number = 40;
    
	// Private Properties:
	[Inspectable(name="formType", enumeration="symbol,swf"]
	private var _formType:String = "symbol";
	
	[Inspectable(name="formSource", defaultValue="")]
	private var _formSource:String = "";
	
	[Inspectable(name="formPadding", defaultValue=10)]
	private var _formPadding:Number = 10;
	
	private var _title:String="";
	private var _allowResize:Boolean = false;
	private var constraints:Constraints;
	private var dragProps:Array;
	private var formCreated:Boolean = false;
	private var loader:MovieClipLoader;
  
	[Inspectable(name="minWidth")]
	private var _minWidth:Number;
	
	[Inspectable(name="maxWidth")]	
	private var _maxWidth:Number;
	
	[Inspectable(name="minHeight")]	
	private var _minHeight:Number;	
	
	[Inspectable(name="maxHeight")]	
	private var _maxHeight:Number;	
    
    public var SignalFormLoaded:Signal;

	// UI Elements:
	private var hitArea:MovieClip;
	private var titleTextField:TextField;
	//private var line:MovieClip;
	public var closeButton:Button;
	private var background:MovieClip;
	private var hit:MovieClip;
	private var form:UIComponent;
    
    private var m_Footer:MovieClip; // addad by bardi
    private var m_Stroke:MovieClip // added by bardi
	// Initialization:
	public function Window()
	{
		super();	
        SignalFormLoaded = new Signal();
	}

	// Public Methods:
	[Inspectable(defaultValue="")]
	public function get title():String
	{
		return _title;
	}
	
	public function set title(value:String):Void
	{
		_title = value;
		invalidate();
	}

	[Inspectable(defaultValue="true")]
	public function get allowResize():Boolean
	{
		return _allowResize;
	}

	public function set allowResize(value:Boolean):Void
	{
		_allowResize = value;
		invalidate();
	}
  
	public function toString():String
	{
		return "[Scaleform Window " + _name + "]";
	}
  
	// Private Methods:
	private function configUI():Void
	{
		background.hitTestDisable = true;
		hitArea.tabEnabled = hitArea.focusEnabled = false;

		super.configUI();										

		constraints = new Constraints(this);
		constraints.addElement(background, Constraints.ALL);
		constraints.addElement(hitArea, Constraints.ALL);
		constraints.addElement(titleTextField, Constraints.LEFT | Constraints.RIGHT);
		hitArea.onPress = Delegate.create(this, dragStartHandler);
		hitArea.onRelease = hitArea.onReleaseOutside = Delegate.create(this, dragStopHandler);
		
		titleTextField.text = _title;
        
	}
  
	private function draw():Void
	{
		if (!formCreated)
		{
			formCreated = true;
			
			if (_formType == "swf")
			{
				this.visible = false;
		
				if (loader)
				{
					delete loader;
				}
				
				loader = new MovieClipLoader();
				this.createEmptyMovieClip("form", this.getNextHighestDepth());
				loader.addListener(this);				
				loader.loadClip(_formSource, form);			
		
			// Defer form config until it has been completly loaded
			}
			else
			{
                this.attachMovie(_formSource, "form", this.getNextHighestDepth());
                var formConfigUI = Delegate.create(form, form.configUI);
                var localSignal:Signal = SignalFormLoaded;
                form.configUI = function()
                {
                    formConfigUI();
                    localSignal.Emit();
                }
                layout();
			}
			
		return;			
		}
	
		constraints.update(__width, __height);
		
		if (form && form.validateNow)
		{
			form.validateNow();
		}
	}
  
	// Only used for swf loading
	private function onLoadComplete():Void
	{ 
		// Delay config by a frame to allow form dimensions to be propogated
		onEnterFrame = function()
		{
			layout();
			this.visible = true;
            SignalFormLoaded.Emit();
			onEnterFrame = null;
		}
	}
  
	private function layout():Void
	{		
		if (!form)
		{
			return;
		}
		
		// Layout window assets
		titleTextField._x = _formPadding;
		titleTextField._y = _formPadding;

        if (title != "")
        {
            form._x = titleTextField._x;
            form._y = titleTextField._y + titleTextField._height + _formPadding;
        }
        else
        {
            form._x = _formPadding;
            form._y = _formPadding;
        }
		
		setSize(form._width + _formPadding * 2, form._y + form._height + _formPadding);
        
		// Update constraints before adding form to constraints			
		constraints.update(__width, __height);
		constraints.addElement(form, Constraints.ALL);
		
		// Layout window assets after form is added to constraints
		closeButton._x = hitArea._x + hitArea._width - closeButton._width;
		closeButton._y = hitArea._y + 2;
		closeButton.disableFocus = true;
		

		// Setup default minimum resize dimensions
		var minWidth = (!_minWidth) ? __width : Math.max(__width, _minWidth);
	    var minHeight = (!_minHeight) ? __height : Math.max(__height, _minHeight);
		
		// Setup default maximum resize dimensions
		if (_maxWidth < 0)
		{
			_maxWidth = _minWidth;
		} 
		else
		{
			_maxWidth = (!_maxWidth) ? Number.POSITIVE_INFINITY : Math.max(_minWidth, _maxWidth);
		}
		
		if (_maxHeight < 0)
		{
			_maxHeight = _minHeight;
		}
		else
		{
			_maxHeight = (!_maxHeight) ? Number.POSITIVE_INFINITY : Math.max(_minHeight, _maxHeight);
		}

        if ( m_Footer != undefined)
        {
            m_Footer._y = minHeight - m_Footer._height;
            m_Footer._width = minWidth
        }
        if (m_Stroke != undefined)
        {
            m_Stroke._height = minHeight;
            m_Stroke._width = minWidth;
        }
		// Set the final size
		setSize(minWidth, minHeight);			
	}
	  
	function dragStartHandler()
	{
        var visibleRect = Stage["visibleRect"];
		
        startDrag   (
                    this,
                    false,
                    0 - this.width + DRAG_PADDING,
                    0 - this.height + DRAG_PADDING,
                    visibleRect.x + visibleRect.width - DRAG_PADDING,
                    visibleRect.y + visibleRect.height - DRAG_PADDING
                    );
    }

	function dragStopHandler()
	{
		stopDrag();
	}	

	function handleResizeDragStart()
	{
		dragProps = [_parent._xmouse-(this._x+this._width), _parent._ymouse-(this._y+this._height)];
		onMouseMove = handleResize;
	}

	function handleResizeDragStop()
	{
		onMouseMove = null;
		delete onMouseMove;
	}
	function handleResize()
	{			
		setSize	(
				Math.max(_minWidth, Math.min(_maxWidth, _parent._xmouse-this._x-dragProps[0])),
				Math.max(_minHeight, Math.min(_maxHeight, _parent._ymouse-this._y-dragProps[1]))
				);
	}
}