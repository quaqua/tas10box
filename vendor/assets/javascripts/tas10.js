var tas10 = {

  'userCan': function(obj, priv){
    return ($(obj) && $(obj).attr('data-privileges') && $(obj).attr('data-privileges').indexOf('w') > 0)
  },

  'cleanupCreateForms': function(){
    $('.create-form input[type=text]').val('');
  },

  calcHeight: function(){
    return $(window).height()-75;
  },

  'disabledContextMenuItems': {},

  'dashboard': function( action ){
    if( action === 'reload' ){
      $('#tas10-dashboard').load('/dashboard/reload', function reloadDashboard(){
        tas10.dashboard('show');
      });
    } else if ( action === 'hide' ){
      $('#tas10-dashboard').fadeOut({easing: 'easeOutQuart'});
      $('#tas10-tab-container').fadeIn({easing: 'easeOutQuart'});
    } else if ( action === 'show' ){
      $('#tas10-tab-container').fadeOut({easing: 'easeOutQuart'});
      $('#tas10-dashboard').fadeIn({easing: 'easeOutQuart'});
    }

  },

  'ajaxLoad': function( elem ){
    var method = $(elem).attr('data-method') || 'get'
      , data = null;
    if( $(elem).attr('data-method') !== 'get' )
      data = {_csrf: $('#_csrf').val()};
      $.ajax({ url: $(elem).attr('href'),
           dataType: 'script',
           type: method,
           data: data
      });
  },

  'clipboard': function tas10Clipboard( action, item ){
    if( action === 'push'){
      tas10.clipboardStore = this.clipboardStore || [];
      tas10.clipboardStore.push( item );
      $('.browser-actions .paste').removeClass('disabled');
      tas10.disabledContextMenuItems.paste = true;
      $(item).attr('data-orig-label-id', $(item).closest('.tab-content').attr('id') );
      if( $(item).attr('data-move') )
        $(item).remove();
    } else if( action === 'pullAll'){
      $('.browser-actions .paste').addClass('disabled');
      var cb = tas10.clipboardStore;
      tas10.clipboardStore = [];
      return cb;
    } else if( action === 'size' ){
      return (tas10.clipboardStore ? tas10.clipboardStore.length : 0);
    }
    console.log('clipboardstore', tas10.clipboardStore);
  },

  'appendToList': function( data ){
    for( var i in data.label_ids)
      $('#tab_content_'+data.label_ids[i]+' .tas10-list').prepend( 
        $( tas10.getListTemplate( data )).render( data ) 
      );
    if( data.label_ids.length < 1 )
      $('#tab_content_home .tas10-list').prepend( $( tas10.getListTemplate( data )).render( data ) );
    $('li.list-item[data-id='+data._id+']').effect('highlight', { duration: 3000, color: '#fc6' })
  },

  'moveCopyElem': function moveCopyElem( labelId, elem ){
    if( labelId.indexOf('search') >= 0 ){
      tas10.notify(I18n.t('errors.cannot_move_or_copy_here'), 'error');
      $('#'+$(elem).attr('data-orig-label-id') + ' .tas10-list').prepend(elem);
      return;
    }
    var newContainer = $('#tab_content_'+labelId);

    $.ajax({url: '/documents/' + $(elem).data('id') + '/labels',
            data: { from_id: $(elem).attr('data-move'), label_id: labelId },
            type: 'post',
            dataType: 'script'
    });

  },

  'pushLoaderTimeout': function pushLoaderTimeout(){
    this.loaderWaiting || (this.loaderWaiting = []);
    this.loaderWaiting.push( function(){ tas10.loader(true); } );
    setTimeout( function runPendingLoaders(){ tas10.runWaitingLoaders( tas10.loaderWaiting.length-1 ); }, 1000 );
  },

  'pullLoaderTimeout': function pushLoaderTimeout(){
    if( this.loaderWaiting )
      this.loaderWaiting.pop();
    this.loader(false);
  },

  'runWaitingLoaders': function runWaitingLoaders( pos ){
    if( this.loaderWaiting && this.loaderWaiting.length > pos && this.loaderWaiting[ pos ] )
      this.loaderWaiting[ pos ]();
  },

  'setupCheckbox': function setupCheckbox( elem ){

    var input = $('<input type="checkbox" name="'+$(elem).attr('data-name')+'" />');
    input.hide();
    $(elem).after(input);

    $(elem).on('click', function(){
      if( $(elem).find('.tas10-checkbox').length )
        $(elem).find('.tas10-checkbox').toggleClass('checked');
      var checkbox = $(this).next('input[type=checkbox]');
      checkbox.attr('checked', !checkbox.attr('checked'));
    })

  }


};

