$(function(){
	
	$.views.helpers({
		formattedDate: function( d, format ){
			if( typeof format === 'undefined' )
				format = 'DD.MM.YYYY HH:mm';
			var t = moment( d ).format(format);
			return t;
		},
		t: function( str ){
			return I18n.t( str );
		},
		colorTemplates: ['#aa9d73','#6d87d6','#22884f','#bf4e30','#85a000'],
		defined: function( val ){
			return typeof( val ) !== 'undefined';
		},
		isObject: function( val ){
			return (typeof( val ) === 'object' && val);
		}
	})

});