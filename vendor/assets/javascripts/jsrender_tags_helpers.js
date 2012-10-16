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
			if( typeof(amount) === 'undefined')
				amount = 0;
			a = amount.toString();
			if( a.split('.').length < 2 )
				a += ".00"
			else{
				var comma = a.split('.')[1];
				if( comma.length < 1 )
					a += "00";
				else if( comma.length < 2 )
					a += "0";
				else
					a += comma.substring(0,2);
			}
			a += " EUR";
			if( a.indexOf('-') === 0 )
				a = "<span style=\"color:red\">" + a + "</span>"
			return a;
		}
	})

});