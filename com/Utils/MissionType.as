class com.Utils.MissionType
{
    /// returns the mission type as a string, gets it from the missiontypeenum
    ///  there is really no great way of converting 1 to _Stealth unless we use a sattic mapping method
    public static function ToString( id:Number )
    {
        var iconname:String = "Unknown";
        var qtype:Object = _global.Enums.MainQuestType;
        switch( id )
        {
            case qtype.e_Action:
                iconname = "Action";
            break;
            case qtype.e_Stealth:
                iconname = "Stealth";
            break;
            case qtype.e_Story:
                iconname = "Story";
            break;
            case qtype.e_Challenge:
                iconname = "Challenge";
            break;
            case qtype.e_Investigation:
                iconname = "Investigation";
            break;
        }
        return iconname;


    }
}