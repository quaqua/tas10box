
tas10['appendToList'] = function( data ){
  if( typeof( data.labels ) !== 'undefined' && data.labels.length > 0 && $('#tab_'+data.labels[0]).length )
    $('#tab_content_'+data.labels[0]+' .tas10-list').prepend( $( tas10.getListTemplate( data.labels[0] )).render( data.labels[0] ) );
  else
    $('#tab_content_home .tas10-list').prepend( $( tas10.getListTemplate( data )).render( data ) );
  $('li.list-item[data-id='+data._id+']').effect('highlight', { duration: 3000, color: '#fc6' })
};

tas10['clipboard'] = function( action, item ){
  if( action === 'push'){
    tas10.clipboardStore = this.clipboardStore || [];
    tas10.clipboardStore.push( item );
    $('.tas10-list-actions .paste').removeClass('disabled');
    tas10.disabledContextMenuItems.paste = true;
    $(item).attr('data-orig-tag-id', $(item).closest('.tab-content').attr('id') );
    if( $(item).attr('data-move') )
      $(item).remove();
  } else if( action === 'pullAll'){
    $('.tas10-list-actions .paste').addClass('disabled');
    var cb = tas10.clipboardStore;
    tas10.clipboardStore = null;
    return cb;
  } else if( action === 'size' ){
    return (tas10.clipboardStore ? tas10.clipboardStore.length : 0);
  }
}

tas10['moveCopyElem'] = function moveCopyElem( tagId, elem ){
  if( tagId.indexOf('search') >= 0 ){
    tas10.notify($.i18n.t('errors.cannot_move_or_copy_here'), 'error');
    $('#'+$(elem).attr('data-orig-tag-id') + ' .tas10-list').prepend(elem);
    return;
  }
  var newContainer = $('#tab_content_'+tagId);
  $.ajax({url: '/document/' + $(elem).data('id') + '/move',
          data: { from: $(elem).attr('data-move'),
              _csrf: $('#_csrf').val(),
              tag_id: tagId },
          type: 'post',
          dataType: 'json',
          success: function( data ){
            if( data.flash.info.length > 0 ){

              if( $(elem).attr('data-move') )
                $('li[data-id='+$(elem).data('id')+']').remove();

              if( data.doc.taggable )
                $('#tas10-browser-tree').tastenboxTree( 'append', data.doc );

              $(elem).data('move',null);
              $(elem).removeClass('selected').find('.tas10-checkbox').removeClass('checked');

              $(newContainer).find('.tas10-list').prepend(elem);
            }
            tas10.flash(data.flash);
          }
      })
}

tas10.getListTemplate = function getListTemplate( doc ){
  var name = '#'+doc._type.toLowerCase()+'-list-item-template';
  if( $(name).length )
    return name;
  else
    return '#default-list-item-template';
};



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
    if( $(this).closest('.tas10-list').find('.tas10-checkbox.checked').length > 1 )
      $(this).closest('.tas10-list-wrapper').find('.browser-actions a.multi').removeClass('disabled');
    else if( $(this).closest('.tas10-list').find('.tas10-checkbox.checked').length === 1 )
      $(this).closest('.tas10-list-wrapper').find('.browser-actions a.single').removeClass('disabled');
    if( typeof(tas10.clipboardStore) === 'undefined' || tas10.clipboardStore.length == 0 )
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
      $(ui.helper).append('<div class="move-copy">'+$.i18n.t('move_to')+'</div>').css('z-index', 999);
    },
    drag: function( e, ui ){
      if( e.ctrlKey ){
        $(this).removeClass('move').addClass('tag-with');
        $(ui.helper).find('.move-copy').text($.i18n.t('tag_with'));
      } else if( $(this).hasClass('tag-with') ){
        $(this).removeClass('move').removeClass('tag-with');
        $(ui.helper).addClass('move').find('.move-copy').text($.i18n.t('move_to'));
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

  $('.tas10-list-filter').live('click', function(e){
    if( $(this).find('ul').is(':visible') )
      $(this).removeClass('menu-open').find('ul').slideUp({easing: 'easeOutQuart', duration: 200});
    else
      $(this).addClass('menu-open').find('ul').slideDown({easing: 'easeInQuart', duration: 200});
  })
  
  $('.tas10-list-filter li').live('click', function(){
    var self = this;
    if( $(this).hasClass('invisible') ){
      $(this).closest('.tab-content').find('li[data-filter-type='+$(self).attr('data-filter').toLowerCase()+']')
      .show();
      $(self).removeClass('invisible').find('.ui-icon-check').css('opacity','0.5');
    } else {
      $(this).closest('.tab-content').find('li[data-filter-type='+$(self).attr('data-filter').toLowerCase()+']')
      .hide();
      $(self).addClass('invisible').find('.ui-icon-check').css('opacity','0');
    }
  })


});

(function( jQuery ){

  var setupTas10ListEvents = function(listItem){



  };

  var tas10ListMethods = {
      init : function( options ) {

        if( $(this).hasClass('tas10-list-obj') || !$(this).is('ul') )
          return;

        var settings = { url: ($(this).attr('data-url') || null), page: 1, pageCount: 30 };
        if ( typeof(options) != 'undefined' ) {
          $.extend( settings, options );
        }
        $(this).data('settings', settings);

        $(this).addClass('tas10-list-obj');
        $(this).css('height', $(this).closest('#tas10-left-panel').height()-50);

        setupTas10ListEvents( this );

      },
      reload : function() {
        var self = this;
      $.getJSON( $(self).data('settings').url, function( data ){
        for( var i in data ){
          if( $(self).data('settings').short )
            data[i].templ_short = true;
          try{
              $(self).append( $( tas10.getListTemplate( data[i] )).render( data ) );
            } catch( e ){
              console.log(data[i].name + ', ' + data[i]._type);
              console.log(e);
            }
          }
      });
      },
      append : function( doc, options ) {
        var self = this;
        if( options && options.short )
          doc.templ_short = true;

        $(self).append( $( tas10.getListTemplate( data[i] )).render( doc ) );
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

    jQuery.fn.tastenboxList = function( method ) {

      if ( tas10ListMethods[method] ) {
        return tas10ListMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
      } else if ( typeof method === 'object' || ! method ) {
        tas10ListMethods.init.apply( this, arguments );
        return tas10ListMethods.reload.apply( this );
      } else {
        $.error( 'Method ' +  method + ' does not exist on jQuery.tastenboxList' );
      }
    };

})( jQuery );