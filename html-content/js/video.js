/*jslint plusplus: true */
(function () {
  'use strict';
  function togglePlay() {
    var video = document.getElementsByTagName('video');
    if (video.ended || video.paused) {
      video.play();
    } else {
      video.pause();
    }
  }

  function toggleControls() {
    var video = document.getElementsByTagName('video');
    if (video.controls) {
      video.removeAttribute('controls', 0);
    } else {
      video.controls = 'controls';
    }
  }

  // Touch and keyboard based controls and playback functions
  // A better way to get this working may be to use pointer events
  // If we ever get it or its equivalent implemented across browsers
  // See: http://caniuse.com/#search=pointer for more info
  window.onload = function () { //s/b jq  $(document).ready
    var video = document.getElementsByTagName('video');

    // Remove the controls and let the use double click to see them
    video.removeAttribute('controls', 0);

    // First attempt at using the page visibility API
    //
    // We first add an event listener for visibilitychange
    // to the document
    document.addEventListener('visibilitychange', function () {
      // If the document is hidden
      if (document.hidden) {
      // Then pause the video
        video.pause();
      }
      // If it's visible then don't do anything, it's up to
      // the user if they want the video to play or not.
    });

    // One click toggles video playback
    video.addEventListener('click', function (e) {
      e.preventDefault();
      togglePlay();
    }, false);

    //Double click toggles display of controls
    video.addEventListener('dblclick', function (e) {
      e.preventDefault();
      toggleControls();
    }, false);

    // If the user presses the spacebar toggle playback
    video.addEventListener('keyup', function (e) {
      var k = e ? e.which : window.event.keyCode;
      if (k === 32) {
        e.preventDefault();
        togglePlay();
      }
    }, false);
  };
}());
