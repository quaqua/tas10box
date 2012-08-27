$(function(){

	$.fn.tas10InlineEdit = function( options ) {
		if( $(this).length < 1 )
			return;
		
		if( $(this).data('initialized-tas10-inline-edit') )
			return;
		$(this).data('initialized-tas10-inline-edit', true);

		$(this).bind('click', function(){
			if( $(this).find('form.tas10-inline-edit-form').length )
				return;
			var elem = this
			  , form = $('<form data-remote="true" method="put" class="tas10-inline-edit-form" />');
			$(form).attr('action', $(this).attr('data-url'));
			$(form).append('<input type="hidden" name="_csrf" value="' + $('#_csrf').val() + '" />');
			var input = $('<input type="text" name="document[' + $(this).attr('data-name') + ']" />');
			$(input).css({width: $(this).outerWidth()}).val($(this).find('span.text').text());
			$(form).append(input);
			var cancel = $('<a href="#" class="tas10-inline-cancel"><span class="ui-icon ui-icon-close"></span></a>');
			$(cancel).on('click', function(e){
				e.stopImmediatePropagation();
				$(form).remove();
				$(elem).find('span.text').show();
			});
			$(form).append(cancel);
			$(form).on('submit', function(){
				$(form).remove();
				$(elem).find('span.text').show();
			});
			$(elem).append(form);
			$(elem).find('span.text').hide();
			$(form).find('input[type=text]').select();
		})

	};

});