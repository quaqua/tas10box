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
		},
		formattedFileSize: function(size){
			var s = parseInt(parseFloat(size) / 1024).toString()
			return s + 'kb';
		},
		formattedCurrency: function( amount ){
			var a = accounting.formatMoney(amount);
			if ( parseInt(amount) < 0 )
				return "<span style=\"color:red\">"+a+"</span>";
			return a;
		},
		notBlank: function( value ){
			if( value && value.length > 0 )
				return true;
			else
				return false;
		}

	})

});