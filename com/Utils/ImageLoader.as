intrinsic class com.Utils.ImageLoader
{
  /// Request an image to be loaded from the RDB. The first argument is the RDB ID for the texture (type/instance). The next two is
  /// an object and the name of a method on that object that will be called when the image is done loading.
  /// After the callbackFunc argument you can pass in any number of aditional arguments. Any additional arguments will be passed
  /// on to the callback function.
  ///
  /// When the image has been loaded callbackObj.callbackFunc() will be called. The callback will be passed a temporary
  /// URL that can be used in the normal loading API's to retrieve the actual image, and a boolean that will be true if
  /// the loading succeded, and false if the loading failed. After the boolean any extra arguments passed to RequestRDBImage()
  /// will be passed.
  ///
  /// The callback should look something like this:
  ///    function ImageLoaded( url:String, succeded:Boolean, extraArg1:ExtraArg1Type, extraArg2:ExtraArg2Type, ... ) {}
  ///
  /// And RequestRDBImage() is called like this:
  ///    ImageLoader.RequestRDBImage( new com.Utils.ID32( TypeID, InstanceID ), this, "ImageLoaded", "foo", 42 );
  ///
  ///@author Kurt Skauen

  
    static public function RequestRDBImage( textureID:com.Utils.ID32, callbackObj:Object, callbackFunc ) : String;
    static public function StartAnimation( url:String ) : Void;
    static public function StopAnimation( url:String, stopTime:Number ) : Void;  
}

