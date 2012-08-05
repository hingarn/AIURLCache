# What is AIURLCache?

AIURLCache is a class that extends NSURLCache to allow you to save specific resources on disk for later use. This results in
faster, more responsive user interfaces, especially in UIWebView.

## How it works 

When you specify the URL and MIME type AIURLCache will examine each request and either do default caching or save the file on disk
and next time you make the request it will return cached version from a disk. You can specify when the files expire. 

## Installation

Drag ```AIURLCache``` into your project. 

## Usage

(see sample Xcode project in ```/Demo```)

* Import ```AIURLCache.h"``` file in your ```AppDelegate.h``` file.
* In the ```(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions``` method 
instantiate ```AIURLCache``` class
```html
AIURLCache *sharedCache = [[AIURLCache alloc] initWithMemoryCapacity:[capacityInBytes] diskCapacity: [capacityInBytes] diskPath:@"[directoryName]"];
```
* Set URL and MIME type to cache
For example, if you would like to cache all ```.png``` files in ```http://www.mydomain.com/images```. 
```html
[sharedCache cacheResourcesForURL:@"http://www.mydomain.com/images" withMIMEType:png];
```

```AIURLCache``` provides enum for MIME types: 
```
png = image/png
jpeg,jpg = image/jpeg
css = text/css
js = application/javascript
allImages = image/jpeg or image/png 
all
```

* (Optionally) Set cache maximum age limit. Default is 1 week
This will set the cache to expire in two weeks. 
```html
    [sharedCache setMaxCacheAge:60*60*24*14];
```
* Set your app's cache to use ```AIURLCache```
```html
[NSURLCache setSharedURLCache:sharedCache];
```

## ARC Support

AIURLCache supports ARC. 

# License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.