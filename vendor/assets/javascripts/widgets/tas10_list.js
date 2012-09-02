tas10.getListTemplate = function getListTemplate( doc ){
  var name = '#'+doc._type.toLowerCase()+'-list-item-template';
  if( $(name).length )
    return name;
  else
    return '#default-list-item-template';
};


$(function(){

  $('.tas10-list-h .tas10-checkbox').live('click', function(e){
    var items = $(this).closest('.tas10-list-wrapper').find('li.list-item');
    if( $(this).hasClass('checked') )
      $(items).addClass('selected').find('.tas10-checkbox').addClass('checked');
    else
      $(items).removeClass('selected').find('.tas10-checkbox').removeClass('checked');
  });

  $('.tas10-list .tas10-checkbox').live('click', function(e){
    $(this).closest('li').toggleClass('selected').toggleClass('selected-item');
    $(this).closest('.tas10-list-wrapper').find('.browser-actions a').addClass('disabled');
    console.log('checking length ', $(this).closest('.tas10-list').find('.tas10-checkbox.checked').length );
    if( $(this).closest('.tas10-list').find('.tas10-checkbox.checked').length > 1 )
      $(this).closest('.tas10-list-wrapper').find('.browser-actions a.multi').removeClass('disabled');
    else if( $(this).closest('.tas10-list').find('.tas10-checkbox.checked').length === 1 )
      $(this).closest('.tas10-list-wrapper').find('.browser-actions a.single').removeClass('disabled');
    if( typeof(tas10.clipboardStore) === 'undefined' || (tas10.clipboardStore && tas10.clipboardStore.length == 0 ) )
      $(this).closest('.tas10-list-wrapper').find('.browser-actions a.paste').addClass('disabled');
  });

  $('.tas10-list li').liveDraggable({
    handle: '.title a',
    helper: 'clone',
    tolerance: 'pointer',
    appendTo: 'body',
    zIndex: 999,
    start: function( e, ui ){
      $(this).addClass('move');
      $(ui.helper).addClass('move-helper');
      $(ui.helper).append('<div class="move-copy">'+I18n.t('move_to')+'</div>').css('z-index', 999);
    },
    drag: function( e, ui ){
      if( e.ctrlKey ){
        $(this).removeClass('move').addClass('label-with');
        $(ui.helper).find('.move-copy').text(I18n.t('labels.add'));
      } else if( $(this).hasClass('label-with') ){
        $(this).removeClass('move').removeClass('label-with');
        $(ui.helper).addClass('move').find('.move-copy').text(I18n.t('move_to'));
      }
    },
    stop: function( e, ui ){
      $(ui.item).find('.move-copy').remove();
    }
  });

  $('#tas10-left-panel li.item .item-container').liveDroppable({
    greedy: true,
    hoverClass: "drop-hover",
    accept: ".list-item,.table-item",
    drop: function(event, ui){
      var id = $(this).closest('li').data('id');
      if( $(ui.draggable).hasClass('move') )
        $(ui.draggable).attr('data-move', id );
      tas10.moveCopyElem( id, ui.draggable );
    }
  })


});

