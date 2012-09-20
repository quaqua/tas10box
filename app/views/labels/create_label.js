<% if flash[:notice] %>
  alert('he');
  $('#button_new_dialog').popover('hide');
  var doc = <%= raw( @doc.to_json ) %>;
  $('.tas10-labels-form').remove();
  $('.tas10-labels[data-id=<%= @doc.id %>]').append(' <%= escape_javascript( render :partial => "common/snippets/label", :locals => {:label => @label} ) %>');
  // if first label, remove self everywhere
  $('li[data-id=<%= @doc.id %>]').remove();
  // and fill it in again where it belongs to
  $('#tas10-browser-tree').tas10Tree( 'append', doc );
  // also in table
  <% @doc.label_ids.each do |label_id| %>
    $('#tas10-table-<%= label_id %>').tas10Table('append', doc);
    $('#tas10-list-<%= label_id %>').tas10List('append', doc);
  <% end %>
<% end %>

<%= render "common/process_flash" %>