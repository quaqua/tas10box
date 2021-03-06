/*
 * tas10 tree plugin (client side)
 */

(function( jQuery ){

  var setupTas10TabsEvents = function(tabsContainer){
    $(tabsContainer).find('.settings-tabs > a').each( function(){
      $(this).die().live('click', function(e){
        var self = this;
        e.preventDefault();
        if( $(this).hasClass('disabled') )
          return;
        $(tabsContainer).find('.current').removeClass('current');
        $(this).addClass('current');
        var id = $(this).attr('href');
        $(tabsContainer).find('.settings-tab-content').hide();

        if( id.indexOf('#') === 0 )
          $(tabsContainer).find(id).show();
        else
          $.ajax({url: id, type: 'get', dataType: 'html',
                  success: function( html ){
                    $(self).closest('.tas10-settings-tabs').append( html );
                    id = $(self).closest('.tas10-settings-tabs').find('.settings-tab-content:last').attr('id')
                    $(self).attr('href','#'+id)
                    $(tabsContainer).find('#'+id).show();
                  }
          })
      });
    });
  };

  var tas10TabMethods = {
      init : function( options ) {

        if( $(this).hasClass('tas10-tab-obj') )
          return;

        $(this).addClass('tas10-tab-obj');
        $(this).find('.settings-tabs').addClass('ui-helper-clearfix');

        setupTas10TabsEvents(this);

        $(this).find('.settings-tabs a:first').addClass('current');
        $(this).find('.settings-tab-content:first').show();

        $(this).find('.settings-tab-content').css({ height: ($(window).height() - 170)});

      }
    };

    jQuery.fn.tas10SettingsTabs = function( method ) {

      if ( tas10TabMethods[method] ) {
        return tas10TabMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
      } else if ( typeof method === 'object' || ! method ) {
        tas10TabMethods.init.apply( this, arguments );
      } else {
        $.error( 'Method ' +  method + ' does not exist on jQuery.tas10Tabs' );
      }
    };

})( jQuery );
