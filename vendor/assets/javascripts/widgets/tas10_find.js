tas10['appendFindFilter'] = function( sel ){

	tas10.setPath({id: $(sel).attr('data-id'), name: $(sel).text()}, true);
	$('#tas10-find .label-res').remove();
	$('#tas10-find input[name=query]').val('');

}

tas10['loadFindSettings'] = function(){

	

	if( !tas10.tas10FindSettingsInit ){

		$.getJSON('/query_scripts.json?query=true', function( data ){
			$('#tas10-find .available-scripts').append( $.render.tas10FindQueryScriptMarkup(data) );
		});
		tas10.tas10FindSettingsInit = true;
	}

};

tas10['tas10FindSettingsInit'] = false;

$(function(){

	$.templates('tas10FindQueryScriptMarkup', "<li data-id=\"{{:_id}}\" data-url=\"{{:url}}\" "+
		"class=\"script-item\"><a href=\"/documents/{{:_id}}\" class=\"float-right\" data-method=\"delete\""+
		" data-remote=\"true\"><i class=\"icon-trash\"/></a>"+
		"<a href=\"/query_scripts/{{:_id}}/edit\" data-remote=\"true\" class=\"float-right\"><i class=\"icon-pencil\" /></a>" +
		" <a href=\"/query_scripts/{{:_id}}\" "+
		"data-remote=\"true\" data-attr-name=\"name-{{:_id}}\">{{:name}}</a></li>");

	$('#tas10-find .query-script-item').on('click', function(){
		$('#button-find-drop .find-dropdown-content').slideUp(200);
	});

  $('#button-find-dropdown').hover(function(e){
    $(this).css('opacity', 1) },
    function(e){
      if( !$('.find-dropdown-content').is(':visible') )
        $(this).css('opacity', 0.5)
    }).on('click', function(e){
    if( !$(e.target).closest('.trigger').length )
      return;
    if( $(this).find('.find-dropdown-content').is(':visible') ){
      $(this).find('.find-dropdown-content').slideUp(200);
      return;
    }
    $('.find-dropdown-content').slideDown(200, function(){
    	$('.find-dropdown-content [name=query]').focus();
    	tas10.loadFindSettings();
    });
  });

	$('#tas10-find input[name=query]').val('');
	$('#tas10-find input[name=label_ids]').val('');
	$('#tas10-find input[name=conditions]').val('');
	$('#tas10-find input[name=types]').val('');

	$.templates('tas10FindLabelResMarkup', "<li data-id=\"{{:_id}}\">{{:name}}</li>");

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

			if( $(this).prev('.types').find('.add-type').length === 0 ){
				item = $('#tas10-find .types').find('.add-type:last');
			  field = $('#tas10-find [name=types]');
			  id = $(item).attr('data-name');
				$(field).val( $(field).val().replace(','+id,'').replace(id+',','').replace(id,'') );
				$(item).remove();
			}
		}

		// enter key pressed
		if( e.keyCode === 13 ){
			if( $(this).val().length > 1 && $(this).val().substring(0,1) === '#' ){
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

		if( $(this).val().length > 2 && $(this).val().substring(0,1) === '#' ){
			var labelName = $(this).val().substring(1,$(this).val().length-1);
			$.ajax({url: '/documents/find', data: { 
						query: labelName, labelable: true, findCombo: true
					}, type: 'post',
					dataType: 'json',
					success: function( data ){
						if( typeof( data ) === 'object' && data.length > 0 ){
							$('#tas10-find .label-res').remove();
							var ul = $('<ul class="label-res" />');
							$(ul).css({ left: ($(self).offset().left - $('#tas10-find').offset().left) });
							$('#tas10-find').append(ul);
							$( '#tas10-find .label-res' ).append( $.render.tas10FindLabelResMarkup( data ) );
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
			$('#tas10-find input[name=label_ids]').val().length > 0 ||
			$('#tas10-find input[name=types]').val().length > 0 )
			$('#tas10-find form').submit();
		else
			$('#tas10-find input[name=query]').focus();
	});

	$('#tas10-find form').on('submit', function(e){
		$(this).closest('.find-dropdown-content').slideUp(200);
	});

	$('#tas10-find .settings-trigger').on('click', function(){
		if( $('#tas10-find .settings').is(':visible') ){
			$('#tas10-find .settings').slideUp(200);
			return;
		}

		$('#tas10-find .settings').slideDown(200, tas10.loadFindSettings);
	})

	$('#tas10-find .add-type').on('click', function(){
		if( $('#tas10-find .types [data-name='+$(this).attr('data-name')+']').length )
			return;
		$('#tas10-find .types').append( $(this).clone() );
		var v = [];
		if( $('#tas10-find input[name=types]').val().length > 1 )
			v.push( $('#tas10-find input[name=types]').val() )
		if( v.indexOf( $(this).attr('data-name') ) < 0 )
			v.push( $(this).attr('data-name') );
		$('#tas10-find input[name=types]').val( v.join(',') );
		$('#tas10-find input[type=text]:first').focus();
	})

});