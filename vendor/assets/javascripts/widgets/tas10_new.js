tas10['setupCurrentLabelForNewForm'] = function(){
	// set correct current path for all forms	
	if( $('#tas10-find .path-item').length && $('#tas10-find .path-item:last').html().length > 2 )
		$('#tas10-dialog .tas10-path').addClass('path-item').html( $('#tas10-find .path-item:last').html() );
	$('#tas10-dialog .tas10-current-label').val( $('#tas10-current-label').val() );
}

tas10['loadNewForm'] = function( newForm, options ){

	if( $(newForm).html().length < 10 )
		$.getScript( $(newForm).attr('data-url'), function(){
			if( options && options.dataTypeTemplate ){
				var dtype = options.dataType;
				$('#tas10-dialog #'+dtype+'-form [name='+dtype+'\\[template\\]] option[value="'+options.dataTypeTemplate+'"]').attr('selected', true);	
				$('#tas10-dialog #'+dtype+'-form [name='+dtype+'\\[template\\]] option[data-v="'+options.dataTypeTemplate+'"]').attr('selected', true);
			}
			$(newForm).show().find('.js-get-focus').focus();
			$('#tas10-dialog').center();
			tas10.setupCurrentLabelForNewForm();
		});
	else{
		$(newForm).show().find('.js-get-focus').focus();
		$('#tas10-dialog').center();
		tas10.setupCurrentLabelForNewForm();
	}

}

tas10['setupNewDialog'] = function( options ){

	tas10.dialog( 'new', {title: I18n.t('new'), content: $('#tas10-new-item-dialog-data').html()}, function(){

		$('#tas10-dialog .create-form').hide();
		if( options.dataType ){
			tas10.loadNewForm( $('#tas10-dialog #'+options.dataType+'-form'), options );
			$('#tas10-dialog #tas10-select-type-to-create option[value='+options.dataType+']').attr('selected',true);
		} else {
			tas10.loadNewForm( $('#tas10-dialog #labels-form'), options );
			$('#tas10-dialog #tas10-select-type-to-create option[value=label]').attr('selected', true);
		}

		
		var newSelector = $('#tas10-dialog #tas10-select-type-to-create');

		$(newSelector).bind('change', function(){
			$('.create-form').hide();
			var newForm = $('#tas10-dialog #'+$(this).find('option:selected').val()+'-form');
			tas10.loadNewForm( newForm );
		})

	});

	if( options.completed && typeof(options.completed) === 'function' )
		options.completed($('#tas10-dialog #'+options.dataType+'-form').find('form'));

}

tas10['fireNewDialog'] = function( options ){

	if( $('#tas10-new-item-dialog-data').length )
			tas10.setupNewDialog( options );
	else {
		$('body').append('<div id="tas10-new-item-dialog-data" style="display:none" />');
		$('#tas10-new-item-dialog-data').load('/documents/new', function(){
			tas10.setupNewDialog( options );
		});
	}

}
$(function(){

	$('.new-item').live('click', function(){
		var trigger = this;
		var options = {
			dataType: $(trigger).attr('data-type'),
			dataTypeTemplate: $(trigger).attr('data-type-template')
		}
		tas10.fireNewDialog( options );
	});

});