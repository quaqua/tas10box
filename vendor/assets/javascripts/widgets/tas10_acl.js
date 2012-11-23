/*
 * acl
 */

tas10['showAclMiniDialog'] = function showAclMiniDialog( elem, action, showTitle ){
  var form = $($('#acl-form-template').render({ action: action, 
    parentElemId: $(elem).closest('.action-container').attr('id'), showTitle: (showTitle || false) }));
  $('body').append(form);
  var left = $(elem).offset().left;
  if ( $(elem).offset().left + 380 > $(window).width())
    left = ($(window).width() - 400);
  $(form).css({top: $(elem).offset().top, left: left}).show();
  if( ! $(form).find('.ui-autocomplete-input').length ){
    $(form).find('.select-user-combobox').tas10Combobox({ 
      submitOnSelect: true,
      url: '/users/' + $('#account-info').data('id') + '/known',
      emptyDataCallback: function(select, val){
        var validEmail = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if( validEmail.test( val) ){
          var docIds = [];
          $(elem).closest('.action-container').find('.selected-item').each( function(){
            docIds.push( $(this).attr('data-id') );
          });
          $(select).closest('.tas10-acl-form').find('.create-button').show();
          var form = $(select).closest('.tas10-acl-form');
          $(form).find('input[name=doc_ids]').val( docIds.join(',') );
          $(form).find('input[name=email]').val( $(form).find('.ui-autocomplete-input').val() );
        } else
          $(select).closest('.tas10-acl-form').find('.create-button').hide();
      },
      hasDataCallback: function(select){
        $(select).closest('.tas10-acl-form').find('.create-button').hide();
      }
    });
    //$(form).find('.ui-autocomplete-input').on()
  }
  $(form).find('.ui-autocomplete-input').focus();
}

$(function(){

  $('.tas10-acl-priv').live('click', function(e){
    e.preventDefault();
    if( $(this).hasClass('read') )
      if( $(this).hasClass('sel') )
        $(this).next('.tas10-acl-priv').removeClass('sel').next('.tas10-acl-priv').removeClass('sel').next('.tas10-acl-priv').removeClass('sel');
    if( $(this).hasClass('write') )
      if( $(this).hasClass('sel') )
        $(this).next('.tas10-acl-priv').removeClass('sel').next('.tas10-acl-priv').removeClass('sel');
      else
        $(this).next('.tas10-acl-priv').addClass('sel');
    if( $(this).hasClass('share') )
      if( $(this).hasClass('sel') )
        $(this).next('.tas10-acl-priv').removeClass('sel');
      else
        $(this).prev('.tas10-acl-priv').addClass('sel').prev('.tas10-acl-priv').addClass('sel');
    if( $(this).hasClass('del') && !$(this).hasClass('sel') )
        $(this).prev('.tas10-acl-priv').addClass('sel').prev('.tas10-acl-priv').addClass('sel').prev('.tas10-acl-priv').addClass('sel')
    $(this).toggleClass('sel');
    var selPrivileges = ""
      , form = $(this).closest('form');
    $(form).find('.sel').each(function(){
      selPrivileges = selPrivileges + $(this).text();
    });
    $(form).find('input[name=privileges]').val(selPrivileges);
  });

  $('.tas10-acl .add').live('click', function(){
    tas10.showAclMiniDialog(this, $(this).attr('data-url') );
  });

  $('.tas10-acl-entry .remove').live('click', function(){
    $.ajax({ url: '/documents/'+$(this).closest('.tas10-acl').data('id')+'/acl/'+$(this).closest('.tas10-acl-entry').data('id'),
         type: 'delete',
         dataType: 'script'
    });
  });

  $('.tas10-acl-form .create-button').live('click', function(){
    var form = $(this).closest('form')
    $(form).submit();
  });

});