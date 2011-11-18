#Simple AS3 Recorder#

A voice recorder in Flash AS3 language.
Allows you to record a sound, listen to it and download it (as a WAV file).

Very simple yet efficient interface with 3 buttons : 

+   Record button
+   Play/Stop button
+   Download button

Every button activates when necessary (you obviously don't need a download button when you haven't recorded anything yet).

You can insert it in your web pages using the great [swfobject](http://code.google.com/p/swfobject/) javascript library like so : 
```javascript
var flashVars = {
    title : "My Badass Recorder"
}

swfobject.embedSWF("Simple-recorder.swf", "recorder", "320", "170", "10.0.0", null, flashVars);
```


Or you can play it old-school and use the ```<object>``` tag : 
```actionscript
<object type="application/x-shockwave-flash" data="Simple-recorder.swf" width="320" height="170">
    <param name="movie" value="Simple-recorder.swf" />
    <param name="width" value="320" />
    <param name="heigth" value="170" />
    <param name="flashVars" value="title=My%20Badass%20Recorder" />
</object>
```

