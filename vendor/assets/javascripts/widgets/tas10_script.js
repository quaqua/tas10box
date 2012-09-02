$(function(){

  $('.available-scripts li.script-url').live('click', function(){
    $.ajax({ url: '/documents/find', data: $(this).attr('data-url'), dataType: 'script', type: 'post' });
  })

  $('.save-query-script').live('click', function(){
    $.getScript( '/query_scripts/new?query='+$(this).attr('data-query') );
  })

  $('.query-scripts-list .edit-query-script').live('click', function(){
    $.getScript( '/query_scripts/'+$(this).closest('li').attr('data-id')+'/edit' );
  })

  $('.query-scripts-list .delete-query-script').live('click', function(){
    var self = this;
    tas10.confirm( I18n.t('really_delete', {name: $(this).closest('li').find('[data-attr-name]').text()}), function(){
      $.ajax({ url: '/documents/'+$(self).closest('li').attr('data-id'),
               dataType: 'script',
               type: 'delete'
      });
    });
  })
  
});