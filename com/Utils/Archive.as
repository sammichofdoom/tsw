
class com.Utils.Archive
{
    public function Archive()
    {
        m_Dictionary = new Object;
    }


    public function AddEntry( name:String, value )
    {
        if ( m_Dictionary.hasOwnProperty( name ) )
        {
            m_Dictionary[name].push( value );
        }
        else
        {
            m_Dictionary[name] = [ value ];
        }
    }
    public function ReplaceEntry( name:String, value )
    {
        m_Dictionary[name] = [ value ];
    }

    public function DeleteEntry( name:String ) : Void
    {
        delete m_Dictionary[name];
    }
    
    public function FindEntry( name:String, defaultValue )
    {
        if ( m_Dictionary.hasOwnProperty( name ) )
        {
            var array:Array = m_Dictionary[name];
            if ( array.length > 0 )
            {
                return array[0];
            }
        }
        return defaultValue;
    }
    public function FindEntryArray( name:String ) : Array
    {
        if ( m_Dictionary.hasOwnProperty( name ) )
        {
            return m_Dictionary[name];
        }
        return undefined;
    }

    public function Clear()
    {
        m_Dictionary = new Object;
    }

    public function toString() : String
    {
        var text:String = "";

        for ( var name in m_Dictionary )
        {
            if ( text.length > 0 )
            {
                text += ", ";
            }
            text += name + "[" + m_Dictionary[name].toString() + "]";
        }
        return text;
    }
    
    private var m_Dictionary:Object;
}