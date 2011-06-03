/**
 * getXPath jQuery plugin v0.1
 * @copyright	Copyright (c) 2010, Ben Cawkwell
 * @author		Ben Cawkwell
 * @version		0.1.0
 */

(function($)
{
	//
	// getXPath function
	//
	$.fn.getXPath = function(options)
	{
		// build main options before element iteration
		var opts = $.extend({}, $.fn.getXPath.defaults, options);
		// Array to store values
		var paths = [];
		// iterate and calculate each element
		this.each(
			function()
			{
				var path = '';
				var element = this;
				for (; element && element.nodeType==1; element=element.parentNode)
				{
					var idx=$(element.parentNode).children(element.tagName).index(element)+1;
					idx>1 ? (idx='['+idx+']') : (idx='');
					path='/'+element.tagName.toLowerCase()+idx+path;
				}
				paths.push(path);
			}
		)
		return paths;
	};
	//
	// evalXPath function
	//
	$.fn.evalXPath = function(paths,options)
	{
		// build main options
		var opts = $.extend({}, $.fn.getXPath.defaults, options);
		// normalise paths to an array
		if (typeof(paths) == 'string') {
			paths = [paths];
		}
		// List to hold the elements
		var elements = [];
		// iterate and calculate each element
		$.each(paths,
			function(index,xpath)
			{
				if (document.evaluate) //firefox
				{
					var element = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
				}
				else //ie can not use xmldocument.selectSingleNode(xpath);
				{
					var tags=xpath.slice(1).split('/');
					var ele=document;
					for (var i=0; i<tags.length; ++i)
					{
						var idx=1;
						if (tags[i].indexOf('[')!=-1)
						{
							idx=tags[i].split('[')[1].split(']')[0];
							tags[i]=tags[i].split('[')[0];
						}
						var ele=$(ele).children(tags[i])[idx-1];
					}
					var element = ele;
				}
				elements.push(element);
			}
		)
		return $(elements);
	};

	//
	// plugin defaults
	//
	$.fn.getXPath.defaults ={};

//
// end of closure
//
})(jQuery);
