var tas10 = {

  'userCan': function(obj, priv){
    return ($(obj) && $(obj).attr('data-privileges') && $(obj).attr('data-privileges').indexOf('w') > 0)
  },

  'cleanupCreateForms': function(){
    $('.create-form input[type=text]').val('');
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
  }

};

tas10['notify'] = function tas10Notify( msg, error ){
  var notifier = '#tas10-notifier';
  if( error )
    $(notifier).addClass('error');
  else
    $(notifier).removeClass('error');
  $('#tas10-notifier .content').html(msg);
  $(notifier).css('zIndex', 10002).show().delay(3000).animate({'zIndex': 9998});
  $(notifier).find('.wrapper').switchClass('low','high', 0)
    .delay(2000).switchClass('high','low', 600, 'easeOutBack');
}

tas10['flash'] = function tas10Flash( flash ){
  if( flash.info.length > 0 )
    tas10.notify(flash.info[flash.info.length-1]);
  if( flash.error.length > 0 )
    tas10.notify(flash.error[flash.error.length-1],true);
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

  if( action === 'close' ){
    $('#tas10-overlay').hide();
    $('#tas10-dialog').hide().html('');
    return;
  }

  $('#tas10-overlay').show();
  $('#tas10-dialog').show().html('<img src="/assets/loading_50x50.gif" class="loading" />').center();

  $('#tas10-dialog').html('<div class="close-button float-right"><span class="ui-icon ui-icon-closethick float-right" onclick="$(\'#tas10-dialog\').hide(); $(\'#tas10-overlay\').hide();"></span></div>');
  $('#tas10-dialog').append( text );

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
    $('#tas10-dialog').center();
  }

  $('.tas10-datepicker').datepicker({
    firstDay: 1,
    dateFormat: 'yy-mm-dd'
  });
  
  if( typeof(callback) === 'function' )
    callback();

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
  for( var i in path )
    if( typeof(path[i].id) === 'undefined' )
      path.splice(i, 1);

  var tas10PathMarkup = "&nbsp;/&nbsp;<a href=\"/{{:_type ? _type.toLowerCase()+'s' : ''}}/{{:id}}\" data-remote=\"true\" class=\"item_{{:id}}_title\">{{:name}}</a>";
  var tas10FindMarkup = "<span class=\"path-item item_{{:id}}_title\" data-id=\"{{:id}}\">{{:name}}</span>";
  $.templates("tas10Path", tas10PathMarkup);
  $.templates("tas10Find", tas10FindMarkup);

  if( append && typeof(path) === 'object' ){
    $('#tas10-find .path').append( $.render.tas10FindMarkup( path ) );
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