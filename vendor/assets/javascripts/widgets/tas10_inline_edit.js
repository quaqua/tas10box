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

			// input field
			var input = $('<input type="text" name="tas10_document[' + $(this).attr('data-name') + ']" />')
				.val($(elem).find('span.text').text());

			// cancel button
			var cancel = $('<a href="#" class="float-right"><span class="float-right ui-icon ui-icon-close"></span></a>');
			$(cancel).on('click', function(e){
				e.stopImmediatePropagation();
				$(form).remove();
				//$(elem).find('span.text').show();
			});

			// cancel button
			var save = $('<a href="#" class="float-right"><span class="float-right ui-icon ui-icon-disk"></span></a>');
			$(save).on('click', function(e){
				e.stopImmediatePropagation();
				$(form).submit();
			});

			$(form).append(cancel);
			$(form).append(save);
			$(form).append(input);
			$(form).css({top: $(elem).offset().top, left: $(elem).offset().left});
			$(form).on('submit', function(){
				$(form).remove();
				$(elem).find('span.text').show();
			});
			$('body').append(form);
			//$(elem).find('span.text').hide();
			$(form).find('input[type=text]').select();
		})

	};

});