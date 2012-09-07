/*
 * tas10 tree plugin (client side)
 */

(function( jQuery ){

  var setupTas10TabsEvents = function(tabsContainer){

    $(tabsContainer).find('.tabs > a').live('click', function(e){
      e.preventDefault();
      if( $(this).hasClass('disabled') )
        return;
      $(tabsContainer).find('.current').removeClass('current');
      $(this).addClass('current');
      var id = $(this).attr('href');
      $(tabsContainer).find('.tab-content').hide();
      $(tabsContainer).find(id).show();
      //if( $(tabsContainer).closest('#tas10-dialog').length )
      //  $('#tas10-dialog').center();
    })
  };

  var tas10TabMethods = {
      init : function( options ) {

        if( $(this).hasClass('tas10-tab-obj') )
          return;

        $(this).addClass('tas10-tab-obj');
        $(this).find('.tabs').addClass('ui-helper-clearfix');

        setupTas10TabsEvents(this);

        $(this).find('.tabs a:first').addClass('current');
        $(this).find('.tab-content:first').show();

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
