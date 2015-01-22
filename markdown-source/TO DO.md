# Things to research

These are the things I want to look at after finishing mvp.

## Deep Linking using Emphasis

The NYT developed a deep linking library called Emphasis ([code](https://github.com/NYTimes/Emphasis) - [writeup](http://open.blogs.nytimes.com/2011/01/11/emphasis-update-and-source/)) that would allow us to create links to specific areas of our content. 

Downside is that it uses jQuery and I'm not certain I want to go through the pain in the ass process of converting it to plain JS or ES6 (and if it's even possible)

Still, if we use jQuery for something else (video manipulation?) it may be worth exploring both as a sharing tool and as a technology.

One thing it doesn't do is handle mobile well, if at all. How do we make this tool work everywhere? [Pointer Events](http://www.w3.org/TR/pointerevents/)?

## Build Media Queries 

Particularly if we want to use the same XSLT and CSS for mutliple projects we need to be able to tailor the display for different devices and viewports. 

Media Queries are the best solution (or are they?)

## Using XSLT to build navigation

The same way we build the table of content should allow us to build navigation within the pages of a publication using preceeding-sibling and following-sibling logic

## Create a better way to generate filenames

The current way to create filenames doesn't take into account that different `section/@type` elements have different starting values. Can I make it start from 1 for every @type in the document?

## Expand the use cases for this project

The original idea was for text and code-heavy content. Is there a case to be made for a more expressive vocabulary? I'm thinking of additional elements for navigation and content display such as asides and blockquotes

## Explore implementing a serviceworker solution for these projects

<iframe width="560" height="315" src="//www.youtube.com/embed/Rr2vXDIVerI" frameborder="0" allowfullscreen></iframe>

***Click the image to play the video***

The core of the proposed offline capabilities is a scoped service worker that will initially handle the caching of the publication's content. We take advantage of the multiple cache capabilitity available with service workers to create caches for individual unitts of content (like magazine issues) and to expire them within a certain time period (by removing and deleting the cache).

For publications needing to pull data from specific URLs we can special case the requests based on different pieces of the URL allowing to create different caches based on edition (assuming each edition is stored in its own directory), resource type or even the URL we are requesting.

Serviceworkers have another benefit not directly related with offline connections. They will give all access to our content a speed boost by eliminating the network roundtrip after the content is installed. If the content is in the cache, the resource's time to load is only limited by the Hard Drive's speed.

This is what the ServiceWorker code looks like in the demo application:

```javascript
//
// ATHENA DEMO SERVICE WORKER
//
// @author Carlos Araya
// @email carlos.araya@gmail.com
//
// Based on Paul Lewis' Chrome Dev Summit serviceworker. 

importScripts('js/serviceworker-cache-polyfill.js');

// This is one best practice that can be followed in general 
// to keep track of multiple caches used by a given service 
// worker, and keep them all versioned.  maps a shorthand 
// identifier for a cache to a specific, versioned cache name.

// Note that since global state is discarded in between 
// service worker restarts, these variables will be reinitialized 
// each time the service worker handles an event, and you should 
// not attempt to change their values inside an event 
// handler. (Treat them as constants.)

// If at any point you want to force pages that use this service 
// worker to start using a fresh cache, then increment the 
// CACHE_VERSION value. It will kick off the service worker 
// update flow and the old cache(s) will be purged as part of 
// the activate event handler when the updated service worker 
// is activated.

// In this demo, we also cache two links from O'Reilly. Normally 
// I wouldn't do this but it's mean to illustrate a point later 
// in the rationale document
var CACHE_NAME = 'athena-demo';
var CACHE_VERSION = 8;

self.oninstall = function(event) {

  event.waitUntil(
    caches.open(CACHE_NAME + '-v' + CACHE_VERSION).then(function(cache) {

      return cache.addAll([
        '/athena-framework/',
        '/athena-framework/bower_components/',
        '/athena-framework/css/',
        '/athena-framework/js/',
        '/athena-framework/layouts/',

        '/athena-framework/content/',
        '/athena-framework/index.html',
        '/athena-framework/notes.html',

        'http://chimera.labs.oreilly.com/books/1230000000345/ch12.html',
        'http//chimera.labs.oreilly.com/books/1230000000345/apa.html'
      ]);
    })
  );
};

self.onactivate = function(event) {

  var currentCacheName = CACHE_NAME + '-v' + CACHE_VERSION;
  caches.keys().then(function(cacheNames) {
    return Promise.all(
      cacheNames.map(function(cacheName) {
        if (cacheName.indexOf(CACHE_NAME) == -1) {
          return;
        }

        if (cacheName != currentCacheName) {
          return caches.delete(cacheName);
        }
      })
    );
  });

};

self.onfetch = function(event) {
  var request = event.request;
  var requestURL = new URL(event.request.url);

  event.respondWith(

    // Check the cache for a hit.
    caches.match(request).then(function(response) {

      // If we have a response return it.
      if (response)
        return response;

      // Otherwise fetch it, store and respond.
      return fetch(request).then(function(response) {

        var responseToCache = response.clone();

        caches.open(CACHE_NAME + '-v' + CACHE_VERSION).then(
          function(cache) {
            cache.put(request, responseToCache).catch(function(err) {
              // Likely we got an opaque response which the polyfill
              // can't deal with, so log out a warning.
              console.warn(requestURL + ': ' + err.message);
            });
          });

        return response;
      });

    })
  );
};
```
### Limitations

As powerful as service workers are they also have some drawbacks. They can only be served through HTTPS (you cannot install a service worker in a non secure server) to prevent [man-in-the-middle attacks](http://www.wikiwand.com/en/Man-in-the-middle_attack).

There is limited support for the API (only Chrome Canary and  Firefox Nightly builds behind a flag will work.) This will change as the API matures and becomes finalized in the WHATWG and/or a recommendation with the W3C. 

Even in browsers that support the API the support is not complete. Chrome uses a polyfill for elements of the cache API that it does not support natively. This should be fixed in upcoming versions of Chrome and Chromium (the open source project Chrome is based on.)

We need to be careful with how much data we choose to store in the caches. From what I understand the ammount of storage given to offline applications is divided between all offline storage types: IndexedDB, Session Storage, Web Workers and ServiceWorkers and this amount is not consistent across all browsers. 

Furthermore I am not aware of any way to increase this total amount or to specifically increase the storage assigned to ServiceWorkers; Jake Archibald mentions this in the offline cookbook section on [cache persistence](http://jakearchibald.com/2014/offline-cookbook/#cache-persistence)
