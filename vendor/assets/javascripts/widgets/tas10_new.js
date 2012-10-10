

tas10.newDialog = {

  availableCreates: function(){
    var creates = $('[data-tas10-creates]').map( function( item, el ){
            return {value: $(el).attr('data-tas10-creates'),
             name: $(el).attr('original-title_sgl') }
          }).get();
    creates.push({value: 'label', name: I18n.t('labels.title') });
    return creates;
  },

	getOptions: function(){ 
    var dtype = $('.tab-content:visible .new-item:first').attr('data-type') || 'labels';
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
        if( $(this).find('input[name=template]').val().length > 0 )
          $(this).append('<input type="hidden" name="'+tas10.newDialog.singularize(appName)+'[template]" value="'+$(this).find('input[name=template]').val()+'" />');
    		$(this).append('<input type="hidden" name="'+tas10.newDialog.singularize(appName)+'[name]" value="'+$(this).find('input[name=name]').val()+'" />');
    	});
    });
  });

});