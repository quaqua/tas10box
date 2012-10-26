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

    if( arguments[0] === 'showMessage' && arguments[1].length > 0 ){
      var error = arguments[2]
        , msg = $('<div/>')
        , msgs = $(this).find('.wizard-messages');
      if( error )
        msg.addClass('error');
      msg.html( arguments[1] );
      msgs.html( msg ).slideDown(200);
      if( $(window).scrollTop() > msgs.offset().top ){
        var transientMessage = $('<div id="transientMessage"/>')
        transientMessage.attr('class', msgs.attr('class'))
        transientMessage.css({ position: 'fixed', top: 10, left: msgs.offset().left, margin: 0, width: msgs.width()})
        transientMessage.html( msgs.html() ).show();
        $('body').append(transientMessage)
        setTimeout( function(){ transientMessage.animate( {top: -100} ); }, 2000 );
        setTimeout( function(){ transientMessage.remove(); }, 2500 );
      }
      return;
    }

    if( arguments[0] === 'hideMessage' ){
      $(this).find('.wizard-messages').html( msg ).hide();
      return;
    }

    var _options = { i18n: { step: "Schritt", next: "Weiter", submit: "Abschicken", prev: "Zurück" }, summary: false }
      , self = this;

    $.extend( _options, options );

    if( this.hasClass('tas10-wizard-init') )
      return;
    this.addClass('tas10-wizard-init');

    this.prepend($('<div class="wizard-content"><div class="wizard-messages"></div><div class="wizard-header"/></div>'));
    var footer = $('<div class="wizard-footer" />');
    footer.append($('<button class="button prev">'+_options.i18n.prev+'</button>'));
    footer.append($('<button class="button next">'+_options.i18n.next+'</button>'));
    footer.append($('<button class="button submit">'+_options.i18n.submit+'</button>'));
    this.append(footer);

    this.find('fieldset').hide().addClass('wizard').each(function(i, fieldset){
      var title;
      if( $(window).width() > 767 ){
        title = $('<div class="title pull-left" data-anchor="'+i+'"><h1>'+_options.i18n.step+' ' + (i+1).toString() + '</h1></div>');
        title.append($('<p/>').text($(fieldset).find('legend').text()));
      } else
        title = $('<div class="title pull-left" data-anchor="'+i+'"><h1>'+(i+1).toString()+'</h1></div>');
      self.find('.wizard-header').append(title);
      $(fieldset).find('legend').hide();
    })

    self.find('.wizard-header .title').on('click', function(){
      self.find('button.submit').hide();
      if( self.find('.wizard-header .title.active') &&
          parseInt($(this).attr('data-anchor')) >
          parseInt(self.find('.wizard-header .title.active').attr('data-anchor'))
           ){
        if( $(self).find('fieldset.active').length && $(self).find('fieldset.active').attr('data-validate') ){
          if( !eval($(self).find('fieldset.active').attr('data-validate')+'.call(self)' ) )
            return;
        }
      }
      $(self).find('fieldset').removeClass('active').hide();
      self.find('.wizard-header .title.active').removeClass('active');
      $(this).addClass('active');
      $(self.find('fieldset')[parseInt($(this).attr('data-anchor'))]).fadeIn(300).addClass('active');
      if( parseInt($(this).attr('data-anchor')) > 0 )
        $(self).find('button.prev').show();
      else
        $(self).find('button.prev').hide();
      if( parseInt($(this).attr('data-anchor')) < $(self).find('fieldset').length -1 )
        $(self).find('button.next').show();
      else{
        $(self).find('button.next').hide();
        $(self).find('button.submit').show();
      }

    });

    self.find('button.button').on('click', function(e){
      e.preventDefault();
      if( $(this).hasClass('next') )
        self.find('.title.active').next('.title').click();
      else if( $(this).hasClass('submit') )
        $(self).find('form').submit();
      else
        self.find('.title.active').prev('.title').click();
    })

    self.find('.wizard-header .title:first').click();

  };

})( jQuery );