tas10['getURIParam'] = function getURIParam( name ){
  return decodeURI(
    (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
  );
};

tas10['notify'] = function tas10Notify( msg, error ){
  var notifier = '#tas10-notifier';
  if( error )
    $(notifier).addClass('error');
  else
    $(notifier).removeClass('error');
  $('#tas10-notifier .content').html(msg);
  //$(notifier).clearQueue().stop(true, true).css('zIndex', 10002).show().delay(3000).animate({'zIndex': 9998});
  $(notifier).show();
  $(notifier).find('.wrapper').clearQueue().stop(true, true).switchClass('low','high', 0)
    .delay(2000).switchClass('high','low', 600, 'easeOutBack');
}

tas10['flash'] = function tas10Flash( flash ){
  if( flash.notice && (flash.notice instanceof Array) && flash.notice[0] )
    tas10.notify(flash.notice[flash.notice.length-1].replace(/\'/,"\'"));
  if( flash.error && (flash.error instanceof Array) && flash.error[0] )
    tas10.notify(flash.error[flash.error.length-1].replace(/\'/,"\'"),true);
}

tas10['loader'] = function tas10Loader( show ){
  if( show ){
    $('#tas10-logo').addClass('loading');
    $('#tas10-loader').show();
  } else {
    $('#tas10-loader').hide();
    $('#tas10-logo').removeClass('loading');
  }
}

tas10['confirm'] = function tas10Confirm( msg, callback ){
  var really = confirm(msg);
  if( really )
    callback();
}

tas10['prompt'] = function tas10Prompt( msg, text, callback ){
  var inputText = prompt(msg, text);
  if( inputText && inputText.length > 0 )
    callback( inputText );
  else
    tas10.notify( 'aborted' );
}

tas10['infoDialog'] = function tas10InfoDialog(id){
  $.getScript( '/documents/'+id+'/info' );
}

tas10['shareDialog'] = function tas10ShareDialog(id){

  $.ajax({ url: '/documents/'+id, dataType: 'json',
       success: function( data ){
        tas10.dialog( 'new', $('#document-share-template').tmpl( data ),
          function( data ){
            setupTBColorPicker();
            $('#tas10-dialog abbr.timeago').timeago();  
            $('.strftime').strftime('%A, %d. %b %Y - %H:%M:%S');
          }
         );
       }
  });

}

tas10['dialog'] = function tas10Dialog( action, text, callback ){

  if( typeof(text) === 'object' ){
    title = text.title;
    text = text.content || text.url;
  }

  if( action === 'close' ){
    $('#tas10-overlay').hide();
    $('#tas10-dialog').hide().html('');
    return;
  }

  if( action === 'load' ){
    $('#tas10-dialog').load( text, function( htmldata ){
      tas10.dialog( 'new', { title: title, content: htmldata }, callback );
    });
  }

  $('#tas10-overlay').show();
  $('#tas10-dialog').show().html('<img src="/assets/loading_50x50.gif" class="loading" />').center();

  $('#tas10-dialog').html('<div class="close-button float-right"><span class="ui-icon ui-icon-closethick float-right" onclick="$(\'#tas10-dialog\').hide(); $(\'#tas10-overlay\').hide();"></span></div>');
  if( title ){
    var title = $('<div class="tas10-dialog-header" />').html( title );
    $('#tas10-dialog').append( title );
  }
  var content = $('<div class="tas10-dialog-content" />').append( text );
  $('#tas10-dialog').append( content );

  if( typeof( action ) === 'object' ){
    var l = $(action).offset().left + ($(action).outerWidth() / 2 ) - ($('#tas10-dialog').outerWidth() / 2);
    if( l < 10 )
      l = 10;
    var off = ( 375 - $('#tas10-dialog').outerWidth() ) / 2
      , bTop = $('<div class="border-top" />').css('backgroundPosition', '-'+(off + 10)+'px -4px');
    $('#tas10-dialog').css({ top: $(action).offset().top + $(action).outerHeight() + 20,
               left: l, borderTop: 'none' }).prepend(bTop).find('.ui-icon-closethick').remove();
  } else{
    if( $('#tas10-dialog').height() > $(window).height() )
      $('#tas10-dialog .tas10-dialog-content').css('height', $(window).height() - 150 );
    else
      $('#tas10-dialog .tas10-dialog-content').css('max-height', $(window).height() - 150 );
    $('#tas10-dialog').center();
  }

  $('.tas10-datepicker').datepicker({
    firstDay: 1,
    dateFormat: 'yy-mm-dd'
  });

  if( !($('#tas10-dialog').hasClass('ui-draggable') ) )
    $('#tas10-dialog').draggable({handle: '.tas10-dialog-header'});
  
  $('#tas10-dialog .js-get-focus:visible:first').focus();
  
  if( typeof(callback) === 'function' )
    callback( $('#tas10-dialog') );

}

tas10['renameItem'] = function( name, id ){

  tas10.prompt(I18n.t('enter_name'), name, function(newName){
    $.ajax({ url: '/documents/' + id,
         type: 'put',
         data: {_csrf: $('#_csrf').val(), document: {name: newName}},
         dataType: 'json',
         success: function( data ){
          if( data.flash.info.length ){
            var doc = data.doc;
            if( doc && 'name' in doc )
              $('.item_'+doc._id+'_title').text(doc.name);
           }
           tas10.flash(data.flash);
         }
    });
  });

}

tas10['getPath'] = function tas10GetPath( elem ){
  var path = [{id: $(elem).data('id'), _type: $(elem).attr('data-_type'), name: $(elem).find('div.item-container:first .title').text()}];
  $(elem).parents('li.item').each( function( ){
    path.push({id: $(this).attr('data-id'), _type: $(this).attr('data-_type'), name: $(this).find('div.item-container:first .title').text()});
  });
  return path.reverse();
}

tas10['setPath'] = function tas10SetPath( path, append ){

  path || (path = []);
  if( path && path instanceof Array )
    for( var i in path )
      if( typeof(path[i].id) === 'undefined' || path[i].id.indexOf('_') === 0 )
        path.splice(i, 1);

  var tas10PathMarkup = "&nbsp;/&nbsp;<a href=\"/{{:_type ? _type.toLowerCase()+'s' : ''}}/{{:id}}\" data-remote=\"true\" class=\"item_{{:id}}_title\">{{:name}}</a>";
  var tas10FindMarkup = "<span class=\"label path-item item_{{:id}}_title\" data-id=\"{{:id}}\">{{:name}}</span>";
  $.templates("tas10Path", tas10PathMarkup);
  $.templates("tas10Find", tas10FindMarkup);

  if( append && typeof(path) === 'object' ){
    $('#tas10-find .path').append( $.render.tas10Find( path ) );
    $('.tas10-current-label').val(path.id);
    var labelVal = $('#tas10-find [name=label_ids]');
    $(labelVal).val( $(labelVal).val() + ($(labelVal).val().length > 0 ? ',' : '') + path.id );
    return;
  }

  $('.tas10-path').html('');
  if( path && path.length > 0 && 'id' in path[0] && path[0].id.length > 0 ){
    
    $('#tas10-find .path').html( $.render.tas10Find( path ) );
    for( var i in path )
      $('#tas10-find [name=label_ids]').val( path[i].id );


    $('.tas10-path').append( $.render.tas10Path( path ) );
    $('.tas10-current-label').val(path[path.length-1].id);
  } else{
    $('.tas10-current-label').val('');
    $('#tas10-find .path').html( $.render.tas10Find( path ) );
    $('#tas10-find [name=label_ids]').val( '' );
  }

}

$(function(){

  /**
   * liveDraggable
   * to make draggable event attach to items live
   */
  (function ($) {
     $.fn.liveDraggable = function (opts) {
        this.live("mouseover", function() {
           if (!$(this).data("init")) {
              $(this).data("init", true).draggable(opts);
           }
        });
        return $();
     };
  }(jQuery));

  /**
   * liveDroppable
   * to make draggable event attach to items live
   */
  (function ($) {
     $.fn.liveDroppable = function (opts) {
        this.live("mouseover", function() {
           if (!$(this).data("init")) {
              $(this).data("init", true).droppable(opts);
           }
        });
        return $();
     };
  }(jQuery));

})