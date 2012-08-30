/*
 * labeling
 */

$(function(){
  $('.tas10-labels .add').live('click', function(){
    var form = $(this).closest('.tas10-labels').find('form').clone();
    $('body').append(form);
    $(form).addClass('tas10-labels-form').css({top: $(this).offset().top, left: $(this).offset().left}).show();
    if( ! $(form).find('.ui-autocomplete-input').length )
      $(form).find('.select-label-combobox').tas10Combobox({ url: '/labels',
        submitOnSelect: true
      });
    $(form).find('.ui-autocomplete-input').focus();
  });

  $('.tas10-labels .remove').live('click', function(){
    $.ajax({ url: '/documents/'+$(this).closest('.tas10-labels').attr('data-id')+'/labels/'+$(this).closest('.tas10-label').attr('data-id'),
         type: 'delete',
         success: function( data ){
          if( data.flash && data.flash.info.length ){
            $('.tas10-labels[data-id='+data.doc._id+'] .tas10-label[data-id='+data.label._id+']').remove();
            $('[data-id='+data.label._id+'] [data-id='+data.doc._id+']').remove();
            $('#tas10-browser-tree').tastenboxTree( 'append', data.doc );
           }
          tas10.flash(data.flash);
         }
    });
  })
});