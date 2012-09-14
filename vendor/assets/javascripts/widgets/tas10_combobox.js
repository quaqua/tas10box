(function( $ ) {
  $.widget( "ui.tas10Combobox", {

    // These options will be used as defaults
    options: { url : null, onSelectCallback: null },

    _create: function( ) {
      var self = this,
      select = this.element.hide(),
      selected = select.children( ":selected" ),
      value = selected.val() ? selected.text() : "";

      var input = this.input = $( "<input>" )
      .insertAfter( select )
      .val( value )
      .autocomplete({
        delay: 0,
        minLength: 0,
        source: function( request, response ) {
          if( self.options.url ){
              if ( 'cache' in self.options ) {
                if ( request.term in self.options.cache ) {
                  response( self.options.cache[ request.term ] );
                  return;
                }
              }
              data_hash = {}
              if(request)
                data_hash = jQuery.extend(data_hash,request);
              $.ajax({
                url: self.options.url,
                dataType: "json",
                data: data_hash,
                success: function( data ) {
                  if ( 'cache' in self.options )
                    self.options.cache[request.term] = data;

                  if( data.length < 1 && self.options.emptyDataCallback && typeof(self.options.emptyDataCallback) === 'function' )
                    self.options.emptyDataCallback( select, input.val() );

                  if( data.length > 0 && self.options.hasDataCallback && typeof(self.options.hasDataCallback) === 'function' )
                    self.options.hasDataCallback( select, input.val() );
                  
                  response( data );
                }
              });
          } else {
            var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
            response( select.children( "option" ).map(function() {
              var text = $( this ).text();
              if ( this.value && ( !request.term || matcher.test(text) ) )
              return {
                label: text.replace(
                         new RegExp(
                           "(?![^&;]+;)(?!<[^<>]*)(" +
                           $.ui.autocomplete.escapeRegex(request.term) +
                           ")(?![^<>]*>)(?![^&;]+;)", "gi"
                           ), "<strong>$1</strong>" ),
                  value: text,
              option: this
              };
            }) );
          }
        },
        select: function( event, ui ) {
          if( self.options.onSelectCallback && typeof(self.options.onSelectCallback) === 'function' ){
            self.options.onSelectCallback.call( this, select, ui );
            return;
          }
          if( !$(select).find('option[value='+ui.item.id+']').length )
            $(select).append('<option value="'+ui.item.id+'">'+ui.item.name+'</option>');
          $(select).find('option').attr('selected',false);
          $(select).find('option[value='+ui.item.id+']').attr('selected', true);
          var form = $(select).closest('form')
            , formData = $(select).closest('form').serializeArray();
          docIds = [];
          parentElemId = $(form).attr('data-parent-elem-id');
          $('#' + parentElemId).find('.selected-item').each( function(){
            if( docIds.indexOf($(this).attr('data-id')) < 0 )
              docIds.push($(this).attr('data-id'));
          })
          formData.push( { name: 'doc_ids', value: docIds })
          if( self.options.submitOnSelect ){
            $(input).val('');
            $(select).find('option').remove();
            $.ajax({ url: $(form).attr('action'), data: formData, dataType: 'script', type: 'post', success: self.options.successCallback });
          }
          if( self.options.onSubmit && typeof(self.options.onSubmit) === 'function' )
            self.options.onSubmit();
        },
        search: function( event, ui ){
          //console.log('change', input.val(), select.children('option') )
          //options.changeCallback && options.changeCallback( select );
        },
        change: function( event, ui ) {
          if ( !ui.item ) {
            var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
              valid = false;
            select.children( "option" ).each(function() {
              if ( $( this ).text().match( matcher ) ) {
                this.selected = valid = true;
                return false;
              }
            });
            if ( !valid ) {
              // remove invalid value, as it didn't match anything
              $( this ).val( "" );
              select.val( "" );
              input.data( "autocomplete" ).term = "";
              return false;
            }
          }
        },
        open: function( event, ui ){
          $(this).autocomplete('widget').css('z-index', 9999);
        }
      })
      .bind('keydown', function(e){
        if( e.keyCode === 13 ){
          var selectedOption = $(select).find('option:selected');
          if( ( selectedOption.length && $(selectedOption).val().length > 22 ) || 
            select.closest('form').find('.create-button').is(':visible') )
            if( self.options.onSubmit && typeof(self.options.onSubmit) === 'function' && !$('.ui-autocomplete.ui-menu li').length )
              self.options.onSubmit();
            else
              return true;
          return false;
        }
      })
      .addClass( "ui-widget ui-widget-content ui-corner-left" );


  input.data( "autocomplete" )._renderItem = function( ul, item ) {
    return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append( "<a>" + item.label + "</a>" )
      .appendTo( ul );
  };

  this.button = $( "<button type='button'>&nbsp;</button>" )
    .attr( "tabIndex", -1 )
    .attr( "original-title", "Show All Items" )
    .insertAfter( input )
    .button({
      icons: {
               primary: "ui-icon-triangle-1-s"
             },
      text: false
    })
  .removeClass( "ui-corner-all" )
    .addClass( "ui-corner-right ui-button-icon live-tipsy" )
    .click(function() {
      // close if already visible
      if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
        input.autocomplete( "close" );
        return;
      }

      // work around a bug (likely same cause as #5265)
      $( this ).blur();

      // pass empty string as value to search for, displaying all results
      input.autocomplete( "search", "" );
      input.focus();
    });
             },
    destroy: function() {
               this.input.remove();
               this.button.remove();
               this.element.show();
               $.Widget.prototype.destroy.call( this );
             }
  });
})( jQuery );