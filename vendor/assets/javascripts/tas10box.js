//= require jquery
//= require jquery-ui
//= require tools/center
//= require tas10
//= require widgets/tas10_container
//= require widgets/tas10_find
//= require widgets/tas10_inline_edit
//= require widgets/tas10_navbar
//= require widgets/tas10_new
//= require widgets/tas10_tree
//= require 3rdparty/jquery-ui.min
//= require 3rdparty/jquery.tipsy
//= require i18n
//= require i18n/translations
//= require_self

$( function(){

  // oldversion: $.i18n.init({ fallbackLng: 'en', useLocalStorage: false }, function(t){} );

  $('.js-get-focus:last').focus();
  $('.live-tipsy').tipsy({live: true});
  $('.live-tipsy-e').tipsy({live: true, gravity: 'e'});
  $('.live-tipsy-w').tipsy({live: true, gravity: 'w'});

  $('.tas10-checkbox').live('click', function(e){
    $(this).toggleClass('checked');
  });

  
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
      var elem = e.currentTarget.activeElement;
      if( $('.tab.active').length )
        $('.tab.active').find('.tab-close').addClass('loading');
      tas10.loader(true);
      $('.want-to-load-ajax').each(function(){
        $(this).removeClass('want-to-load-ajax').attr('disabled',true).addClass('ajax-loading').data('orig',$(this).html()).html('<img src="/assets/loading-small.gif" />');
      });
    }).bind("ajaxComplete", function(e, req){
      hideAjaxLoader(e);
      tas10.loader(false);
    }).bind("ajaxError", function(e, xhr){
      hideAjaxLoader(e);
      if( xhr.status === 0 )
      tas10.notify('You are offline!!\n Please Check Your Network.', true);
      else if( xhr.status in [401,403] )
        location = '/login';
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

    $('form[data-remote=true]').live('submit', function(e){
      e.preventDefault();
      $.ajax({ url: $(this).attr('action'),
           dataType: 'script',
           data: $(this).serializeArray(),
           type: $(this).attr('method') });
    });

    $('a[data-remote=true]').live('click', function(e){
      e.preventDefault();
      var elem = this;
      if( $(this).attr('data-confirm') )
        tas10.confirm( $(elem).attr('data-confirm'), function(){
          tas10.ajaxLoad( elem );
      });
      else
        tas10.ajaxLoad( this );
    })

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
        if( $('#tas10-dialog').is(':visible') )
            tas10.dialog('close');
          else if( $('#tas10-find .label-res').length )
            $('#tas10-find .label-res').remove();
        else if( $('.selected-item').length ){
            $('.selected-item').removeClass('selected-item');
            tas10.setPath([]);
          }
      }
  });

  // if ($.browser.webkit) {
  //   $('.login-container input').attr('autocomplete', 'off');

});