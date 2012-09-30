/*
 * tas10tree tas10box plugin (client side)
 */

tas10.getTreeTemplate = function getTreeTemplate( doc ){
	var name = '#'+doc._type.toLowerCase()+'-tree-item-template';
	if( $(name).length )
		return name;
	else
		return '#default-tree-item-template';
};

tas10.updateTreeSelection = function updateTreeSelection( actionContainer ){

	if( $(actionContainer).find('.selected-item').length > 1 ){
		$(actionContainer).find('.browser-actions .single').addClass('disabled');
		$(actionContainer).find('.browser-actions .multi').removeClass('disabled');
	} else if( $(actionContainer).find('.selected-item').length === 1 ){
		$(actionContainer).find('.browser-actions .single').removeClass('disabled');
		$(actionContainer).find('.browser-actions .multi').each(function(){
			if( !$(this).hasClass('single') )
				$(this).addClass('disabled');
		})
	} else
		$(actionContainer).find('.browser-actions a.single, .browser-actions a.multi').addClass('disabled');
	if( typeof(tas10.clipboardStore) === 'undefined' || tas10.clipboardStore.length == 0 )
		$(actionContainer).find('.paste').addClass('disabled');

};

(function( jQuery ){

	var loadTreeItemChildren = function loadTreeItemChildren( handle, li, id, callback ){
		$.getJSON('/labels/' + id + '/children?taggable=true', function(data){
					if( data && data.length > 0 ){
						$(li).append('<ul class="children" style="padding-left: 16px"></ul>');
						$(li).find('ul.children').append( $( tas10.getTreeTemplate( data[0] )).render( data ) );
						$(handle).addClass('open ui-icon-triangle-1-s').removeClass('ui-icon-triangle-1-e');
			    	} else 
			    		$(handle).die('click')
			    				 .removeClass('opener')
								 .removeClass('ui-icon-triangle-1-e')
								 .removeClass('ui-icon')
								 .addClass('spacer');
					$(handle).removeClass('loading');
					$(li).addClass('loaded');
					if( callback )
						callback();
		});
	}

	var setupTas10TreeEvents = function(treeItem){

		// children
		$(treeItem).find('.opener').die('click').live('click', function(){
			var handle = this
			  , li = $(this).closest('li')
			  , id = $(li).attr('data-id');
			if( $(this).hasClass('open') ){
				$(this).removeClass('open').addClass('ui-icon-triangle-1-e').removeClass('ui-icon-triangle-1-s');
				$(li).find('ul.children:first').hide();
			} else if( $(li).hasClass('loaded') ){
				$(li).find('ul.children:first').show();
				$(handle).addClass('ui-icon-triangle-1-s open').removeClass('ui-icon-triangle-1-e');
			} else {
				loadTreeItemChildren(handle, li, id);
			}
		})

		// item functions
		$(treeItem).find('li').die('click').live('click', function(e){

			var self = this;
			var actionContainer = $(this).closest('.action-container');

			if( $(e.target).hasClass('opener') )
				return;

			var wasSelected = $(this).hasClass('selected-item')
			//if( e.target.nodeName === 'A' )
			if( !e.ctrlKey && !e.metaKey )
				$('.selected-item').removeClass('selected').removeClass('selected-item');

			if( wasSelected ){
				$(this).removeClass('selected-item');
				tas10.setPath();
			} else {
				$(this).addClass('selected-item');
				tas10.setPath(tas10.getPath(this));
			}
			tas10.updateTreeSelection( actionContainer );

			if( e.target.nodeName !== 'A' )
				e.stopPropagation();

		}).find('a').die('click').live('click', function(e){
      var li = $(this).closest('li')
        , actionContainer = $(this).closest('.action-container');
      if( $(li).hasClass('selected-item') ){
        $(li).removeClass('selected-item')
        tas10.setPath();
        tas10.updateTreeSelection( actionContainer );
        return false;
      }
      $(li).addClass('selected-item');
      tas10.setPath(tas10.getPath(li));
      tas10.updateTreeSelection( actionContainer );
    });

	};

	var tbTreeMethods = {
	    init : function( options ) {

	      if( $(this).hasClass('tas10-tree-obj') || !$(this).is('ul') )
	        return;

	      var settings = { url: ($(this).attr('data-url') || null), page: 1, pageCount: 30 };
	      if ( typeof(options) != 'undefined' ) {
	        $.extend( settings, options );
	      }
	      $(this).data('settings', settings);

	      $(this).addClass('tas10-tree-obj');

	      var height;
	      if( options.height )
	      	height = options.height;
	      else{
		      height = $(this).closest('#tas10-left-panel').height()-50
		      if( height < 100 )
		      	height = 100;
		    }
	      $(this).css('height', height);

	      setupTas10TreeEvents( this );

	    },
	    reload : function() {
	    	var self = this;
        $(this).html('<li class="loading"><img src="/assets/loading_50x50.gif" /></li>');
				$.getJSON( $(self).data('settings').url, function( data ){
					if( 'items' in data )
						data = data['items'];
					if( data.length > 0 )
						$(self).append( $( tas10.getTreeTemplate( data[0] )).render( data ) );
					$(self).find('li.loading').remove();
				});
	    },
	    append : function( doc ) {
	    	var self = this;
	    	if( doc.label_ids.length > 0 )
	    		for( var i in doc.label_ids){
	    			var li = $('.tas10-tree li[data-id='+doc.label_ids[i]+']');
	    			if( $(li).find('ul.children').length ){
	    				if( !$(li).find('.opener').hasClass('open') )
	    					$(li).find('.opener').click();
	    				if( ! $(li).find('ul.children li[data-id='+doc._id+']').length )
	    					$(li).find('.ul.children').prepend( $( tas10.getTreeTemplate( doc )).render( doc ) );
	    				$(li).find('li[data-id='+doc._id+']').effect('highlight', {color: '#fc6'}, 2000);
	    			} else
	    				loadTreeItemChildren( $(li).find('.opener'), li, doc.label_ids[i], function(){
	    					$(li).find('.opener').addClass('open');
	    					$(li).find('li[data-id='+doc._id+']').effect('highlight', {color: '#fc6'}, 2000);	
	    				});
	    		}
	    	else
	    		$(this).prepend( $( tas10.getTreeTemplate( doc )).render( doc ) );
	    },
	    unselectAll: function(){
	    	$('.selected-item').removeClass('selected-item');
			tas10.setPath([]);
	    },
	    select: function( itemId ){
	    	var item = $('.tas10-tree:visible li[data-id='+itemId+']:first');
			if( !$(item).length )
				return;
	    	$('.selected-item').removeClass('selected-item');
			$(item).addClass('selected-item');
			tas10.setPath(tas10.getPath(item));
	    }

	  };

	  jQuery.fn.tas10Tree = function( method ) {

	    if ( tbTreeMethods[method] ) {
	      return tbTreeMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	    } else if ( typeof method === 'object' || ! method ) {
	      tbTreeMethods.init.apply( this, arguments );
	      return tbTreeMethods.reload.apply( this );
	    } else {
	      $.error( 'Method ' +  method + ' does not exist on jQuery.tas10Tree' );
	    }
  	};

})( jQuery );
