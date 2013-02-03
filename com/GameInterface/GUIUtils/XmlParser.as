/// @file TSWCode/FlashGui/com/GameInterface/Utils/XmlParser.as
/// @class XmlParser
/// @author Board Ingebricson
/// @date 091113
/// @version 1

/// Parses XML to values in an object and handles methods for simple retrieval of these values
class com.GameInterface.GUIUtils.XmlParser
{
	private var m_Values:Object; /// object that holds all the parsed values.
	
	
	/// The constructor, retrives an XMLNode, sets up the toplevel object and starts parsing the xml
	/// @param p_xml:XMLNode - the fragment xml to parse
	/// @return void
	public function XmlParser( p_xml:XMLNode )
	{
		// get the attributes into its own object, note that if any elements are named the same as the toplevel attributes, the latter is overwriting the first
		if( hasAttribute(p_xml) )
		{
			this.m_Values = getAttributes( p_xml, this.m_Values);
		} 
		else 
		{
			this.m_Values = new Object();
		}

		// loop the elements of the XMLNode recurively and parse the content to the this.m_Values object
		recursiveXmlLoop(p_xml, this.m_Values );
	}
	
	/// Recursive looping and parsiing of XML, parses the attributes first if available, proceeds with the elements, if any sub elements the function calls itself repeditly
	/// @param p_xmlnode:XMLNode - the xmlnode to parse
	/// @param p_valueobject:Object -  the Object at the correct point where you wuuld like to insert the parsed values
	/// @returns Void
	private function recursiveXmlLoop(p_xmlnode:XMLNode, p_valueobject:Object ) : Void
	{
		
		for(var i:Number = 0; i < p_xmlnode.childNodes.length; i++)
		{
			var cNode:XMLNode =XMLNode(  p_xmlnode.childNodes[i] );
			var nn:String = cNode.nodeName;
			
			if(cNode.firstChild.nodeType == 1) // if it is an element node
			{

				if( hasAttribute( cNode ) ) { // if there are attributes to this node
					p_valueobject[nn]  = getAttributes(cNode, p_valueobject);
				} else { // no attributes, but still an object
					p_valueobject[ nn ] = new Object();
				}
				recursiveXmlLoop(cNode,p_valueobject[ nn ] );
			}
			else if (cNode.firstChild.nodeType == 3 ) // normal content
			{
				var str:String =  cNode.firstChild.nodeValue.toString();
				
				if( hasAttribute( cNode ) ) // if there are attributes to this node
				{
					p_valueobject[ nn ] = getAttributes(cNode, p_valueobject);
					p_valueobject[nn ]["value"] = str;
				} else {
						p_valueobject[ nn ] = str;
				}
			}
		}
	}
	
	
	/// Reads all the attributes of an XML, if attribute is empty it is omitted
	/// @param p_xmlnode:XMLNode - the xmlnode to parse
	/// @param p_valueobject:Object -  the Object at the correct point where you would like to insert the parsed values
	/// @return Object - the object (or associative array if you will ) where the values are inserted
	private function getAttributes( p_xmlnode:XMLNode, p_valueobject:Object ) : Object
	{
		var attribs:Object = new Object();
		for( var attr in p_xmlnode.attributes )
		{
			if( String( p_xmlnode.attributes [ attr ]) != "")
			{
				attribs[ attr ] =  p_xmlnode.attributes [ attr ];
			}
		}
		return attribs;
	}
	
	/// Looks up the internal getValueByName method and return its values
	/// @param p_name:String
	/// @return string, null or Object depending if one, zero or multiple items are found
	public function GetValue( p_name:String)
	{
		return getValueByName(p_name, this.m_Values);
	}
	
	/// recursive function that loops the m_Values object looking for textual matches, and returns all possible
	/// @param p_name:String - the name of the prop to return
	/// @param p_valueobject:Object -  the object you are inspecting
	/// @return string, null or Object depending if one, zero or multiple items are found
	private function getValueByName(p_name:String, p_valueobject:Object)
	{
		if(p_valueobject[ p_name ] == undefined ) // there is no element with that name
		{
			var props:Array = new Array();
			
			for( var prop in p_valueobject) /// loop all elements at this level
			{
				if(typeof( p_valueobject[ prop ] ) == "object" ) // if an element is an object (has sub elements)
				{
					var val =  getValueByName(p_name, p_valueobject[ prop ]); // recurse
					if( val != null) {
						if(typeof( val ) == "object" )
						{
							props = props.concat(val);
						} else {
							props.push( val );
						}
					}
				}
			}
			/// determine the return value
			if( props.length == 1) {
				return String( props[0])
			} else if ( props.length > 1) {
				return props;
			} else {
				return null
			}
		}
		else
		{
			return p_valueobject[ p_name ] 
		}
	}


	/// attempts to iterate the XMLNode's attributes, returns true if there are any attributes to iterate
	/// @param p_context:XMLNode - the xmlnode to inspact for attributes
	/// @returns Boolean true if attributes exist, false if not
	public function hasAttribute(p_context:XMLNode)
	{
		for( var attr in p_context.attributes )
		{
			return true;
			break;
		}
		return false;
	}

}