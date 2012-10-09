/**
 * tas10wizard - a form wizard
 * by TAS10WERK http://tas10werk.com
 *
 * turns a set of fieldsets in a nice form wizard
 * including validation
 *
 * LICENSE: MIT
 *
 * DATE: Oct/2012
 *
 */

(function( jQuery ){

  jQuery.fn.tas10Wizard = function( options ) {

    var _options = { i18n: { step: "Schritt", next: "Weiter", prev: "Zurück" }, summary: false }
      , self = this;

    $.extend( _options, options );

    if( this.hasClass('tas10-wizard-init') )
      return;
    this.addClass('tas10-wizard-init');

    this.prepend($('<div class="wizard-content"><div class="wizard-header"/></div>'));
    var footer = $('<div class="wizard-footer" />');
    footer.append($('<button class="button prev">'+_options.i18n.prev+'</button>'));
    footer.append($('<button class="button next">'+_options.i18n.next+'</button>'));
    this.append(footer);

    this.find('fieldset').hide().addClass('wizard').each(function(i, fieldset){
      var title = $('<div class="title pull-left" data-anchor="'+i+'"><h1>'+_options.i18n.step+' ' + (i+1).toString() + '</h1></div>');
      title.append($('<p/>').text($(fieldset).find('legend').text()));
      self.find('.wizard-header').append(title);
      $(fieldset).find('legend').hide();
    })

    self.find('.wizard-header .title').on('click', function(){
      $(self).find('fieldset').hide();
      self.find('.wizard-header .title.active').removeClass('active');
      $(this).addClass('active');
      $(self.find('fieldset')[parseInt($(this).attr('data-anchor'))]).fadeIn(300);
      if( parseInt($(this).attr('data-anchor')) > 0 )
        $(self).find('button.prev').show();
      else
        $(self).find('button.prev').hide();
      if( parseInt($(this).attr('data-anchor')) < $(self).find('fieldset').length -1 )
        $(self).find('button.next').show();
      else
        $(self).find('button.next').hide();
    });

    self.find('button.button').on('click', function(e){
      e.preventDefault();
      if( $(this).hasClass('next') )
        self.find('.title.active').next('.title').click();
      else
        self.find('.title.active').prev('.title').click();
    })

    self.find('.wizard-header .title:first').click();

  };

})( jQuery );