(function( jQuery ){

  var setupTas10ListEvents = function(list){
  
    $('#' + $(list).attr('id') + ' li').live('mouseenter', function(e){
      if( $(this).hasClass('loading') )
        return;
      $('#tas10-table-item-details').remove();
      var itemDetails = $('<div id="tas10-table-item-details"/>');

      $(itemDetails).append('<a href="/documents/'+$(this).attr('data-id')+'" data-remote="true" original-title="'+I18n.t('show')+'"><span class="ui-icon ui-icon-arrow-1-e"></span></a>')
              .append('<a href="/documents/'+$(this).attr('data-id')+'/edit" data-remote="true" original-title="'+I18n.t('edit')+'"><span class="ui-icon ui-icon-pencil"></span></a>')
              .append('<a href="/documents/'+$(this).attr('data-id')+'" data-remote="true" data-method="delete" data-confirm="'+I18n.t('really_delete', {name: $(this).attr('data-title')})+'" original-title="'+I18n.t('delete')+'"><span class="ui-icon ui-icon-trash"></span></a>');        
      $('body').append(itemDetails);
      $(itemDetails).css({top: $(this).offset().top, left: $(this).offset().left - $(itemDetails).outerWidth() + 4});
      $(itemDetails).bind('mouseleave', function(){ 
        if( $(e.target).closest('#tas10-table-item-details').length )
          return;
        $(this).remove(); 
      });
    }).live('mouseleave', function(e){
      var newElem = e.toElement || e.relatedTarget;
      if( $(newElem).attr('id') && $(newElem).attr('id') === 'tas10-table-item-details' )
        return;
      $('#tas10-table-item-details').remove();
    });

    $('#' + $(list).attr('id')).closest('.action-container').find('.refresh').bind('click', function(){
      $('#' + $(list).attr('id')).tas10List('reload');
    });

    if( tas10.clipboardStore && tas10.clipboardStore.length )
      $(list).closest('.action-container').find('.paste').removeClass('disabled');

  };

  var tas10ListMethods = {

      init : function( options ) {

        if( $(this).hasClass('tas10-list-obj') || !$(this).is('ul') )
          throw new Error('not a ul element');

        if( $(this).data('id') && !options.id )
          options.id = $(this).data('id');

        if( !($(this).attr('id')) ){
          if( 'id' in options )
            $(this).attr('id', 'tas10-list-'+options.id );
          else
            $(this).attr('id', 'tas10-list-' + $(document).find('.tas10-table').length );
        }

        var settings = { page: 1, limit: 30 };
        if ( typeof(options) != 'undefined' ) {
          $.extend( settings, options );
        }
        $(this).data('settings', settings);

        $(this).addClass('tas10-list-obj');
        //$(this).css('height', $(this).closest('#tas10-left-panel').height()-50);

        setupTas10ListEvents( this );

      },
      reload : function() {
        var self = this
          , settings = $(self).data('settings');
        $(this).find('li').remove();

        // in case of provided :data
        if( settings.data ){
          $(self).append( $( tas10.getListTemplate( settings.data[0] )).render( settings.data ) );
          return;
        }

        $(this).html('<li class="loading"><img src="/assets/loading_50x50.gif" /></li>');
        
        // in case of url
        $.getJSON( $(self).data('settings').url, function( data ){
          for( var i in data ){
            if( $(self).data('settings').short )
              data[i].templ_short = true;
            try{
                $(self).append( $( tas10.getListTemplate( data[i] )).render( data[i] ) );
              } catch( e ){
                console.log(data[i].name + ', ' + data[i]._type);
                console.log(e);
              }
            }
            $(self).find('li.loading').remove();
        });
      },
      append : function( doc, options ) {
        var self = this;
        if( options && options.short )
          doc.templ_short = true;

        $(self).append( $( tas10.getListTemplate( doc )).render( doc ) );
        $('li[data-id='+doc._id+']').effect('highlight', {color: '#fc6'}, 2000);
      },
      unselectAll: function(){
        $('.selected-item').removeClass('selected-item');
      tas10.setPath([]);
      },
      select: function( itemId ){
        var item = $('li[data-id='+itemId+']');
        $('.selected-item').removeClass('selected-item');
      $(item).addClass('selected-item');
      tas10.setPath(tas10.getPath(item));
      }
    };

    jQuery.fn.tas10List = function( method ) {

      if ( tas10ListMethods[method] ) {
        return tas10ListMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
      } else if ( typeof method === 'object' || ! method ) {
        tas10ListMethods.init.apply( this, arguments );
        return tas10ListMethods.reload.apply( this );
      } else {
        $.error( 'Method ' +  method + ' does not exist on jQuery.tas10List' );
      }
    };

})( jQuery );