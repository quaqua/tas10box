/*
 * tas10 container plugin (client side)
 */

(function( jQuery ){

	var setupTas10ContainerEvents = function(containerItem, options){

		$(containerItem).find('.tab').live('click', function(e){
			var options = $(this).data('options');
			if( $(e.target).hasClass('ui-sortable-placeholder') )
				return;
			if( $(e.target).hasClass('tab-close') )
				return;
    	$(containerItem).find('.tab').removeClass('active');
    	$(containerItem).find('.tab-content').hide();
    	$(this).addClass('active');
    	var id = $(this).attr('id').replace('tab_','');
    	$(containerItem).find('#tab_content_'+id).show();
    	//$('.tas10-item-title').text( $(this).attr('original-title') || $(this).text() );

    	if( id.substring(0,1) === '_' )
    		path = [];
    	if( !options || !options.path )
    		path = [{name: $(this).find('.tab-title').text(), id: id, className: null}];
    	else
    		path = options.path;
    	if( id === 'home' )
    		path = [];

    	tas10.setPath(path);
    	$('.tas10-tree').tas10Tree( 'select', id );
		});

		$(containerItem).find('.tab-close').live('click', function(){
			$(this).closest('.tas10-container-obj').tas10Container( 'remove', $(this).closest('.tab').attr('id').replace('tab_','') );
		});

	};

	var tas10ContainerMethods = {
	    init : function( options ) {

	      if( $(this).hasClass('tas10-container-obj') )
	        return;

	      var settings = {};
	      if ( typeof(options) != 'undefined' ) {
	        $.extend( settings, options );
	      }
	      $(this).data('settings', settings);
	      $(this).addClass('tas10-container-obj');

	      $(this).addClass('tas10-container').html('')
	      		 .append('<div class="tas10-container-tabs-wrapper"><div class="tas10-container-tabs-line"></div><ul class="tas10-container-tabs"></ul></div>')
	      		 .append('<div class="tas10-containers"/>');

	      
	      $(this).find('.tas10-container-tabs').sortable({ beforeStop: function( e, ui ){
	      		if( !$(e.toElement).closest('#tas10-tab-container').length )
	      			$(ui.item).closest('.tas10-container-obj').tas10Container( 'remove', $(ui.item).attr('id').replace('tab_','') );
	      	} 
	      });
				
	      setupTas10ContainerEvents(this, options);

	    },
	    append : function( options, callback ) {

			var thisTab = $(this).find('#tab_'+options.id);

	    	if( $(thisTab).length ){
	    		if( $(thisTab).hasClass('active') && !options['replace'] )
	    			; //$('#tab_content_'+options.id).stop(true,true).effect('highlight', {duration: 2000, color: '#fc6'});
	    		else
	    			$(thisTab).click();
	    		if( options['replace'] ){
	    			var container = $('#tab_content_'+options.id);
	    			$(container).html( options['content'] );
	    			if( callback )
	    				callback(container);
	    		}
	    		$(thisTab).closest('.tas10-container').show();
	    		$('#tas10-dashboard').hide();
		    	return;
		    }

	    	$('.tab').removeClass('active');
	    	$('.tab-content').hide();

	    	var container = $('<div class="tab-content" data-id="'+options.id+'" id="tab_content_'+options.id+'" />');
	    	$(container).html( options.content );
	    	var centerTab = $('<span class="center" />');
	    	//$(centerTab).append('<span class="tab-sprite tab-close"></span>');
	    	if( options.title.length > 15 )
	    		$(centerTab).append('<span data-attr-name="name" data-id="'+options.id+'" class="tab-title item_'+options.id+'_title">'+options.title.substring(0,15)+'</span>');
	    	else
	    		$(centerTab).append('<span data-attr-name="name" data-id="'+options.id+'" class="tab-title item_'+options.id+'_title">'+options.title+'</span>');
	    	var shortOpts = options;
	    	delete shortOpts['content'];
	    	var tab = $('<li class="tab active" id="tab_'+options.id+'" />').data('options', shortOpts);
	    	$(tab).append('<span class="ui-icon ui-icon-close tab-close"></span>');
	    	$(tab).append(centerTab);
	    	$(tab)
	    	if( options.title.length > 15 )
	    		  $(tab).attr('original-title', options.title)
	    		  		.addClass('live-tipsy');
	    	$(tab).show();
	    	$(this).find('.tas10-container-tabs').append(tab);
	    	$(this).find('.tas10-containers').append(container);
	    	$(container).show();
	    	//$('.tas10-item-title').text( $(tab).attr('original-title') || $(tab).text() );
	    	tas10.dashboard('hide');

	    	if( tas10.clipboard('size') )
	    		$(container).find('.tas10-list-actions .paste').removeClass('disabled');

	    	if( options.id.substring(0,1) === '_' )
	    		path = [];

	    	if( !options.path )
	    		path = [{name: options.title, id: options.id, className: null}];
	    	else
	    		path = options.path;

	    	if( options.id === 'home' )
	    		path = [];

	    	tas10.setPath(path);
		    $('.tas10-tree').tas10Tree( 'select', options.id );

	    	if( callback )
	    		callback( container );
	    },
	    remove: function( containerId ){
	    	$('#tab_content_'+containerId).remove();
	    	if( $('#tab_'+containerId).hasClass('active') ){
	    		var takeNext = true;
		    	if( $('#tab_'+containerId).prev('.tab').length ){
		    		takeNext = false;
		    		if( $('#tab_'+containerId).prev('.tab').hasClass('ui-sortable-placeholder') && $('#tab_'+containerId).prev('.tab').prev('.tab').length )
		    		 	$('#tab_'+containerId).prev('.tab').prev('.tab').click();
					else if( $('#tab_'+containerId).prev('.tab').length && !$('#tab_'+containerId).prev('.tab').hasClass('ui-sortable-placeholder') )
						$('#tab_'+containerId).prev('.tab').click();
					else
						takeNext = true;
		    	}
		    	if( takeNext && $('#tab_'+containerId).next('.tab').length ){
		    		if( $('#tab_'+containerId).next('.tab').hasClass('ui-sortable-placeholder') && $('#tab_'+containerId).next('.tab').next('.tab').length )
		    		 	$('#tab_'+containerId).next('.tab').next('.tab').click();
					else
						$('#tab_'+containerId).next('.tab').click();
		    	}
		    }
	    	$('#tab_'+containerId).effect('explode');
	    	setTimeout(function(){ $('#tab_'+containerId).remove(); }, 500);
	    },
	    closeActiveTab: function(){
				var activeTab = $(this).find('.tab.active');
	    	$(this).tas10Container('remove', $(activeTab).attr('id').replace('tab_','') );
	    }
	  };

	  jQuery.fn.tas10Container = function( method ) {

	    if ( tas10ContainerMethods[method] ) {
	      return tas10ContainerMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	    } else if ( typeof method === 'object' || ! method ) {
	      return tas10ContainerMethods.init.apply( this, arguments );
	    } else {
	      $.error( 'Method ' +  method + ' does not exist on jQuery.tas10Container' );
	    }
  	};

})( jQuery );
