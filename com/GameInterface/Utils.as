import com.GameInterface.DistributedValue;
import com.GameInterface.UtilsBase;
import com.GameInterface.Log;
import com.GameInterface.HTMLFont;
import com.Utils.Colors;

class com.GameInterface.Utils extends com.GameInterface.UtilsBase
{
    public static function ParseHTMLColor(name:String):flash.geom.ColorTransform 
    {
        var color:flash.geom.ColorTransform = new flash.geom.ColorTransform();
        var rgb = UtilsBase.ParseHTMLColor( name );
        color.rgb = rgb;
        return color;
    }
	 
    public static function ParseHTMLFont(name:String):Object
    {
     return UtilsBase.ParseHTMLFont( name );
    }
	 
    public static function ParseHTMLFontFinal(name:String):HTMLFont
    {
        var htmlFont:HTMLFont = new HTMLFont();
        var fontObject:Object = ParseHTMLFont( name );

        htmlFont.SetColor( fontObject.m_Color );
        htmlFont.SetSize( fontObject.m_Size );
        htmlFont.SetStyle( fontObject.m_Style );
        htmlFont.SetFamily( fontObject.m_Family );
        htmlFont.SetWaitOnScreen( fontObject.m_WaitOnScreen );
        htmlFont.SetSpeed( fontObject.m_Speed );
        htmlFont.SetFlyingDirection( fontObject.m_FlyingDirection );
				
        return htmlFont;
    }
    
    public static function CreateResourceString(resourceId:com.Utils.ID32):String
    {
        return com.Utils.Format.Printf( "rdb:%.0f:%.0f", resourceId.GetType(), resourceId.GetInstance() );
    } 
	
  public static function SetupHtmlHyperLinks(htmlText:String, hyperLinkFunction:String, addFormat:Boolean):String
  {
    var dst:String = "";

    var tagStart:Number = 0;
    var tagEnd:Number = 0;

    var src:String = htmlText;
    var lowercaseSrc:String = src.toLowerCase();
		
    for ( var i:Number = 0 ; i < lowercaseSrc.length ; ) 
    {
      tagStart = lowercaseSrc.indexOf("<a", i);
      if (tagStart>=0) 
      {
        dst += src.substring(i, tagStart);
        i = tagStart;
        tagStart = lowercaseSrc.indexOf("href", tagStart+2);
        if (tagStart>=0) 
        {
          tagStart += 4;
          while (lowercaseSrc.charAt(tagStart) == ' ' || lowercaseSrc.charAt(tagStart) == '\t') 
          {
            tagStart++;
          }
          if (lowercaseSrc.charAt(tagStart) == '=') 
          {
            tagStart += 1;
            while (lowercaseSrc.charAt(tagStart) == ' ' || lowercaseSrc.charAt(tagStart) == '\t') 
            {
              tagStart++;
            }
            if (lowercaseSrc.charAt(tagStart) == '"' || lowercaseSrc.charAt(tagStart) == "'")
            {
              tagStart += 1;
            }
            if (addFormat)
            {
                dst += "<u>";
            }
            dst += src.substring(i, tagStart);
            i = tagStart;
            dst += "asfunction:" + hyperLinkFunction+",";
          }
          else
          {
            i = src.length;
          }
        }
        else
        {
          i = src.length;
        }
	
        tagEnd = lowercaseSrc.indexOf("</a>",i);
        if(tagEnd >= 0)
        {
          tagEnd += 4;
          dst += src.substring(i, tagEnd);
          if (addFormat)
          {
            dst += "</u>";
          }
          i = tagEnd;
        }
      } 
      else 
      {
        dst += src.substring(i);
        i = src.length;
      }
    }
    return dst;
  }
  
/*  public static function FormatNumeric(number:Number):String
  {
	var number_string = ExternalInterface.call("FormatNumeric", m_ClassName, number);
	return number_string;
    }*/
    
    /// Shortens the mission name if it does not fit inside the window, then appends an ellipsis to the
    /// mission name to visually indicate to the user that more text is available.
    /// @param textField - the textfield to truncate, does only work on textfields where autoSize = true
    /// Example:  "This is my text" could become "this is m...".
    public static function TruncateText(textField:TextField):Void
    {
        var margin:Number = 5;
        var width:Number  = textField._width;

        if (textField.autoSize == "none")
        {
            width -= margin;
        }
        
        if (textField.textWidth < width)
        {
            return;
        }
        
        var clippedString:String = textField.text;
        
        while (clippedString.length > 0 && textField.textWidth >= width)
        {
            clippedString = clippedString.substr(0, clippedString.length - 1);
            textField.text = clippedString + "...";
        }

    }
    
    public static function TruncateHTMLText(textField:TextField) : Void
    {
        var margin:Number = 5;
        
        if (textField.textWidth < textField._width - margin)
        {
            return;
        }
        var format:TextFormat = textField.getTextFormat()
        var htmlParams:Object = { face: format.font, color: Colors.ColorToHtml( format.color ), size:format.size };
        var clippedString:String = textField.text;
        
        while (clippedString.length > 0 && textField.textWidth >= textField._width - margin)
        {
            clippedString = clippedString.substr(0, clippedString.length - 1);
            
            textField.htmlText = CreateHTMLString( clippedString + "...", htmlParams);
        }
    }
    
    
    public static function CreateHTMLString(text:String, parameters:Object)
    {
        var out:String = "<font ";
        
        for (var prop:String in parameters)
        {
            out += prop+"='"+parameters[prop]+"' "
        }
        
        return out + ">"+text+"</font>";

    }
}
