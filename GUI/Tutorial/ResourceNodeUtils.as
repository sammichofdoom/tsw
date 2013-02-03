import com.GameInterface.Lore;

class GUI.Tutorial.ResourceNodeUtils
{
    
    public static function GetArgs(id:Number):Object
    {
        var args = new Object();
        var hasData = false;
        
        
        var text:String = Lore.GetTagText(id);
        if (text != undefined && text.length > 0)
        {
            args["Text"] = text;
            hasData = true;
        }
        
        var mediaId:Number = Lore.GetMediaId(id, _global.Enums.LoreMediaType.e_FlashFile )
        if (mediaId > 0)
        {
            args["Image"] = new com.Utils.ID32(_global.Enums.RDBID.e_RDB_FlashFile, mediaId);
            hasData = true;
        }
        mediaId = Lore.GetMediaId(id, _global.Enums.LoreMediaType.e_Image )
        if (mediaId > 0)
        {
            args["Image"] = new com.Utils.ID32(_global.Enums.RDBID.e_RDB_GUI_Image, mediaId);
            hasData = true;
        }
        mediaId = Lore.GetMediaId(id, _global.Enums.LoreMediaType.e_Movie )
        if (mediaId > 0)
        {
            args["Video"] = new com.Utils.ID32(_global.Enums.RDBID.e_RDB_USM_Movie, mediaId);
            hasData = true;
        }
        
        if (!hasData)
        {
            args["Text"] = "missing data";
        }
        
        args["hasData"] = hasData;
        
        return args;
    }
}