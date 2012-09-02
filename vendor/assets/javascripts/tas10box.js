//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require 3rdparty/jsrender
//= require 3rdparty/jquery-ui.min
//= require 3rdparty/jquery.tipsy
//= require 3rdparty/jquery.timeago
//= require 3rdparty/moment.min
//= require 3rdparty/jquery.dragtable
//= require tools/center
//= require tas10
//= require_self
//= require tas10_browser_actions
//= require jsrender_tags_helpers
//= require widgets/tas10_container
//= require widgets/tas10_find
//= require widgets/tas10_script
//= require widgets/tas10_inline_edit
//= require widgets/tas10_navbar
//= require widgets/tas10_new
//= require widgets/tas10_combobox
//= require widgets/tas10_labeling
//= require widgets/tas10_acl
//= require widgets/tas10_list
//= require widgets/tas10_tree
//= require widgets/tas10_table
//= require i18n
//= require i18n/translations

$( function(){

  // oldversion: $.i18n.init({ fallbackLng: 'en', useLocalStorage: false }, function(t){} );

  $('.js-get-focus:last').focus();
  $('.live-tipsy').tipsy({live: true});
  $('.live-tipsy-e').tipsy({live: true, gravity: 'e'});
  $('.live-tipsy-w').tipsy({live: true, gravity: 'w'});

  $('.tas10-checkbox').live('click', function(e){
    $(this).toggleClass('checked');
  });

  $('.comment-form-trigger').live('click', function(){
    $(this).closest('tr').next('tr').show().find('textarea').focus();
    $(this).closest('tr').hide();
  })
  $('.comment-form-close').live('click', function(){
    $(this).closest('tr').prev('tr').show();
    $(this).closest('tr').hide();
  })
  $('.add-button').live('hover', function(){
    $(this).attr('src', $(this).attr('src').replace('.png','h.png') );
  }, function(){
    $(this).attr('src', $(this).attr('src').replace('h.png','.png') );
  })

  
  $('.starred').live('click', function(){
    var self = this
    $.ajax({ url: '/document/'+$(self).data('id'),
         type: 'put',
         dataType: 'json',
         data: { _csrf: $('#_csrf').val(), document: {
          starred: $(this).find('.tas10-icon16').hasClass('tas10-icon-star-empty') 
         } },
         success: function( data ){
          if( data.flash.info.length > 0 )
            if( data.doc.starred ){
              $('.starred[data-id='+$(self).data('id')+']').find('.tas10-icon16').addClass('tas10-icon-star-full').removeClass('tas10-icon-star-empty');
              $('#tas10-favourits-list').tastenboxList('append', data.doc, {short: true});
            } else{
              $('.starred[data-id='+$(self).data('id')+']').find('.tas10-icon16').addClass('tas10-icon-star-empty').removeClass('tas10-icon-star-full');
              $('#tas10-favourits-list').find('[data-id='+data.doc._id+']').remove(); 
            }
          tas10.flash(data.flash);
         }})
  })

  $('.tas10-checkbox-label').live('click', function(e){
    $(this).prev('.tas10-checkbox').toggleClass('checked');
  });


  $('input.tas10-current-tag').val('');
  $('#tas10-tab-container').tas10Container();

  function hideAjaxLoader(e){
    $('.ajax-loading').each(function(){
      $(this).html($(this).data('orig')).removeClass('ajax-loading').attr('disabled',false);
    });
      $('.tab-close').removeClass('loading');
  }

  function setupAjaxHelpers(){
    
    $(document).bind("ajaxSend", function(e, req){
      tas10.pushLoaderTimeout();
    }).bind("ajaxComplete", function(e, req){
      tas10.pullLoaderTimeout();
    }).bind("ajaxError", function(e, xhr){
      hideAjaxLoader(e);
      if( xhr.status === 0 )
        tas10.notify('You are offline!!\n Please Check Your Network.', true);
      else if( xhr.status in [401,403] ){
        console.log('we are having a 401')
        window.location = '/login';
      }
      //else if( xhr.status === 404 )
      //  tas10.notify('Destination target could not be found', true);
      else if( xhr.status === 500 )
        tas10.notify('Unexpected server error - We have been notified!', true);
      else if( e === 'parsererror' )
        tas10.notify('Error.\nParsing JSON Request failed.', true);
      else if( e === 'timeout' )
        tas10.notify('Request Time out.', true);
    });
    $('.ajax-button').live('click', function(){
      $(this).addClass('want-to-load-ajax');
    });

  }

  setupAjaxHelpers();

  $(document).bind('click', function(e){
    $('.tipsy').remove();
    if( $(e.target).attr('id') === 'tas10-overlay' && $('#tas10-dialog').is(':visible') ){
      $('#tas10-dialog').hide();
      $('#tas10-overlay').hide();
    }
  }).bind('keydown', function(e){
      // ESC
      if ( e.keyCode === 27 ){
        if( $('.tas10-inline-edit-form').length )
          $('.tas10-inline-edit-form').remove()
        else if( $('.tas10-acl-form').length )
          $('.tas10-acl-form').remove()
        else if( $('.tas10-labels-form').length )
          $('.tas10-labels-form').remove()
        else if( $('#tas10-dialog').is(':visible') )
          tas10.dialog('close');
        else if( $('#tas10-find .label-res').length )
          $('#tas10-find .label-res').remove();
        else if( $('.selected-item').length ){
          $('.selected-item').removeClass('selected-item');
          tas10.setPath([]);
        }
      }
  });

});