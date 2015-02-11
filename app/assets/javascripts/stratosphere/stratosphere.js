/*
 * Intended for use with the Stratosphere Ruby Gem
 * Copyright (c) 2015 Zachary Golba (zak@zacharygolba.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

window.Stratosphere = function() {
  'use strict';
  
  function Stratosphere(modelName, modelId, attachmentName) {
    var csrfMeta        = document.querySelectorAll('meta[name=csrf-token]')[0];
    this.file           = null;
    this.csrfToken      = !!csrfMeta ? csrfMeta.getAttribute('content') : '';
    this.modelId        = modelId;
    this.modelName      = modelName;
    this.attachmentName = attachmentName;
  }

  Stratosphere.activate = function() {
    var $uploadContainer = jQuery('*[data-stratosphere-enabled="true"]');

    if ( $uploadContainer.length > 0 ) {
      var stratosphere = new Stratosphere( $uploadContainer.data('modelName'), $uploadContainer.data('modelId'), $uploadContainer.data('attachmentName') );
      var $fileInput = $uploadContainer.find("input[type='file']");
      
      var uploadFile = function(file) {
        if ( !!file ) {
          var $uploadControls = $uploadContainer.find('.upload-controls');
          var $uploadProgress = $uploadContainer.find('.upload-progress');
          var $progressBar    = $uploadProgress.find('.progress-bar');

          $uploadControls.css('display', 'none');
          $uploadProgress.css('display', 'block');

          stratosphere.upload(file, $progressBar[0]).then(function (attachment) {
            var successful = !!attachment && attachment.hasOwnProperty('url') && attachment.hasOwnProperty('name') && attachment.hasOwnProperty('type');

            if ( successful ) {
              $uploadContainer.find('.current-attachment a').html(attachment.name);
              $uploadContainer.find('.current-attachment a').attr('href', attachment.url);
              if ( /^image\/.+/g.test(attachment.type) ) {
                $uploadContainer.find('.current-attachment img').attr('src', attachment.url);
              }
            }

            $uploadControls.css('display', '');
            $uploadProgress.css('display', 'none');
            $uploadContainer.find('.current-attachment').css('display', 'inline-block');
            $uploadContainer.find('*[data-stratosphere-action="delete"]').css('display', '');

            $fileInput.val('');

            setTimeout(function () {
              $progressBar[0].setAttribute('aria-valuenow', '0');
              $progressBar[0].style.width = 0;
            }, 500);

          }, function (error) {
            console.log(error);
          });

        } else {
          stratosphere.file = null;
        }
      };

      $uploadContainer.find('button').on('click', function (e) {
        var $target = jQuery(e.target);

        e.preventDefault();

        if ( $target.data('stratosphereAction') === 'upload' ) {
          $fileInput.trigger('click');
        }

        if ( $target.data('stratosphereAction') === 'delete' ) {
          if ( window.confirm('Are you sure you want to delete this attachment?') ) {

            stratosphere.deleteAttachment().then(function () {
              $uploadContainer.find('.current-attachment').css('display', 'none');
              $uploadContainer.find('*[data-stratosphere-action="delete"]').css('display', 'none');
            });

          }
        }
      });

      $fileInput.on('change', function () {
        uploadFile($fileInput[0].files[0]);
      });
    }
  };

  Stratosphere.deactivate = function() {
    var $uploadContainer = jQuery('*[data-stratosphere-enabled="true"]');

    if ($uploadContainer.length > 0) {
      $uploadContainer.find("input[type='file']").off('change');
      $uploadContainer.find('button').off('click');
    }
  };

  Stratosphere.prototype.getUploadUrl = function() {
    var self = this;
    
    return new RSVP.Promise(function(resolve, reject) {
      if ( !!self.file ) {
        jQuery.ajax({
          type: 'GET',
          url: '/' + self.modelName.pluralize() + '/' + self.modelId + '/edit',
          data: {
            'file_name': self.file.name,
            'content_type': self.file.type,
            'content_length': self.file.size,
            'stratosphere_submitted': true
          },
          headers: {
            'X-CSRF-Token': self.csrfToken
          }
        }).done(function ( data, textStatus, jqXHR  ) {
          if (  jqXHR.status >= 200 && jqXHR.status < 400  ) {
            if ( data.hasOwnProperty('url') ) {
              resolve(data.url);
            } else {
              reject(null);
            }
          } else {
            reject(jqXHR);
          }
        });
      } else {
        reject(null);
      }
    });
  };

  Stratosphere.prototype.upload = function(file, progressBar) {
    var self = this;
    
    if ( progressBar === null ) {
      progressBar = null;
    }
    
    this.file = file;

    return new RSVP.Promise(function (resolve, reject) {
      self.getUploadUrl().then(function (url) {
        var xhr = new XMLHttpRequest();
        
        xhr.open('PUT', url, true);

        xhr.setRequestHeader('Accept', '*/*');
        xhr.setRequestHeader('Content-Type', file.type);

        xhr.onload = function() {
          if ( xhr.status >= 200 && xhr.status < 400 ) {
            self.updateModel().then(function (didUpdate) {
              if ( didUpdate ) {
                resolve( { url: url.split('?')[0], name: self.file.name, type: self.file.type } );
              } else {
                reject(null);
              }
            }, function () {
              reject(null);
            });
          } else {
            reject(null);
          }
        };

        if ( !!progressBar && xhr.upload ) {
          var $upload = jQuery(xhr.upload);

          $upload.on('progress', function (e) {
            if ( e.originalEvent.lengthComputable ) {
              var p = e.originalEvent.loaded / e.originalEvent.total * 100;
              progressBar.setAttribute('aria-valuenow', '' + p);
              progressBar.style.width = p + '%';
            }
          });

          $upload.on('load', function () {
            $upload.off('progress');
            $upload.off('load');
          });
        }
        
        xhr.send(file);
      }, function () {
        reject(null);
      });
    });
    
  };

  Stratosphere.prototype.updateModel = function() {
    var self = this;
    
    return new RSVP.Promise(function (resolve, reject) {
      if ( !!self.file ) {
        var params = {
          'stratosphere_submitted': true
        };

        params[ self.attachmentName + '_file' ] = self.file.name;
        params[ self.attachmentName + '_content_type' ] = self.file.type;
        params[ self.attachmentName + '_content_length' ] = self.file.size;

        jQuery.ajax({
          type: 'PATCH',
          url: '/' + self.modelName.pluralize() + '/' + self.modelId,
          data: params,
          headers: {
            'X-CSRF-Token': self.csrfToken,
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
          }
        }).done(function ( data, textStatus, jqXHR  ) {
          if ( jqXHR.status >= 200 && jqXHR.status < 400 ) {
            resolve(true);
          } else {
            reject(jqXHR);
          }
        });
      } else {
        reject( false );
      }
    });
  };

  Stratosphere.prototype.deleteAttachment = function() {
    var self = this;

    return new RSVP.Promise(function (resolve, reject) {
      var params = {
        'stratosphere_submitted': true
      };

      params[ self.attachmentName + '_file' ] = null;
      params[ self.attachmentName + '_content_type' ] = null;
      params[ self.attachmentName + '_content_length' ] = null;
      
      jQuery.ajax({
        type: 'PATCH',
        url: '/' + self.modelName.pluralize() + '/' + self.modelId,
        data: params,
        headers: {
          'X-CSRF-Token': self.csrfToken,
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        }
      }).done(function ( data, textStatus, jqXHR  ) {
        if ( jqXHR.status === 200 ) {
          resolve(true);
        } else {
          reject(jqXHR);
        }
      });
    });
  };

  return Stratosphere;

}();

if ( !!window.jQuery ) {
  if ( !!window.Turbolinks ) {
    jQuery(document).on('page:change', function() {
      Stratosphere.activate();
    });
    jQuery(document).on('page:before-unload', function() {
      Stratosphere.deactivate();
    });
  } else {
    jQuery(document).ready(function() {
      Stratosphere.activate();
    });
  }
} else {
  console.error('jQuery not detected. Make sure you include stratosphere/main after jquery.');
}