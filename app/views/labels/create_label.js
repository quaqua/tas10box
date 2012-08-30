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
<% end %>

<%= render "common/process_flash" %>