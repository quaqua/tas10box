$(function(){
	
	$.views.helpers({
		formattedDate: function( d ){
			var t = moment( d ).format('DD.MM.YYYY HH:mm');
			return t;
		},
		t: function( str ){
			return I18n.t( str );
		},
		colorTemplates: ['#aa9d73','#6d87d6','#22884f','#bf4e30','#85a000'],
		defined: function( val ){
			return typeof( val ) !== 'undefined';
		}
	})

});