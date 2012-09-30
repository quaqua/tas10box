/*
tas10['setupCurrentLabelForNewForm'] = function(){
	// set correct current path for all forms	
	if( $('#tas10-find .path-item').length && $('#tas10-find .path-item:last').html().length > 2 )
		$('#tas10-dialog .tas10-path').addClass('path-item').html( $('#tas10-find .path-item:last').html() );
	$('#tas10-dialog .tas10-current-label').val( $('#tas10-current-label').val() );
}

tas10['loadNewForm'] = function( newForm, options ){

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

}

tas10['setupNewDialog'] = function( options ){

	tas10.dialog( 'new', {title: I18n.t('new'), content: $('#tas10-new-item-dialog-data').html()}, function(){

		$('#tas10-dialog .create-form').hide();
		if( options.dataType ){
			tas10.loadNewForm( $('#tas10-dialog #'+options.dataType+'-form'), options );
			$('#tas10-dialog #tas10-select-type-to-create option[value='+options.dataType+']').attr('selected',true);
		} else {
			tas10.loadNewForm( $('#tas10-dialog #label-form'), options );
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

*/


tas10['setupNewDialog'] = function setupNewDialog( options ){

	var form = $('#tas10-dialog .tas10-form');
	$('#tas10-select-type-to-create').on('change', function(){
		var controllerName = $(this).find('option:selected').val();
		$(form).attr("action", "/"+$('.plugin-pluralize-'+controllerName).attr('data-name'));
		$(form).find('.select-template').hide();
		$(form).find('.select-template-'+controllerName).show();
	})

	$('#tas10-dialog .tas10-form').on('submit', function(){
		var controllerName = $('#tas10-select-type-to-create option:selected').val()
		  , name = $(this).find('[name=name]').val();
		$('#'+controllerName+'_name').val( name );
	})

	if( options && options.dataTypeTemplate ){
		var dtype = options.dataType;
		$('#tas10-dialog [name='+dtype+'\\[template\\]] option[value="'+options.dataTypeTemplate+'"]').attr('selected', true);
	}

	if( options && options.dataType ){
		$('#tas10-select-type-to-create option[value="'+options.dataType+'"]').attr('selected', true);
		$(form).attr("action", "/"+$('.plugin-pluralize-'+options.dataType).attr('data-name'));
		$(form).find('.select-template').hide();
		$(form).find('.select-template-'+options.dataType).show();
	}
	else
		$('#tas10-dialog .select-template:first').show();

	if( $('#tas10-find .path-item').length && $('#tas10-find .path-item:last').html().length > 2 )
		$('#tas10-dialog .tas10-path').addClass('path-item').html( $('#tas10-find .path-item:last').html() );
	$('#tas10-dialog .tas10-current-label').val( $('#tas10-current-label').val() );

	if( options && options.completed && typeof(options.completed) === 'function' )
		options.completed($('#tas10-dialog').find('form'));

}

tas10.newDialog = {

  availableCreates: function(){
    var creates = $('[data-tas10-creates]').map( function( item, el ){
            return {value: $(el).attr('data-tas10-creates'),
             name: $(el).attr('original-title') }
          }).get();
    creates.push({value: 'label', name: I18n.t('labels.title') });
    return creates;
  },

	getOptions: function(){ 
    var dtype = $('.tab-content:visible .new-item').attr('data-type') || 'labels';
    var options = {
      dataType: dtype,
			labelId: null,
      dataTypeName: I18n.t(dtype+'.title'),
      dataTypeTemplate: $('.tab-content:visible .new-item').attr('data-type-template') || null,
      availableCreates: tas10.newDialog.availableCreates()
    };

		if( $('#tas10-find .path-item').length && $('#tas10-find .path-item:last').html().length > 2 ){
			options.labelId = $('.tas10-current-label').val();
			options.labelName = $('.path-item.item_'+options.labelId+'_title:first').text();
		}
		return options;
  },

  singularize: function( str ){
    if( str[str.length-1] === 's' )
      return str.substring(0,str.length-1);
    else
      return str;
  }
}
$(function(){

  $('#button-new-dropdown').hover(function(e){
    $(this).css('opacity', 1) },
    function(e){
      if( !$('.new-dropdown-content').is(':visible') )
        $(this).css('opacity', 0.5)
    }).on('click', function(e){
    if( !$(e.target).closest('.trigger').length )
      return;
    if( $(this).find('.new-dropdown-content').is(':visible') ){
      $(this).find('.new-dropdown-content').slideUp(200);
      return;
    }
    $('.new-dropdown-content').html(
      $('#new-popover-template-content').render(tas10.newDialog.getOptions())
    );
    $('.new-dropdown-content').slideDown(200, function(){
      $('.new-dropdown-content input[type=text]:first').focus();
    	$('.new-dropdown-content .dropdown-menu li').on('click', function(){
    		$(this).closest('form').find('input[name=_type]').val( $(this).attr('data-name') );
        $(this).closest('form').find('input[name=name]').focus();
    		$(this).closest('form').find('.dataTypeName').text( $(this).text() );
    	})
    	$('.new-dropdown-content form').on('submit', function(){
    		var appName = $(this).find('input[name=_type]').val();
    		$(this).attr('action', appName);
    		$(this).append('<input type="hidden" name="'+tas10.newDialog.singularize(appName)+'[label_ids]" value="'+$(this).find('input[name=label_ids]').val()+'" />');
    		$(this).append('<input type="hidden" name="'+tas10.newDialog.singularize(appName)+'[name]" value="'+$(this).find('input[name=name]').val()+'" />');
    	});
    });
  });

});