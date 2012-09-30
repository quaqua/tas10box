/*
 * labeling
 */

$(function(){
  
  $('.tas10-labels .add').live('click', function(){
    var form = $(this).closest('.tas10-labels').find('form').clone();
    var left = $(this).offset().left;
    if ( $(this).offset().left + 380 > $(window).width())
      left = ($(window).width() - 400);
    $('body').append(form);
    $(form).addClass('tas10-labels-form').css({top: $(this).offset().top, left: left}).show();
    if( ! $(form).find('.ui-autocomplete-input').length )
      $(form).find('.select-label-combobox').tas10Combobox({ url: '/labels',
        submitOnSelect: true
      });
    $(form).find('.ui-autocomplete-input').focus();
  });

  $('.tas10-labels .remove').live('click', function(){
    $.ajax({ url: '/documents/'+$(this).closest('.tas10-labels').attr('data-id')+'/labels/'+$(this).closest('.tas10-label').attr('data-id'),
         type: 'delete',
         dataType: 'script'
    });
  })
});