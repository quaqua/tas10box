tas10.buttonbar = function( action, iconName, loadUrl, callback ){
	if( action === 'append' ){
		if( $('#tas10-button-tabs #tab_'+iconName).length ){
			if( $('#tas10-navbar #button_'+iconName).hasClass('current') )
				$('#tas10-button-tabs #tab_'+iconName).effect('highlight', {duration: 500, color: '#fc6'})
			tas10.buttonbar( 'update', $('#tas10-navbar #button_'+iconName) );
			return;
		}/*
		var button = '<span id="button_'+iconName+'" class="buttonbar-button tas10-icon24 tas10-icon-'+iconName+' float-left"></span>';
		var sep = '<span class="separator buttonbar-button"></span>';
		$('#tas10-navbar .app-sep').after(button).after(sep);
		*/
		var tab = '<div class="tab" id="tab_'+iconName+'"/>';
		$('#tas10-button-tabs').append(tab);
		$('#tas10-button-tabs #tab_'+iconName).load( loadUrl, function(){
			tas10.buttonbar( 'update', $('#tas10-navbar #button_'+iconName) );
			
			if( callback )
				callback( this );
		})
	} else if( action === 'update' ){
		var elem = arguments[1];
		
		$('#tas10-navbar .buttonbar-button').removeClass('current');

		$('#tas10-button-tabs .tab').hide();
		var tab = $('#tas10-button-tabs #tab_' + $(elem).attr('id').replace('button_',''));
		tab.show().find('.js-get-focus:first').focus();
		var buttonPosition = 0;
		$('.buttonbar-button').each( function( pos ){
			if( $(elem).attr('id') == $(this).attr('id') )
				buttonPosition = pos;
		})
		$('#active-tab-arrow').animate({top: (buttonPosition * 31)+'px'}, 300, 'easeOutQuart');
		setTimeout(function(){
			$(elem).addClass('current');
		}, 300);
	}
}

$( function(){

	$('#tas10-navbar > .buttonbar-button').live('click', function clickButtonbarButton(){

		if( $(this).hasClass('current') && $(this).attr('data-dblclk-url') ){
			$.getScript( $(this).attr('data-dblclk-url') );
			return;
		}

		if( $(this).hasClass('current') )
			return;

		tas10.buttonbar( 'update', this );
	});

	$('#tas10-navbar > a').live('click', function clickAButton(e){
		var bbb = $(this).find('.buttonbar-button');
		if( $(bbb).hasClass('current') ){
			if( $(bbb).attr('data-dblclk-url') )
				$.getScript( $(bbb).attr('data-dblclk-url') );
			return false;
		}
	})

	$('#tas10-navbar > .buttonbar-button:first').addClass('current');

});