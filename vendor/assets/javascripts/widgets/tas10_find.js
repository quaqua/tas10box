tas10['appendFindFilter'] = function( sel ){

	tas10.setPath({id: $(sel).attr('id'), name: $(sel).text()}, true);
	$('#tas10-find .label-res').remove();
	$('#tas10-find input[name=query]').val('');

}

tas10['tas10FindSettingsInit'] = false;

$(function(){

	var tas10FindLabelResMarkup = "<li id=\"${_id}\">${name}</li>";

	// reset hidden field (possibly stored in firefox cache
	$('#tas10-find [name=label_ids]').val('');
	$('#tas10-find [name=path]').val('');
	$('#tas10-find [name=conditions]').val('');

	$('#tas10-find input[name=query]').on('keydown', function(e){

		var self = this;

		// backspace key pressed
		if( e.keyCode === 8 && $(this).val().length === 0 ){
			var item = $(this).prev('.path').find('.path-item:last')
			  , field = $(this).closest('form').find('[name=label_ids]')
			  , id = $(item).data('id');
			if( $(this).prev('.path').find('.path-item').length === 0 ){
				item = $('#tas10-find .conditions').find('.field-condition:last');
			  	field = $('#tas10-find [name=conditions]');
			  	id = $(item).text();
			}
			$(field).val( $(field).val().replace(','+id,'').replace(id+',','').replace(id,'') );
			$(item).remove();
		}

		// enter key pressed
		if( e.keyCode === 13 ){
			if( $(this).val().length > 1 && $(this).val().substring(0,1) === ':' ){
				var sel = $('#tas10-find .selected-res');
				if( sel.length ){
					tas10.appendFindFilter( sel );
					return false;
				}
			} else if( $(this).val().substring(0,1) === "$" && 
						( $(this).val().indexOf('=') > 0 || $(this).val().indexOf('>') > 0 || $(this).val().indexOf('<') ) ){
				var fieldCondition = $(this).val().replace('$','').replace(' ','');

				var cond = $('#tas10-find input[name=conditions]');
				$(cond).val( cond.val().length > 0 ? cond.val() + ',' + fieldCondition : fieldCondition );

				$('#tas10-find input[name=query]').val('');
				$('#tas10-find .conditions').append($('<span class="field-condition">'+fieldCondition+'</span>'));
				return false;
			}

			return;
		}

		// 38...up
		// 40...down
		if( ( e.keyCode === 40 || e.keyCode === 38 ) && $('#tas10-find .label-res').length ){
			var res = $('#tas10-find .label-res li.selected-res')
			if( res.length ){
				if( e.keyCode === 40 )
					$(res).next('li').addClass('selected-res');
				else if( e.keyCode === 38 )
					$(res).prev('li').addClass('selected-res');
				$(res).removeClass('selected-res');
			} else
				$('#tas10-find .label-res li:first').addClass('selected-res');
			return;
		}

		if( $(this).val().length > 2 && $(this).val().substring(0,1) === ':' ){
			var labelName = $(this).val().substring(1,$(this).val().length-1);
			$.ajax({url: '/documents/find.json', data: { 
						query: labelName, _csrf: $('#_csrf').val(), taggable: true
					}, type: 'post',
					dataType: 'json',
					success: function( data ){
						if( typeof( data ) === 'object' && data.length > 0 ){
							$('#tas10-find .label-res').remove();
							var ul = $('<ul class="label-res" />');
							$(ul).css({ left: ($(self).offset().left - $('#tas10-find').offset().left) });
							$('#tas10-find').append(ul);
							$('#tas10-find .label-res').tmpl()
							$.tmpl( tas10FindLabelResMarkup, data ).appendTo( '#tas10-find .label-res' );
						}
					}
			});
			e.stopPropagation();
			return;
		}

	});

	$('#tas10-find .label-res li').live( 'mouseenter', function(){
		$('#tas10-find .selected-res').removeClass('selected-res');
		$(this).addClass('selected-res');
	}).live('click', function(){
		tas10.appendFindFilter( $(this) );
		$('#tas10-find input[name=query]').focus();
	})

	$('#tas10-find').find('.remove-item').live('click', function removeTas10FindItem(){
		if( !$(e.toElement).closest('#tas10-find').length ){
			var fields = [$('#tas10-find input[name=conditions]'), $('#tas10-find input[name=label_ids]')];
			id = $(this).data('id') || $(this).text();
			for( var i in fields )
				$(fields[i]).val( $(fields[i]).val().replace(','+id,'').replace(id+',','').replace(id,'') );
			$(this).effect('explode');
		}
	});

	$('#tas10-find .tas10-icon-find').on('click', function(){
		if( $('#tas10-find input[name=query]').val().length > 0 ||
			$('#tas10-find input[name=conditions]').val().length > 0 ||
			$('#tas10-find input[name=label_ids]').val().length > 0 )
			$('#tas10-find form').submit();
		else
			$('#tas10-find input[name=query]').focus();
	});

	$('#tas10-find .settings').on('hover', function(){
		if( !tas10.tas10FindSettingsInit ){

			$.getJSON('/scripts.json?query=true', function( data ){
				for( var i in data )
					$('#tas10-find .available-scripts').append(
						$('<li/>').attr('data-id', data[i]._id)
						.attr('data-url', data[i].query)
						.text(data[i].name) );
			});
			tas10.tas10FindSettingsInit = true;
		}
	})

});