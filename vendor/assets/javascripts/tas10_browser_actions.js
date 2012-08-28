$(function(){
	
	$('.browser-actions .delete').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var actionContainer = $(this).closest('.action-container');
    	var title = $(actionContainer).find('.selected-item .title:first').text();
		if( $(actionContainer).find('.selected-item').length > 1 )
			title = I18n.t('items', {count: $(actionContainer).find('.selected-item').length});
    	tas10.confirm(I18n.t('really_delete', {name: title}), function(){
			$(actionContainer).find('.selected-item').each(function(){
				var self = this;
            	$.ajax({url: '/document/' + $(self).attr('data-id'),
            			type: 'delete',
            			dataType: 'script',
						success: function( data ){
            				if('ok' in data && data.ok){
            					tas10.notify(I18n.t('deleted', {name: title}));
            					$('[data-id='+data.doc._id+']').remove();
            					tas10.setPath([]);
            					$('#tab_'+data.doc._id+' .tab-close').click();
            				} else
            					tas10.notify(I18n.t('deletion_failed', {name: title}));
            			}
            	});
	        });
		});
	});

	$('.browser-actions .share').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var actionContainer = $(this).closest('.action-container');
		tas10.shareDialog($(actionContainer).find('.selected-item').attr('data-id'));
	});

	$('.browser-actions .edit').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var item = $(this).closest('.action-container').find('.selected-item')
		  , url = '/'+$(item).attr('data-classname').toLowerCase()+'/'+$(item).attr('data-id')+'/edit';
		$.getScript( url );
	});

	$('.browser-actions .info').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var actionContainer = $(this).closest('.action-container');
		tas10.infoDialog($(actionContainer).find('.selected-item').attr('data-id'));
	});

	$('.browser-actions .cut').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var actionContainer = $(this).closest('.action-container');
		$(actionContainer).find('.selected-item').each(function(){
			$(this).attr('data-move', $(this).closest('li.item').data('id'));
			if( !$(this).closest('li.item').length )
				$(this).attr('data-move', $(this).attr('data-id'));
		    if( !$(this).attr('data-move') && $(this).closest('.tab-content').data('id') )
		    	$(this).attr('data-move', $(this).closest('.tab-content').data('id') )
		    tas10.clipboard('push', this);
		});
	});

	$('.browser-actions .copy').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var actionContainer = $(this).closest('.action-container');
		$(actionContainer).find('.selected-item').each(function(){
			$(this).attr('data-move', null);
		    tas10.clipboard('push', this);
		});
	});

	$('.browser-actions .paste').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var elem = $(this).closest('.action-container').find('.selected-item');
		var cS = tas10.clipboard('pullAll');
		for( var i in cS )
			tas10.moveCopyElem( $(elem).data('id'), cS[i] );
	});

	$('.browser-actions .preferences').live('click', function(){
		var actionContainer = $(this).closest('.action-container');
		tas10.dialog( $(this), $(actionContainer).find('.browser-preferences-context-content').html(), function(){

			// bind orig events to dialog copy
			var events = $(actionContainer).find('.browser-preferences-context-content .sort-filter select').data('events');
			if ( events ) {
			    for ( var eventType in events ) {
			        for ( var i in events[eventType] ) {
			            $('#tas10-dialog .sort-filter select')[ eventType ]( events[eventType][i].handler );
			        }
			    }
			}

		});

	})
})