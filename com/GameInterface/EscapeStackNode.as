import flash.external.ExternalInterface;

import com.Utils.Signal;

class com.GameInterface.EscapeStackNode
{
  public function EscapeStackNode()
  {
    SignalEscapePressed = new Signal;
  }

  public function EscapePressed() : Boolean
  {
    trace('EscapeStackNode:EscapePressed()')
    if(!SignalEscapePressed.Empty())
    {
      trace('Someone is connected to SignalEscapePressed, sending signal.')
      SignalEscapePressed.Emit();
      return true;
    }

    trace('Noone is connected to SignalEscapePressed.')
    return false;
  }

  public var SignalEscapePressed:Signal;
}

