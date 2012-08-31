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
		tas10.showAclMiniDialog( this, '/documents/'+$(this).closest('action-container').find('.selected-item').attr('data-id')+'/acl', true );
	});

	$('.browser-actions .edit').live('click', function(){
		if( $(this).hasClass('disabled') )
			return;
		var item = $(this).closest('.action-container').find('.selected-item')
		  , url = '/'+$(item).attr('data-_type').toLowerCase()+'s/'+$(item).attr('data-id')+'/edit';
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
			var li = this;
			$(li).attr('data-move', null);
			if( $(li).parent().parent().hasClass('item') )
				$(li).attr('data-move', $(li).parent().parent().data('id'));
	    else if( $(li).closest('.tab-content').data('id') )
	    	$(li).attr('data-move', $(li).closest('.tab-content').data('id') )
	    console.log('move', $(li).attr('data-move') );
	    tas10.clipboard('push', li);
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
		var labelId
		  , elem = $(this).closest('.action-container').find('.selected-item')
		  , cS = tas10.clipboard('pullAll');
		if( $(elem).length )
			labelId = $(elem).data('id');
		else {
			elem = $(this).closest('.tab-content');
			if( $(elem).length )
				labelId = $(elem).data('id');
		}
		console.log('elem id', labelId);
		for( var i in cS )
			tas10.moveCopyElem( labelId, cS[i] );

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