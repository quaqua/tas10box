$(function(){

  var setupTas10TableEvents = function( table ){

    $('#' + $(table).attr('id') + ' .tas10-checkbox').live('click', function(e){
      $(this).closest('tr').toggleClass('selected').toggleClass('selected-item');
      $(this).closest('.action-container').find('.browser-actions a').addClass('disabled');
      if( $(this).closest('.action-container').find('.tas10-checkbox.checked').length > 1 )
        $(this).closest('.action-container').find('.browser-actions a.multi').removeClass('disabled');
      else if( $(this).closest('.action-container').find('.tas10-checkbox.checked').length === 1 )
        $(this).closest('.action-container').find('.browser-actions a.single').removeClass('disabled');
      if( typeof(tas10.clipboardStore) === 'undefined' || tas10.clipboardStore.length == 0 )
        $(this).closest('.action-container').find('.browser-actions a.paste').addClass('disabled');
      $(this).closest('.action-container').find('.browser-preferences-context-trigger').removeClass('disabled');
    })

    $('#' + $(table).attr('id') + ' tbody tr').live('mouseenter', function(e){
      $('#tas10-table-item-details').remove();
      var itemDetails = $('<div id="tas10-table-item-details"/>');

      $(itemDetails).append('<a href="'+$(this).attr('data-url')+'" data-remote="true" original-title="'+I18n.t('show')+'"><span class="ui-icon ui-icon-arrow-1-e"></span></a>')
              .append('<a href="'+$(this).attr('data-url')+'/edit" data-remote="true" original-title="'+I18n.t('edit')+'"><span class="ui-icon ui-icon-pencil"></span></a>')
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

    $('#' + $(table).attr('id') + ' tbody tr').liveDraggable({
      handle: 'td',
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
          $(this).removeClass('move').addClass('tag-with');
          $(ui.helper).find('.move-copy').text(I18n.t('tag_with'));
        } else if( $(this).hasClass('tag-with') ){
          $(this).removeClass('move').removeClass('tag-with');
          $(ui.helper).addClass('move').find('.move-copy').text(I18n.t('move_to'));
        }
      },
      stop: function( e, ui ){
        $(ui.item).find('.move-copy').remove();
      }
    });

/*
    $('#' + $(table).attr('id')).closest('.action-container').find('.column-selector').on('click', function(e){
      if( $(e.target).hasClass('.column-content') || $(e.target).closest('.column-content').length > 0)
        return;
      $(this).find('.column-content').slideToggle(200);
    }).on('mouseleave', function(){
      $(this).find('.column-content').slideUp(200);
    });
*/

    $('#' + $(table).attr('id')).dragtable({ dataHeader: 'data-sort-key', change: function(e, ui){
      var options = $(table).data('options');
      tmpItems = $(this).dragtable('order');
      options.items = [];
      for( var i in tmpItems )
        if( options.items[i] !== '' )
          options.items.push( tmpItems[i] );
      $(table).data('options', options);
      }
    });

  }

  var tas10TableMethods = {

    load: function( url, callback ){
      var table = this;

      $.ajax({ url: url, 
        data: { sort: $(table).data('sort') || $(table).data('defaultSort'),
            page: parseInt($(table).data('curPage')),
            limit: $(table).data('curLimit') },
        success: function( data ){
          $(table).data('pages', data.pages);
          $(table).data('data', data.data);
          tas10TableMethods['fill'].call( table, data.data, callback );
        },
        dataType: 'json'
      });
    },

    fill: function( data, callback ){
      var options = $(this).data('options')
        , table = this
        , cc = $(table).closest('.action-container').find('.column-content');
      $(table).find('tbody tr').remove();
      $(cc).html(''); 

      for( var i in data ){
        var item = data[i];
        totalColumns = [];
        for( var j in data[i]){
          if(tas10TableMethods['specialTags'].indexOf(j) >= 0 )
            continue;
          totalColumns.push(j);
        }

      
        if( $(cc).html() === '' )
          for( var j in totalColumns ){
            var li = $('<li/>').attr('data-column', totalColumns[j]);
            var checkbox = $('<span class="tas10-icon16 tas10-icon-checkbox tas10-checkbox"></span>');
            for( var k in options.items )
              if( options.items[k] === totalColumns[j])
                $(checkbox).addClass('checked');
            $(li).append(checkbox).append('<span>'+I18n.t(options.i18nPrefix+totalColumns[j])+'</span>');
            $(cc).append(li);
            tas10TableMethods['setupColumnAction'].call( this, li );
          }

        tas10TableMethods['append'].call( this, data[i] );
      }

      tas10TableMethods['setupPageSelect'].call( this );

      if( callback )
          callback( this );
    },

    setupColumnAction: function( column ){
      var table = this;
      $(column).find(' .tas10-checkbox').on('click', function(e){
        var options = $(table).data('options')
          , items = options.items;
        if( $(this).hasClass('checked') )
          items.splice(options.items.indexOf($(this).closest('li').attr('data-column')),1);
        else
          items.push($(this).closest('li').attr('data-column'));
        options.items = [];
        for( var i in items )
          if( items[i] !== '' )
            options.items.push( items[i] );
        $(table).data('options', options);
        tas10TableMethods['setupHeaders'].call( table, options );
        tas10TableMethods['fill'].call( table, $(table).data('data') );
      });

    },

    specialTags: ['_id', 'columns', 'privileges', 'color', 'labelable',
    'acl', 'history', 'label_ids', 'public', 'taggable', 
    '_type', 'deleted_at', 'pos', 'starred', 'log_entries', 'versions', 'version'],

    append: function( elem ){
      var options = $(this).data('options');

      elem.columns = [];

      // in case if no options.items was passed, any column will be displayed apart from the special tags 
      for( var i in elem ){
        if(tas10TableMethods['specialTags'].indexOf(i) >= 0 )
          continue;
        elem.columns.push({ key: i, value: elem[i] });
      }

      if( options.items ){
        elem.columns = [];
        for( var i in options.items )
          if( options.items[i] in elem )
            elem.columns.push({ key: options.items[i], value: elem[options.items[i]]});
      }
      $(this).find('tbody').append( $('#default-table-item-template').render( elem ) );
    },

    setupSortSelect: function( options ){
      var table = this
        , sortSelect = $(table).closest('.action-container').find('.sort-filter');
      if( 'sortItems' in options ){
        for( var i in options.sortItems ){
          var option = $('<option />');
          $(option).val(options.sortItems[i]).text(I18n.t('sort_options.'+options.sortItems[i]));
          if( 'sort' in options && options.sort === options.sortItems[i] )
            $(option).attr('selected',true);
          $(sortSelect).each(function(){
            $(this).find('select').append($(option).clone());
          });
        }
        $(table).data('defaultSort', options.sort );
        $(sortSelect).show();
      } else
        $(sortSelect).hide();

      $(sortSelect).each(function(){
        $(this).find('select').bind('change', function(){
          $(table).data('sort', $(this).val());
          tas10TableMethods['load'].call( table, options.url );
          var thisSelect = this
            , selectedIndex = $(this)[0].selectedIndex;
          $(sortSelect).each(function(){
            if( thisSelect !== this )
              $($(this).find('option')[selectedIndex]).attr('selected', true);
          })
        })
      });
    },

    setupLimitSelect: function( options ){
      var table = this
        , limitSelect = $(table).closest('.action-container').find('.limit-selector select')
        , optionValues = [ 10, 30, 50, 100 ];
      for( var i in optionValues ){
        var option = $('<option value="'+optionValues[i]+'">'+optionValues[i]+'</option>');
        if( optionValues[i] === parseInt($(table).data('curLimit')) )
          $(option).attr('selected',true);
        $(limitSelect).append(option);
      }
      $(limitSelect).bind('change', function(){
        $(table).data('curLimit', parseInt($(this).find('option:selected').val()) );
        tas10TableMethods['load'].call( table, options.url );
      })
    },

    setupPageSelectEvents: function(){
      var table = this
        , pageSelect = $(table).closest('.action-container').find('.page-selector select');
      $(pageSelect).bind('change', function(){
        $(table).data('curPage', parseInt($(this).find('option:selected').val()) );
        tas10TableMethods['load'].call( table, $(table).data('url') );
      })
    },

    setupPageSelect: function(){
      var table = this
        , pages = $(table).data('pages')
        , pageSelect = $(table).closest('.action-container').find('.page-selector select');
      $(pageSelect).find('option').remove();
      for( var i = 1; i < pages+1 ; i++ ){
        var option = $('<option value="'+i+'">'+i+'</option>');
        if( $(table).data('curPage') === i )
          $(option).attr('selected', true);
        $(pageSelect).append(option);
      }
    },

    setupHeaders: function( options ){
      var table = this;

      var tr = $('<tr/>');
      $(tr).append('<th/>').append('<th/>');
      for( var i in options.items ){
        var th = $('<th/>').attr('data-sort-key', options.items[i]);
        if( options.items[i] ){
          if( 'sort' in options && options.sort === options.items[i] )
            $(th).addClass('current-sort');
          $(th).text(I18n.t(options.i18nPrefix+options.items[i]));
        }
        $(tr).append(th);
      }

      $(table).find('thead').remove()
      $(table).append($('<thead>').append(tr));
      $(table).find('thead th').on('click', function(){
        $(table).data('sort', $(this).attr('data-sort-key'));
        $(table).find('.current-sort').removeClass('current-sort');
        $(this).addClass('current-sort');
        tas10TableMethods['load'].call( table, options.url );
      })
    },

    loadTemplates: function( url ){
      var table = this
        , tblContainer = $(table).closest('.action-container').find('.available-scripts')
        , scriptTmpl = $.templates("tas10Path", "<li data-id=\"${_id}\" data-columns=\"${columns}\">${name}</li>");
      $.getJSON(url, function( data ){
        $(tblContainer).append( $.render.tas10Find( path ) );
        $(tblContainer).find('li').on('click', function(){
          var options = $(table).data('options');
          options.items = $(this).attr('data-columns').replace(/\n/i,'').split(',');
          $(table).data('options', options);
          tas10TableMethods['setupHeaders'].call( table, options );
          tas10TableMethods['fill'].call( table, $(table).data('data') );
        })
      });
    }

  }

  $.fn.tas10Table = function( options ) {

    if( $(this).length < 1 )
      return;
    
    if( $(this).data('id') && !options.id )
      optoins.id = $(this).data('id');

    if( !($(this).attr('id')) ){
      if( 'id' in options )
        $(this).attr('id', 'tas10-table-'+options.id );
      else
        $(this).attr('id', 'tas10-table-' + $(document).find('.tas10-table').length );
    }

    var table = this;

    if( typeof(arguments[0]) === 'string' ){
      switch(arguments[0]){
        case 'append': {
          tas10TableMethods['append'].call( table, arguments[1] );
          break;
        }
        case 'reload': {
          tas10TableMethods['load'].call( tabe, $(table).data('url'), setupTas10TableEvents );
          break;
        }
        case 'columns': {
          return $(table).data('options').items;
        }
      }
      return;
    } else if( typeof(arguments[0]) === 'object' ){

      $(table).data('curPage', 1);
      $(table).data('curLimit', 30);
      $(table).data('sort', null);

      $(table).data('options', options);

      if( $(this).data('initialized-tas10-table') )
        return;

      $(this).data('initialized-tas10-table', true).closest('.tas10-table-wrapper').show();

      tas10TableMethods['setupHeaders'].call( table, options );

      if( 'url' in options ){
        $(table).data('url', options.url);
        tas10TableMethods['load'].call( table, options.url, setupTas10TableEvents );
      }
      if( 'templatesUrl' in options)
        tas10TableMethods['loadTemplates'].call( table, options.templatesUrl );

      tas10TableMethods['setupSortSelect'].call( table, options );
      tas10TableMethods['setupLimitSelect'].call( table, options );
      tas10TableMethods['setupPageSelectEvents'].call( table );
    }

  };

});