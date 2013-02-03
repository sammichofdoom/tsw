import com.PatcherInterface.Patcher;

var languageCode:String 

function onLoad()
{
    m_LatestNewsletterButton.label = "$Patcher:LatestNewsletter_textLabel";
    m_LatestNewsletterButton.addEventListener("click", this, "GotoLatestNewsletter");
    
    m_CommunityButton.label = "$Patcher:Community_textLabel";
    m_CommunityButton.addEventListener("click", this, "GotoCommunity");
    
    m_SupportButton.label = "$Patcher:support_textLabel";
    m_SupportButton.addEventListener("click", this, "GotoSupport");
    
    m_ForumsButton.label = "$Patcher:forums_textLabel";
    m_ForumsButton.addEventListener("click", this, "GotoForums");

    languageCode = Patcher.GetLanguageCode(Patcher.GetLanguageSelection());
}

function GotoLatestNewsletter()
{
	switch(languageCode)
	{
		case "de":
			Patcher.ShowExternalURL( "http://www.thesecretworld.com/deutsch/news" );
		break;
		case "fr":
			Patcher.ShowExternalURL( "http://www.thesecretworld.com/french/news" );
		break;
		default:
			Patcher.ShowExternalURL( "http://www.thesecretworld.com/news" );
		break;
	}
}

function GotoCommunity()
{
	switch(languageCode)
	{
		case "de":
			Patcher.ShowExternalURL( "http://www.thesecretworld.com/deutsch/community" );
		break;
		case "fr":
			Patcher.ShowExternalURL( "http://www.thesecretworld.com/french/community" );
		break;
		default:
			Patcher.ShowExternalURL( "http://www.thesecretworld.com/community" );
		break;
	}
}

function GotoSupport()
{
	Patcher.ShowExternalURL( "http://www.thesecretworld.com/support" );
}

function GotoForums()
{
	switch(languageCode)
	{
		case "de":
			Patcher.ShowExternalURL( "http://forums-de.thesecretworld.com/" );
		break;
		case "fr":
			Patcher.ShowExternalURL( "http://forums-fr.thesecretworld.com/" );
		break;
		default:
			Patcher.ShowExternalURL( "http://forums.thesecretworld.com/" );
		break;
	}
}