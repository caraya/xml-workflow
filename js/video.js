/*jslint plusplus: true */
(function () {
  'use strict';
  function togglePlay() {
    var video = document.getElementsByTagName('video')[0];
    if (video.ended || video.paused) {
      video.play();
    } else {
      video.pause();
    }
  }

  function toggleControls() {
    var video = document.getElementsByTagName('video')[0];
    if (video.controls) {
      video.removeAttribute('controls', 0);
    } else {
      video.controls = 'controls';
    }
  }

  /**
  * touch and keyboard based controls and playback functions
  */
  window.onload = function () { //s/b jq  $(document).ready
    var video = document.getElementsByTagName('video')[0];

    // Remove the controls and let the use double click to see them
    video.removeAttribute('controls', 0);

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
