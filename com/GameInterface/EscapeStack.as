import flash.external.ExternalInterface;

import com.GameInterface.EscapeStackNode;

class com.GameInterface.EscapeStack
{
  public static function Push( node:EscapeStackNode )
  {
    m_Stack.push( node );
  }

  public static function OnEscapePressed() // Could called from C++
  {
    while(m_Stack.length > 0)
    {
      var node = m_Stack.pop();
      if(node.EscapePressed())
      {
        return true;
      }
    }
    return false;
    
  }

  private static var m_Stack:Array = [];
};

