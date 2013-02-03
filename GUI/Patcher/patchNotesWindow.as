import com.PatcherInterface.Patcher;

m_TextArea.html = true;

function SlotPatchNotesUpdated( txt:String )
{
    var notes_css = new TextField.StyleSheet();

    notes_css.onLoad = function(success:Boolean)
    {
       if (success)
        {
            m_TextArea.textField.styleSheet = notes_css;
            m_TextArea.htmlText =  _root.patcher.UpdateHRefTags( txt );
            m_TextArea.position = 2; 
            m_TextArea.position = 1;
        }
        else
        {
            m_TextArea.htmlText = "css failed to load!";
        }
    }

    notes_css.load("patchnote.css");
}
Patcher.SignalPatchNotesDownloaded.Connect( SlotPatchNotesUpdated, this );
