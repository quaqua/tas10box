tas10['rightPanel'] = function tas10RightPanel( action, text, callback ){

  var rightPanelControl = $('.tas10-right-panel-control:visible');
  var rightPanel = $('.tas10-right-panel-control:visible').closest('.tab-content').find('.tas10-right-panel');

  if( action === 'hide' ){
    rightPanel.animate({right: -250}, 'easeOutQuart').delay(500).hide();
    if( rightPanelControl.css('position').match(/static|relative/) )
      rightPanelControl.css({right: 0, width: rightPanelControl.width()+260})
    else
      rightPanelControl.css('marginRight', 0);
    return;
  }

  rightPanel.html('<div class="close-button float-right cursor-pointer"><span class="ui-icon ui-icon-closethick float-right" onclick="tas10.rightPanel(\'hide\');"></span></div>');

  var content = $('<div class="tas10-tas10-right-panel-content" />').append( text );
  rightPanel.append( content );

  if( !rightPanel.is(':visible') ){
    rightPanel.show().animate({right: 0}, 'easeInQuart');
    console.log( 'rcontrol', rightPanelControl.first().css('position') );
    if( rightPanelControl.css('position').match(/static|relative/) )
      rightPanelControl.css({right: 260, width: rightPanelControl.width()-260})
    else
      rightPanelControl.css('marginRight', 260)
  }
  
  if( typeof(callback) === 'function' )
    callback( rightPanel );
}
