/**
* vkBeautify - javascript plugin to pretty-print or minify text in XML, JSON, CSS and SQL formats.
*  
* Version - 0.99.00.beta 
* Copyright (c) 2012 Vadim Kiryukhin
* vkiryukhin @ gmail.com
* http://www.eslinstructor.net/vkbeautify/
* 
* Dual licensed under the MIT and GPL licenses:
*   http://www.opensource.org/licenses/mit-license.php
*   http://www.gnu.org/licenses/gpl.html
*
*   Pretty print
*
*        vkbeautify.xml(text [,indent_pattern]);
*        vkbeautify.json(text [,indent_pattern]);
*        vkbeautify.css(text [,indent_pattern]);
*        vkbeautify.sql(text [,indent_pattern]);
*
*        @text - String; text to beatufy;
*        @indent_pattern - Integer | String;
*                Integer:  number of white spaces;
*                String:   character string to visualize indentation ( can also be a set of white spaces )
*   Minify
*
*        vkbeautify.xmlmin(text [,preserve_comments]);
*        vkbeautify.jsonmin(text);
*        vkbeautify.cssmin(text [,preserve_comments]);
*        vkbeautify.sqlmin(text);
*
*        @text - String; text to minify;
*        @preserve_comments - Bool; [optional];
*                Set this flag to true to prevent removing comments from @text ( minxml and mincss functions only. )
*
*   Examples:
*        vkbeautify.xml(text); // pretty print XML
*        vkbeautify.json(text, 4 ); // pretty print JSON
*        vkbeautify.css(text, '. . . .'); // pretty print CSS
*        vkbeautify.sql(text, '----'); // pretty print SQL
*
*        vkbeautify.xmlmin(text, true);// minify XML, preserve comments
*        vkbeautify.jsonmin(text);// minify JSON
*        vkbeautify.cssmin(text);// minify CSS, remove comments ( default )
*        vkbeautify.sqlmin(text);// minify SQL
*
*/

(function() {

function createShiftArr(step) {

	var space = '    ';
	
	if ( isNaN(parseInt(step)) ) {  // argument is string
		space = step;
	} else { // argument is integer
		switch(step) {
			case 1: space = ' '; break;
			case 2: space = '  '; break;
			case 3: space = '   '; break;
			case 4: space = '    '; break;
			case 5: space = '     '; break;
			case 6: space = '      '; break;
			case 7: space = '       '; break;
			case 8: space = '        '; break;
			case 9: space = '         '; break;
			case 10: space = '          '; break;
			case 11: space = '           '; break;
			case 12: space = '            '; break;
		}
	}

	var shift = ['\n']; // array of shifts
	for(ix=0;ix<100;ix++){
		shift.push(shift[ix]+space); 
	}
	return shift;
}

function vkbeautify(){
	this.step = '    '; // 4 spaces
	this.shift = createShiftArr(this.step);
};

vkbeautify.prototype.xml = function(text,step) {

	var ar = text.replace(/>\s{0,}</g,"><")
				 .replace(/</g,"~::~<")
				 .replace(/\s*xmlns\:/g,"~::~xmlns:")
				 .replace(/\s*xmlns\=/g,"~::~xmlns=")
				 .split('~::~'),
		len = ar.length,
		inComment = false,
		deep = 0,
		str = '',
		ix = 0,
		shift = step ? createShiftArr(step) : this.shift;

		for(ix=0;ix<len;ix++) {
			// start comment or <![CDATA[...]]> or <!DOCTYPE //
			if(ar[ix].search(/<!/) > -1) { 
				str += shift[deep]+ar[ix];
				inComment = true; 
				// end comment  or <![CDATA[...]]> //
				if(ar[ix].search(/-->/) > -1 || ar[ix].search(/\]>/) > -1 || ar[ix].search(/!DOCTYPE/) > -1 ) { 
					inComment = false; 
				}
			} else 
			// end comment  or <![CDATA[...]]> //
			if(ar[ix].search(/-->/) > -1 || ar[ix].search(/\]>/) > -1) { 
				str += ar[ix];
				inComment = false; 
			} else 
			// <elm></elm> //
			if( /^<\w/.exec(ar[ix-1]) && /^<\/\w/.exec(ar[ix]) &&
				/^<[\w:\-\.\,]+/.exec(ar[ix-1]) == /^<\/[\w:\-\.\,]+/.exec(ar[ix])[0].replace('/','')) { 
				str += ar[ix];
				if(!inComment) deep--;
			} else
			 // <elm> //
			if(ar[ix].search(/<\w/) > -1 && ar[ix].search(/<\//) == -1 && ar[ix].search(/\/>/) == -1 ) {
				str = !inComment ? str += shift[deep++]+ar[ix] : str += ar[ix];
			} else 
			 // <elm>...</elm> //
			if(ar[ix].search(/<\w/) > -1 && ar[ix].search(/<\//) > -1) {
				str = !inComment ? str += shift[deep]+ar[ix] : str += ar[ix];
			} else 
			// </elm> //
			if(ar[ix].search(/<\//) > -1) { 
				str = !inComment ? str += shift[--deep]+ar[ix] : str += ar[ix];
			} else 
			// <elm/> //
			if(ar[ix].search(/\/>/) > -1 ) { 
				str = !inComment ? str += shift[deep]+ar[ix] : str += ar[ix];
			} else 
			// <? xml ... ?> //
			if(ar[ix].search(/<\?/) > -1) { 
				str += shift[deep]+ar[ix];
			} else 
			// xmlns //
			if( ar[ix].search(/xmlns\:/) > -1  || ar[ix].search(/xmlns\=/) > -1) { 
				str += shift[deep]+ar[ix];
			} 
			
			else {
				str += ar[ix];
			}
		}
		
	return  (str[0] == '\n') ? str.slice(1) : str;
}

vkbeautify.prototype.json = function(text,step) {

	var step = step ? step : this.step;
	
	if (typeof JSON === 'undefined' ) return text; 
	
	if ( typeof text === "string" ) return JSON.stringify(JSON.parse(text), null, step);
	if ( typeof text === "object" ) return JSON.stringify(text, null, step);
		
	return text; // text is not string nor object
}

vkbeautify.prototype.css = function(text, step) {

	var ar = text.replace(/\s{1,}/g,' ')
				.replace(/\{/g,"{~::~")
				.replace(/\}/g,"~::~}~::~")
				.replace(/\;/g,";~::~")
				.replace(/\/\*/g,"~::~/*")
				.replace(/\*\//g,"*/~::~")
				.replace(/~::~\s{0,}~::~/g,"~::~")
				.split('~::~'),
		len = ar.length,
		deep = 0,
		str = '',
		ix = 0,
		shift = step ? createShiftArr(step) : this.shift;
		
		for(ix=0;ix<len;ix++) {

			if( /\{/.exec(ar[ix]))  { 
				str += shift[deep++]+ar[ix];
			} else 
			if( /\}/.exec(ar[ix]))  { 
				str += shift[--deep]+ar[ix];
			} else
			if( /\*\\/.exec(ar[ix]))  { 
				str += shift[deep]+ar[ix];
			}
			else {
				str += shift[deep]+ar[ix];
			}
		}
		return str.replace(/^\n{1,}/,'');
}

//----------------------------------------------------------------------------

function isSubquery(str, parenthesisLevel) {
	return  parenthesisLevel - (str.replace(/\(/g,'').length - str.replace(/\)/g,'').length )
}

function split_sql(str, tab) {

	return str.replace(/\s{1,}/g," ")

				.replace(/ AND /ig,"~::~"+tab+tab+"AND ")
				.replace(/ BETWEEN /ig,"~::~"+tab+"BETWEEN ")
				.replace(/ CASE /ig,"~::~"+tab+"CASE ")
				.replace(/ ELSE /ig,"~::~"+tab+"ELSE ")
				.replace(/ END /ig,"~::~"+tab+"END ")
				.replace(/ FROM /ig,"~::~FROM ")
				.replace(/ GROUP\s{1,}BY/ig,"~::~GROUP BY ")
				.replace(/ HAVING /ig,"~::~HAVING ")
				//.replace(/ SET /ig," SET~::~")
				.replace(/ IN /ig," IN ")
				
				.replace(/ JOIN /ig,"~::~JOIN ")
				.replace(/ CROSS~::~{1,}JOIN /ig,"~::~CROSS JOIN ")
				.replace(/ INNER~::~{1,}JOIN /ig,"~::~INNER JOIN ")
				.replace(/ LEFT~::~{1,}JOIN /ig,"~::~LEFT JOIN ")
				.replace(/ RIGHT~::~{1,}JOIN /ig,"~::~RIGHT JOIN ")
				
				.replace(/ ON /ig,"~::~"+tab+"ON ")
				.replace(/ OR /ig,"~::~"+tab+tab+"OR ")
				.replace(/ ORDER\s{1,}BY/ig,"~::~ORDER BY ")
				.replace(/ OVER /ig,"~::~"+tab+"OVER ")

				.replace(/\(\s{0,}SELECT /ig,"~::~(SELECT ")
				.replace(/\)\s{0,}SELECT /ig,")~::~SELECT ")
				
				.replace(/ THEN /ig," THEN~::~"+tab+"")
				.replace(/ UNION /ig,"~::~UNION~::~")
				.replace(/ USING /ig,"~::~USING ")
				.replace(/ WHEN /ig,"~::~"+tab+"WHEN ")
				.replace(/ WHERE /ig,"~::~WHERE ")
				.replace(/ WITH /ig,"~::~WITH ")
				
				//.replace(/\,\s{0,}\(/ig,",~::~( ")
				//.replace(/\,/ig,",~::~"+tab+tab+"")

				.replace(/ ALL /ig," ALL ")
				.replace(/ AS /ig," AS ")
				.replace(/ ASC /ig," ASC ")	
				.replace(/ DESC /ig," DESC ")	
				.replace(/ DISTINCT /ig," DISTINCT ")
				.replace(/ EXISTS /ig," EXISTS ")
				.replace(/ NOT /ig," NOT ")
				.replace(/ NULL /ig," NULL ")
				.replace(/ LIKE /ig," LIKE ")
				.replace(/\s{0,}SELECT /ig,"SELECT ")
				.replace(/\s{0,}UPDATE /ig,"UPDATE ")
				.replace(/ SET /ig," SET ")
							
				.replace(/~::~{1,}/g,"~::~")
				.split('~::~');
}

vkbeautify.prototype.sql = function(text,step) {

	var ar_by_quote = text.replace(/\s{1,}/g," ")
							.replace(/\'/ig,"~::~\'")
							.split('~::~'),
		len = ar_by_quote.length,
		ar = [],
		deep = 0,
		tab = this.step,//+this.step,
		inComment = true,
		inQuote = false,
		parenthesisLevel = 0,
		str = '',
		ix = 0,
		shift = step ? createShiftArr(step) : this.shift;;

		for(ix=0;ix<len;ix++) {
			if(ix%2) {
				ar = ar.concat(ar_by_quote[ix]);
			} else {
				ar = ar.concat(split_sql(ar_by_quote[ix], tab) );
			}
		}
		
		len = ar.length;
		for(ix=0;ix<len;ix++) {
			
			parenthesisLevel = isSubquery(ar[ix], parenthesisLevel);
			
			if( /\s{0,}\s{0,}SELECT\s{0,}/.exec(ar[ix]))  { 
				ar[ix] = ar[ix].replace(/\,/g,",\n"+tab+tab+"")
			} 
			
			if( /\s{0,}\s{0,}SET\s{0,}/.exec(ar[ix]))  { 
				ar[ix] = ar[ix].replace(/\,/g,",\n"+tab+tab+"")
			} 
			
			if( /\s{0,}\(\s{0,}SELECT\s{0,}/.exec(ar[ix]))  { 
				deep++;
				str += shift[deep]+ar[ix];
			} else 
			if( /\'/.exec(ar[ix]) )  { 
				if(parenthesisLevel<1 && deep) {
					deep--;
				}
				str += ar[ix];
			}
			else  { 
				str += shift[deep]+ar[ix];
				if(parenthesisLevel<1 && deep) {
					deep--;
				}
			} 
			var junk = 0;
		}

		str = str.replace(/^\n{1,}/,'').replace(/\n{1,}/g,"\n");
		return str;
}


vkbeautify.prototype.xmlmin = function(text, preserveComments) {

	var str = preserveComments ? text
							   : text.replace(/\<![ \r\n\t]*(--([^\-]|[\r\n]|-[^\-])*--[ \r\n\t]*)\>/g,"")
									 .replace(/[ \r\n\t]{1,}xmlns/g, ' xmlns');
	return  str.replace(/>\s{0,}</g,"><"); 
}

vkbeautify.prototype.jsonmin = function(text) {

	if (typeof JSON === 'undefined' ) return text; 
	
	return JSON.stringify(JSON.parse(text), null, 0); 
				
}

vkbeautify.prototype.cssmin = function(text, preserveComments) {
	
	var str = preserveComments ? text
							   : text.replace(/\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\//g,"") ;

	return str.replace(/\s{1,}/g,' ')
			  .replace(/\{\s{1,}/g,"{")
			  .replace(/\}\s{1,}/g,"}")
			  .replace(/\;\s{1,}/g,";")
			  .replace(/\/\*\s{1,}/g,"/*")
			  .replace(/\*\/\s{1,}/g,"*/");
}

vkbeautify.prototype.sqlmin = function(text) {
	return text.replace(/\s{1,}/g," ").replace(/\s{1,}\(/,"(").replace(/\s{1,}\)/,")");
}

window.vkbeautify = new vkbeautify();

})();


if (typeof jQuery !== 'undefined') {
	(function($) {
		$('#spinner').ajaxStart(function() {
			$(this).fadeIn();
		}).ajaxStop(function() {
			$(this).fadeOut();
		});
	})(jQuery);
}
// deprecated
$('#debug').click(function () {
    $(this).next().toggle();
});
// handles debug sections
$('.expandable-debug').each(function() {
    $(this).find('div,pre,ul').hide();
    $(this).find('h1,h2,h3,h4,h5')
        .css('cursor','pointer')
        .css('color','grey')
        .click(function () {
            $(this).next().toggle();
        })
        .hover(
            function () { $(this).css('text-decoration','underline') },
            function () { $(this).css('text-decoration','none') }
        );
    // pretty print sections with class pretty
    if (vkbeautify && typeof vkbeautify.json === 'function') {
        $(this).find('pre').each(function() {
            var value = $(this).html();
            if (value !== '') {
                try {
                    $(this).html(vkbeautify.json(value));
                } catch (e) {
                    $(this).html(value);
                }
            }
        });
    }
});

// returns blank string if the property is undefined, else the value
function orBlank(v) {
    return v === undefined ? '' : v;
}
function orFalse(v) {
    return v === undefined ? false : v;
}
function orZero(v) {
    return v === undefined ? 0 : v;
}
function orEmptyArray(v) {
    return v === undefined ? [] : v;
}

function fixUrl(url) {
    return typeof url == 'string' && url.indexOf("://") < 0? ("http://" + url): url;
}

function exists(parent, prop) {
    if(parent === undefined)
        return '';
    if(parent == null)
        return '';
    if(parent[prop] === undefined)
        return '';
    if(parent[prop] == null)
        return '';
    if(ko.isObservable(parent[prop])){
        return parent[prop]();
    }
    return parent[prop];
}

function neat_number (number, decimals) {
    var str = number_format(number, decimals);
    if (str.indexOf('.') === -1) {
        return str;
    }
    // trim trailing zeros beyond the decimal point
    while (str[str.length-1] === '0') {
        str = str.substr(0, str.length - 1);
    }
    if (str[str.length-1] === '.') {
        str = str.substr(0, str.length - 1);
    }
    return str;
}

function number_format (number, decimals, dec_point, thousands_sep) {
    // http://kevin.vanzonneveld.net
    // +   original by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +     bugfix by: Michael White (http://getsprink.com)
    // +     bugfix by: Benjamin Lupton
    // +     bugfix by: Allan Jensen (http://www.winternet.no)
    // +    revised by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)
    // +     bugfix by: Howard Yeend
    // +    revised by: Luke Smith (http://lucassmith.name)
    // +     bugfix by: Diogo Resende
    // +     bugfix by: Rival
    // +      input by: Kheang Hok Chin (http://www.distantia.ca/)
    // +   improved by: davook
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // +      input by: Jay Klehr
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // +      input by: Amir Habibi (http://www.residence-mixte.com/)
    // +     bugfix by: Brett Zamir (http://brett-zamir.me)
    // +   improved by: Theriault
    // +      input by: Amirouche
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // *     example 1: number_format(1234.56);
    // *     returns 1: '1,235'
    // *     example 2: number_format(1234.56, 2, ',', ' ');
    // *     returns 2: '1 234,56'
    // *     example 3: number_format(1234.5678, 2, '.', '');
    // *     returns 3: '1234.57'
    // *     example 4: number_format(67, 2, ',', '.');
    // *     returns 4: '67,00'
    // *     example 5: number_format(1000);
    // *     returns 5: '1,000'
    // *     example 6: number_format(67.311, 2);
    // *     returns 6: '67.31'
    // *     example 7: number_format(1000.55, 1);
    // *     returns 7: '1,000.6'
    // *     example 8: number_format(67000, 5, ',', '.');
    // *     returns 8: '67.000,00000'
    // *     example 9: number_format(0.9, 0);
    // *     returns 9: '1'
    // *    example 10: number_format('1.20', 2);
    // *    returns 10: '1.20'
    // *    example 11: number_format('1.20', 4);
    // *    returns 11: '1.2000'
    // *    example 12: number_format('1.2000', 3);
    // *    returns 12: '1.200'
    // *    example 13: number_format('1 000,50', 2, '.', ' ');
    // *    returns 13: '100 050.00'
    // Strip all characters but numerical ones.
    number = (number + '').replace(/[^0-9+\-Ee.]/g, '');
    var n = !isFinite(+number) ? 0 : +number,
        prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
        sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
        dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
        s = '',
        toFixedFix = function (n, prec) {
            var k = Math.pow(10, prec);
            return '' + Math.round(n * k) / k;
        };
    // Fix for IE parseFloat(0.55).toFixed(0) = 0;
    s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
    if (s[0].length > 3) {
        s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
    }
    if ((s[1] || '').length < prec) {
        s[1] = s[1] || '';
        s[1] += new Array(prec - s[1].length + 1).join('0');
    }
    return s.join(dec);
}

/* From:
 * jQuery File Upload User Interface Plugin 6.8.1
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */
function formatBytes(bytes) {
    if (typeof bytes !== 'number') {
        return '';
    }
    if (bytes >= 1000000000) {
        return (bytes / 1000000000).toFixed(2) + ' GB';
    }
    if (bytes >= 1000000) {
        return (bytes / 1000000).toFixed(2) + ' MB';
    }
    return (bytes / 1000).toFixed(2) + ' KB';
}

/**
 Bootstrap Alerts -
 Function Name - showAlert()
 Inputs - message,alerttype,target
 Example - showalert("Invalid Login","alert-error","alert-placeholder")
 Types of alerts -- "alert-error","alert-success","alert-info"
 Required - You only need to add a alert_placeholder div in your html page wherever you want to display these alerts "<div id="alert_placeholder"></div>"
 Written On - 14-Jun-2013
 **/
function showAlert(message, alerttype, target) {

    $('#'+target).append('<div id="alertdiv" class="alert ' +  alerttype + '"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>')

    setTimeout(function() { // this will automatically close the alert and remove this if the users doesnt close it in 5 secs
        $("#alertdiv").remove();
    }, 5000);
}

function blockUIWithMessage(message) {
    $.blockUI({ message: message, fadeIn:0,
        css: {
            border: 'none',
            padding: '15px',
            backgroundColor: '#000',
            '-webkit-border-radius': '10px',
            '-moz-border-radius': '10px',
            opacity: .5,
            color: '#fff'
        } });
}



/**
 * Attaches a simple dirty flag (one shot change detection) to the supplied model, then once the model changes,
 * auto-saves the model using the supplied key every autoSaveIntervalInSeconds seconds.
 * @param viewModel the model to autosave.
 * @param key the (localStorage) key to use when saving the model.
 * @param autoSaveIntervalInSeconds [optional, default=60] how often to autosave the edited model.
 */
function autoSaveModel(viewModel, saveUrl, options) {

    var serializeModel = function() {
        return (typeof viewModel.modelAsJSON === 'function') ? viewModel.modelAsJSON() : ko.toJSON(viewModel);
    };

    var defaults = {
        storageKey:window.location.href+'.autosaveData',
        autoSaveIntervalInSeconds:60,
        restoredDataWarningSelector:"#restoredData",
        resultsMessageId:"save-result-placeholder",
        timeoutMessageSelector:"#timeoutMessage",
        errorMessage:"Failed to save your data: ",
        successMessage:"Save successful!",
        errorCallback:undefined,
        successCallback:undefined,
        blockUIOnSave:false,
        blockUISaveMessage:"Saving...",
        blockUISaveSuccessMessage:"Save successful",
        serializeModel:serializeModel,
        pageExitMessage: 'You have unsaved data.  If you leave the page this data will be lost.',
        preventNavigationIfDirty: false,
        defaultDirtyFlag:ko.simpleDirtyFlag
    };
    var config = $.extend(defaults, options);

    var autosaving = false;

    var deleteAutoSaveData = function() {
        amplify.store(config.storageKey, null);
    };
    var saveLocally = function(data) {
        amplify.store(config.storageKey, data);
    };


    function confirmOnPageExit(e) {
        // If we haven't been passed the event get the window.event
        e = e || window.event;

        // For IE6-8 and Firefox prior to version 4
        if (e) {
            e.returnValue = config.pageExitMessage;
        }

        // For Chrome, Safari, IE8+ and Opera 12+
        return config.pageExitMessage;
    };

    var onunloadHandler = function(e) {
        autosaving = false;
        deleteAutoSaveData();

        return confirmOnPageExit(e);
    };

    var autoSaveModel = function() {
        if (!autosaving) {
            return;
        }

        if (viewModel.dirtyFlag.isDirty()) {
            amplify.store(config.storageKey, serializeModel());
            window.setTimeout(autoSaveModel, config.autoSaveIntervalInSeconds*1000);
        }
    };

    viewModel.cancelAutosave = function() {
        autosaving = false;
        deleteAutoSaveData();
        if (config.preventNavigationIfDirty) {
            window.onbeforeunload = null;
        }
    };

    if (typeof viewModel.dirtyFlag === 'undefined') {
        viewModel.dirtyFlag = config.defaultDirtyFlag(viewModel);
    }
    viewModel.dirtyFlag.isDirty.subscribe(
        function() {
            if (viewModel.dirtyFlag.isDirty()) {
                autosaving = true;

                if (config.preventNavigationIfDirty) {
                    window.onbeforeunload = onunloadHandler;
                }
                window.setTimeout(autoSaveModel, config.autoSaveIntervalInSeconds*1000);
            }
            else {
                viewModel.cancelAutosave();
            }
        }
    );

    viewModel.saveWithErrorDetection = function(successCallback, errorCallback) {
        if (config.blockUIOnSave) {
            blockUIWithMessage(config.blockUISaveMessage);
        }
        $(config.restoredDataWarningSelector).hide();

        var json = config.serializeModel();

        // Store data locally in case the save fails.plan
        amplify.store(config.storageKey, json);

        return $.ajax({
                url: saveUrl,
                type: 'POST',
                data: json,
                contentType: 'application/json'
            }).done(function (data) {
                if (data.error) {
                    if (config.blockUIOnSave) {
                        $.unblockUI();
                    }
                    showAlert(config.errorMessage + data.detail + ' \n' + data.error,
                        "alert-error",config.resultsMessageId);
                    if (typeof errorCallback === 'function') {
                        errorCallback(data);
                    }
                    if (typeof config.errorCallback === 'function') {
                        config.errorCallback(data);
                    }

                } else {
                    if (config.blockUIOnSave) {
                        blockUIWithMessage(config.blockUISaveSuccessMessage);
                    }
                    else {
                        showAlert(config.successMessage, "alert-success", config.resultsMessageId);
                    }
                    viewModel.cancelAutosave();
                    viewModel.dirtyFlag.reset();
                    if (typeof successCallback === 'function') {
                        successCallback(data);
                    }
                    if (typeof config.successCallback === 'function') {
                        config.successCallback(data);
                    }
                }
            })
            .fail(function (data) {
                if (config.blockUIOnSave) {
                    $.unblockUI();
                }
                bootbox.alert($(config.timeoutMessageSelector).html());
                if (typeof errorCallback === 'function') {
                    errorCallback(data);
                }
                if (typeof config.errorCallback === 'function') {
                    config.errorCallback(data);
                }
            });

    }

}

/**
 * Roles have camelCase names and this is a work-around for printing them from AJAX
 * responses.
 * TODO implement i18n encoding with JS
 *
 * @param text
 * @returns {string}
 */
function decodeCamelCase(text) {
    var result = text.replace( /([A-Z])/g, " $1" );
    return result.charAt(0).toUpperCase() + result.slice(1); // capitalize the first letter - as an example.
}

//
if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

/**
 * Document preview modes to content type 'map'
 * @type {{convert: string[], pdf: string[], image: string[], audio: string[], video: string[]}}
 */
var contentTypes = {
    convert: [
        'application/msword',
        'application/ms-excel',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
        'application/vnd.ms-word.document.macroEnabled.12',
        'application/vnd.ms-word.template.macroEnabled.12',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
        'application/vnd.ms-excel.sheet.macroEnabled.12',
        'application/vnd.ms-excel.template.macroEnabled.12',
        'application/vnd.ms-excel.addin.macroEnabled.12',
        'application/vnd.ms-excel.sheet.binary.macroEnabled.12',
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'application/vnd.openxmlformats-officedocument.presentationml.template',
        'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
        'application/vnd.ms-powerpoint.addin.macroEnabled.12',
        'application/vnd.ms-powerpoint.presentation.macroEnabled.12',
        'application/vnd.ms-powerpoint.template.macroEnabled.12',
        'application/vnd.ms-powerpoint.slideshow.macroEnabled.12',
        'application/vnd.oasis.opendocument.chart',
        'application/vnd.oasis.opendocument.chart-template',
        //'application/vnd.oasis.opendocument.database',
        'application/vnd.oasis.opendocument.formula',
        'application/vnd.oasis.opendocument.formula-template',
        'application/vnd.oasis.opendocument.graphics',
        'application/vnd.oasis.opendocument.graphics-template',
        'application/vnd.oasis.opendocument.image',
        'application/vnd.oasis.opendocument.image-template',
        'application/vnd.oasis.opendocument.presentation',
        'application/vnd.oasis.opendocument.presentation-template',
        'application/vnd.oasis.opendocument.spreadsheet',
        'application/vnd.oasis.opendocument.spreadsheet-template',
        'application/vnd.oasis.opendocument.text',
        'application/vnd.oasis.opendocument.text-master',
        'application/vnd.oasis.opendocument.text-template',
        'application/vnd.oasis.opendocument.text-web',
        'text/html',
        'text/plain'
    ],
    pdf: [
        'application/pdf',
        'text/pdf'
    ],
    image: [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/bmp'
    ],
    audio: [
        'audio/webm',
        'audio/ogg',
        'audio/wave',
        'audio/wav',
        'audio/x-wav',
        'audio/x-pn-wav',
        'audio/mpeg',
        'audio/mp3',
        'audio/mp4'
    ],
    video: [
        'video/webm',
        'video/ogg',
        'application/ogg',
        'video/mp4'
    ]
};

/** A function that works with documents.  Intended for inheritance by ViewModels */
var mobileAppRoles = [
    { role: "android", name: "Android" },
    { role: "blackberry", name: "Blackberry" },
    { role: "iTunes", name: "ITunes" },
    { role: "windowsPhone", name: "Windows Phone" }
];
var socialMediaRoles = [
    { role: "facebook", name: "Facebook" },
    { role: "flickr", name: "Flickr" },
    { role: "googlePlus", name: "Google+" },
    { role: "instagram", name: "Instagram" },
    { role: "linkedIn", name: "LinkedIn" },
    { role: "pinterest", name: "Pinterest" },
    { role: "rssFeed", name: "Rss Feed" },
    { role: "tumblr", name: "Tumblr" },
    { role: "twitter", name: "Twitter" },
    { role: "vimeo", name: "Vimeo" },
    { role: "youtube", name: "You Tube" }
];
function Documents() {
    var self = this;
    self.documents = ko.observableArray();
    self.documentFilter = ko.observable('');
    self.documentFilterFieldOptions = [{ label: 'Name', fun: 'name'}, { label: 'Attribution', fun: 'attribution' }, { label: 'Type', fun: 'type' }];
    self.documentFilterField = ko.observable(self.documentFilterFieldOptions[0]);

    self.selectedDocument = ko.observable();

    function listContains(list, value) {
        return list.indexOf(value) > -1;
    }

    self.previewTemplate = ko.pureComputed(function() {
        var selectedDoc = self.selectedDocument();

        var val;
        if (selectedDoc) {
            var contentType = (selectedDoc.contentType() || 'application/octet-stream').toLowerCase().trim();
            var embeddedVideo = selectedDoc.embeddedVideo();
            if (embeddedVideo) {
                val = "xssViewer";
            } else if (listContains(contentTypes.convert.concat(contentTypes.audio, contentTypes.video, contentTypes.image, contentTypes.pdf), contentType)) {
                val = "iframeViewer";
            } else {
                val = "noPreviewViewer";
            }
        } else {
            val = "noViewer";
        }
        return val;
    });

    self.selectedDocumentFrameUrl = ko.computed(function() {
        var selectedDoc = self.selectedDocument();

        var val;
        if (selectedDoc) {
            var contentType = (selectedDoc.contentType() || 'application/octet-stream').toLowerCase().trim();
            //return (selectedDoc && selectedDoc.url) ? "https://docs.google.com/viewer?url="+encodeURIComponent(selectedDoc.url)+"&embedded=true" : '';

            if (listContains(contentTypes.pdf, contentType)) {
                val = fcConfig.pdfViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else if (listContains(contentTypes.convert, contentType)) {

              // jq promises are fundamentally broken, so...
              val = $.Deferred(function(dfd) {
                $.get(fcConfig.pdfgenUrl, {"file": selectedDoc.url }, $.noop, "json")
                  .promise()
                  .done(function(data) {
                    dfd.resolve(fcConfig.pdfViewer + '?file=' + encodeURIComponent(data.location));
                  })
                  .fail(function(jqXHR, textStatus, errorThrown) {
                    console.warn('get pdf failed', jqXHR, textStatus, errorThrown);
                    dfd.resolve(fcConfig.errorViewer || '');
                  })
              }).promise();
            } else if (listContains(contentTypes.image, contentType)) {
                val = fcConfig.imgViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else if (listContains(contentTypes.video, contentType)) {
                val = fcConfig.videoViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else if (listContains(contentTypes.audio, contentType)) {
                val = fcConfig.audioViewer + '?file=' + encodeURIComponent(selectedDoc.url);
            } else {
                //val = fcConfig.noViewer + '?file='+encodeURIComponent(selectedDoc.url);
                val = '';
            }
        } else {
            val = '';
        }
        return val;
    }).extend({async: ''});

    self.filteredDocuments = ko.pureComputed(function() {
        var lcFilter = self.documentFilter().trim().toLowerCase();
        var field = self.documentFilterField();
        return ko.utils.arrayFilter(self.documents(), function(doc) {
            return (doc[field.fun]() || '').toLowerCase().indexOf(lcFilter) !== -1;
        });
    });

    self.showListItem = function(element, index, data) {
        var $elem = $(element);
        $elem.hide(); // element is visible after render, so hide it to animate it appearing.
        $elem.show(100);
    };

    self.hideListItem = function(element, index, data) {
        $(element).hide(100);
    };

    self.findDocumentByRole = function(documents, roleToFind) {
        for (var i=0; i<documents.length; i++) {
            var role = ko.utils.unwrapObservable(documents[i].role);
            var status = ko.utils.unwrapObservable(documents[i].status);
            if (role === roleToFind && status !== 'deleted') {
                return documents[i];
            }
        }
        return null;
    };

    self.links = ko.observableArray();
    self.findLinkByRole = function(links, roleToFind) {
        for (var i=0; i<links.length; i++) {
            var role = ko.utils.unwrapObservable(links[i].role);
            if (role === roleToFind) return links[i];
        }
        return null;
    };
    self.addLink = function(role, url) {
        self.links.push(new DocumentViewModel({
            role: role,
            url: url
        }));
    };
    self.fixLinkDocumentIds = function(existingLinks) {
        // match up the documentId for existing link roles
        var existingLength = existingLinks? existingLinks.length: 0;
        if (!existingLength) return;
        $.each(self.links(), function(i, link) {
            var role = ko.utils.unwrapObservable(link.role);
            for (i = 0; i < existingLength; i++)
                if (existingLinks[i].role === role) {
                    link.documentId = existingLinks[i].documentId;
                    return;
                }
        });
    };
    function pushLinkUrl(urls, links, role) {
        var link = self.findLinkByRole(links, role.role);
        if (link) urls.push({
            link: link,
            name: role.name,
            role: role.role,
            remove: function() {
              self.links.remove(link);
            },
            logo: function(dir) {
                return dir + "/" + role.role.toLowerCase() + ".png";
            }
        });
    }

    self.transients = {};

    self.transients.mobileApps = ko.pureComputed(function() {
        var urls = [], links = self.links();
        for (var i = 0; i < mobileAppRoles.length; i++)
            pushLinkUrl(urls, links, mobileAppRoles[i]);
        return urls;
    });
    self.transients.mobileAppsUnspecified = ko.pureComputed(function() {
        var apps = [], links = self.links();
        for (var i = 0; i < mobileAppRoles.length; i++)
        if (!self.findLinkByRole(links, mobileAppRoles[i].role))
            apps.push(mobileAppRoles[i]);
        return apps;
    });
    self.transients.mobileAppToAdd = ko.observable();
    self.transients.mobileAppToAdd.subscribe(function(role) {
        if (role) self.addLink(role, "");
    });
    self.transients.socialMedia = ko.pureComputed(function() {
        var urls = [], links = self.links();
        for (var i = 0; i < socialMediaRoles.length; i++)
            pushLinkUrl(urls, links, socialMediaRoles[i]);
        return urls;
    });
    self.transients.socialMediaUnspecified = ko.pureComputed(function() {
        var apps = [], links = self.links();
        for (var i = 0; i < socialMediaRoles.length; i++)
            if (!self.findLinkByRole(links, socialMediaRoles[i].role))
                apps.push(socialMediaRoles[i]);
        return apps;
    });
    self.transients.socialMediaToAdd = ko.observable();
    self.transients.socialMediaToAdd.subscribe(function(role) {
        if (role) self.addLink(role, "");
    });

    self.logoUrl = ko.pureComputed(function() {
        var logoDocument = self.findDocumentByRole(self.documents(), 'logo');
        return logoDocument ? logoDocument.url : null;
    });
    self.bannerUrl = ko.pureComputed(function() {
        var bannerDocument = self.findDocumentByRole(self.documents(), 'banner');
        return bannerDocument ? bannerDocument.url : null;
    });

    self.asBackgroundImage = function(url) {
        return url ? 'url('+url+')' : null;
    };

    self.mainImageUrl = ko.pureComputed(function() {
        var mainImageDocument = self.findDocumentByRole(self.documents(), 'mainImage');
        return mainImageDocument ? mainImageDocument.url : null;
    });

    self.removeBannerImage = function() {
        self.deleteDocumentByRole('banner');
    };

    self.removeLogoImage = function() {
        self.deleteDocumentByRole('logo');
    };

    self.removeMainImage = function() {
        self.deleteDocumentByRole('mainImage');
    };

    // this supports display of the project's primary images
    self.primaryImages = ko.computed(function () {
        var pi = $.grep(self.documents(), function (doc) {
            return ko.utils.unwrapObservable(doc.isPrimaryProjectImage);
        });
        return pi.length > 0 ? pi : null;
    });


    self.embeddedVideos = ko.computed(function () {
        var ev = $.grep(self.documents(), function (doc) {
            var isPublic = ko.utils.unwrapObservable(doc.public);
            var embeddedVideo = ko.utils.unwrapObservable(doc.embeddedVideo);
            if(isPublic && embeddedVideo) {
                var iframe = buildiFrame(embeddedVideo);
                if(iframe){
                    doc.iframe = iframe;
                    return doc;
                }
            }
        });
        return ev.length > 0 ? ev : null;
    });

    self.deleteDocumentByRole = function(role) {
        var doc = self.findDocumentByRole(self.documents(), role);
        if (doc) {
            if (doc.documentId) {
                doc.status = 'deleted';
                self.documents.valueHasMutated(); // observableArrays don't fire events when contained objects are mutated.
            }
            else {
                self.documents.remove(doc);
            }
        }
    };

    self.ignore = ['documents', 'links', 'logoUrl', 'bannerUrl', 'mainImageUrl', 'primaryImages', 'embeddedVideos',
      'ignore', 'transients', 'documentFilter', 'documentFilterFieldOptions', 'documentFilterField', 'previewTemplate',
      'selectedDocumentFrameUrl', 'filteredDocuments'];

}

/**
 * Wraps a list in a fuse search and exposes results and selection as knockout variables.
 * Make sure to require Fuse on any page using this.
 */
SearchableList = function(list, keys, options) {

    var self = this;
    var options = $.extend({keys:keys, maxPatternLength:64}, options || {});

    var searchable = new Fuse(list, options);

    self.term = ko.observable();
    self.selection = ko.observable();

    self.results = ko.computed(function() {
        if (self.term()) {
            var searchTerm = self.term();
            if (searchTerm > options.maxPatternLength) {
                searchTerm = searchTerm.substring(0, options.maxPatternLength);
            }
            return searchable.search(searchTerm);
        }
        return list;
    });

    self.select = function(value) {
        self.selection(value);
    };
    self.clearSelection = function() {
        self.selection(null);
        self.term(null);
    };
    self.isSelected = function(value) {
        if (!self.selection() || !value) {
            return false;
        }
        for (var i=0; i<keys.length; i++) {
            var selection = self.selection();
            if (selection[keys[i]] != value[keys[i]]) {
                return false;
            }
        }
        return true;
    }
};

function isUrlAndHostValid(url) {
    var allowedHost = ['fast.wistia.com','embed-ssl.ted.com', 'www.youtube.com', 'player.vimeo.com'];
    return (url && isUrlValid(url) && $.inArray(getHostName(url), allowedHost) > -1)
};

function isUrlValid(url) {
    return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
};

function getHostName(href) {
    var l = document.createElement("a");
    l.href = href;
    return l.hostname;
};

function buildiFrame(embeddedVideo){
    var html = $.parseHTML(embeddedVideo);
    var iframe = "";
    if(html){
        for(var i = 0; i < html.length; i++){
            var element = html[i];
            var attr = $(element).attr('src');
            if(typeof attr !== typeof undefined && attr !== false){
                var height =  element.getAttribute("height") ?  element.getAttribute("height") : "315";
                iframe = isUrlAndHostValid(attr)  ? '<iframe width="100%" src ="' +  attr + '" height = "' + height + '"/></iframe>' : "";
            }
            return iframe;
        }
    }
    return iframe;
};

function showFloatingMessage(message, alertType) {
    if (!alertType) {
        alertType = 'alert-success';
    }

    var messageContainer = $('<div id="alertdiv" style="display:none; margin:0;" class="alert ' +  alertType + '"><a class="close" data-dismiss="alert">×</a><span>'+message+'</span></div>');

    setTimeout(function() { // this will automatically close the alert and remove this if the users doesnt close it in 5 secs
        messageContainer.slideUp(400, function() {messageContainer.remove();});
    }, 5000);

    if ($('.navbar').is(':appeared')) {
        // attach below navbar
        $('#content').prepend(messageContainer);

    }
    else {
        // attach to top
        messageContainer.css("position", "fixed");
        messageContainer.width('100%');
        messageContainer.css("top", 0);
        messageContainer.css("left", 0);

        $('body').append(messageContainer);

    }
    messageContainer.slideDown(400);
};

/**
 * Format a date given an Unix time number (output of Date.parse)
 *
 * @param t
 * @returns {string}
 */
function formatDate(t) {
    var d = new Date(t);
    var yyyy = d.getFullYear().toString();
    var mm = (d.getMonth()+1).toString(); // getMonth() is zero-based
    var dd  = d.getDate().toString();
    return yyyy + "-" + (mm[1]?mm:"0"+mm[0]) + "-" + (dd[1]?dd:"0"+dd[0]);
};



var BlogViewModel = function(entries, type) {
    var self = this;
    self.entries = ko.observableArray();

    for (var i=0; i<entries.length; i++) {
        if (!type || entries[i].type == type) {
            self.entries.push(new BlogEntryViewModel(entries[i]));
        }
    }
};

var BlogEntryViewModel = function(blogEntry) {
    var self = this;
    var now = convertToSimpleDate(new Date());
    self.blogEntryId = ko.observable(blogEntry.blogEntryId);
    self.projectId = ko.observable(blogEntry.projectId);
    self.title = ko.observable(blogEntry.title || '');
    self.date = ko.observable(blogEntry.date || now).extend({simpleDate:false});
    self.content = ko.observable(blogEntry.content).extend({markdown:true});
    self.stockIcon = ko.observable(blogEntry.stockIcon);
    self.documents = ko.observableArray(blogEntry.documents || []);
    self.viewMoreUrl = ko.observable(blogEntry.viewMoreUrl);
    self.image = ko.computed(function() {
        return self.documents()[0];
    });
    self.type = ko.observable();
    self.formattedDate = ko.computed(function() {
        return moment(self.date()).format('Do MMM')
    });
    self.shortContent = ko.computed(function() {
        var content = self.content() || '';
        if (content.length > 60) {
            content = content.substring(0, 100)+'...';
        }
        return content;
    });
    self.imageUrl = ko.computed(function() {
        if (self.image()) {
            return self.image().url;
        }
    });
};

var EditableBlogEntryViewModel = function(blogEntry, options) {

    var defaults = {
        validationElementSelector:'.validationEngineContainer',
        types:['News and Events', 'Project Stories'],
        returnTo:fcConfig.returnTo,
        blogUpdateUrl:fcConfig.blogUpdateUrl
    };
    var config = $.extend(defaults, options);
    var self = this;
    var now = convertToSimpleDate(new Date());
    self.blogEntryId = ko.observable(blogEntry.blogEntryId);
    self.projectId = ko.observable(blogEntry.projectId || undefined);
    self.title = ko.observable(blogEntry.title || '');
    self.date = ko.observable(blogEntry.date || now).extend({simpleDate:false});
    self.content = ko.observable(blogEntry.content);
    self.stockIcon = ko.observable(blogEntry.stockImageName);
    self.documents = ko.observableArray();
    self.image = ko.observable();
    self.type = ko.observable();
    self.viewMoreUrl = ko.observable(blogEntry.viewMoreUrl).extend({url:true});

    self.imageUrl = ko.computed(function() {
        if (self.image()) {
            return self.image().url;
        }
    });
    self.imageId = ko.computed(function() {
        if (self.image()) {
           return self.image().documentId;
        }
    });
    self.documents.subscribe(function() {
        if (self.documents()[0]) {
           self.image(new DocumentViewModel(self.documents()[0]));
        }
        else {
            self.image(undefined);
        }
    });
    self.removeBlogImage = function() {
        self.documents([]);
    };

    self.modelAsJSON = function() {
        var js = ko.mapping.toJS(self, {ignore:['transients', 'documents', 'image', 'imageUrl']});
        if (self.image()) {
            js.image = self.image().modelForSaving();
        }
        return JSON.stringify(js);
    };

    self.editContent = function() {
        editWithMarkdown('Blog content', self.content);
    };

    self.save = function() {
        if ($(config.validationElementSelector).validationEngine('validate')) {
            self.saveWithErrorDetection(function() {document.location.href = config.returnTo});
        }
    };

    self.cancel = function() {
        document.location.href = config.returnTo;
    };

    self.transients = {};
    self.transients.blogEntryTypes = config.types;

    if (blogEntry.documents && blogEntry.documents[0]) {
        self.documents.push(blogEntry.documents[0]);
    }
    $(config.validationElementSelector).validationEngine();
    autoSaveModel(self, config.blogUpdateUrl, {blockUIOnSave:true});
};

var BlogSummary = function(blogEntries) {
    var self = this;
    self.entries = ko.observableArray();

    self.load = function(entries) {
        self.entries($.map(entries, function(blogEntry) {
            return new BlogEntryViewModel(blogEntry);
        }));
    };

    self.newBlogEntry = function() {
        document.location.href = fcConfig.createBlogEntryUrl;
    };
    self.deleteBlogEntry = function(entry) {
        var url = fcConfig.deleteBlogEntryUrl+'&id='+entry.blogEntryId();
        $.post(url).done(function() {
            document.location.reload();
        });
    };
    self.editBlogEntry = function(entry) {
        document.location.href = fcConfig.editBlogEntryUrl+'&id='+entry.blogEntryId();
    };
    self.load(blogEntries);
};


/**
 * Animates the replacement of an element with a new element obtained via an ajax (GET) call.
 * @param contentSelector identifies the element to replace.
 * @param url the URL to call to get the replacement content.
 * @returns a promise that will complete when the content is replaced.
 */
function replaceContentSection(contentSelector, url) {

    var $existingContent = $(contentSelector);
    var $parent = $existingContent.parent();

    var newStats;

    var animation = $.Deferred();
    $existingContent.slideUp(400, function() {
        $existingContent.remove();
        animation.resolve();
    });

    var ajax = $.get(url).done(function(data) {
        newStats = $(data);
    });

    return $.when(animation, ajax).done(function() {
        newStats.hide().appendTo($parent).slideDown();
    });
}

$(function() {
    $('#logout-btn').click(function() {
        if (window.localStorage) {
            window.localStorage.setItem('logout', new Date().getTime());
        }
    });
    $('#logout-warning a').click(function(){ $('#logout-warning').hide(); });
    window.addEventListener('storage', function(e) {
        if (e.key == 'logout') {
            $('#logout-warning').show();
        }
    });
});
/*
 * Copyright (c) 2013 Viral Patel
 * http://viralpatel.net
 *
 * Dual licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 */

 (function($) {
	$.fn.shorten = function (settings) {
	
		var config = {
			showChars: 100,
			ellipsesText: "...",
			moreText: "more",
			lessText: "less"
		};

		if (settings) {
			$.extend(config, settings);
		}
		
		$(document).off("click", '.morelink');
		
		$(document).on({click: function () {

				var $this = $(this);
				if ($this.hasClass('less')) {
					$this.removeClass('less');
					$this.html(config.moreText);
					$this.parent().prev().prev().show(); // shortcontent
					$this.parent().prev().hide(); // allcontent
  	
				} else {
					$this.addClass('less');
					$this.html(config.lessText);
					$this.parent().prev().prev().hide(); // shortcontent
					$this.parent().prev().show(); // allcontent
				}
				return false;
			}
		}, '.morelink');

    return this.each(function () {
        var $this = $(this);

        var content = $this.html();
        if (content.length > config.showChars) {
            var c = content.substr(0, config.showChars);
            if (c.indexOf('<') >= 0) // If there's HTML don't want to cut it
            {
                var inTag = false; // I'm in a tag?
                var bag = ''; // Put the characters to be shown here
                var countChars = 0; // Current bag size
                var openTags = []; // Stack for opened tags, so I can close them later

                for (i = 0; i < content.length; i++) {
                    if (content[i] == '<' && !inTag) {
                        inTag = true;

                        // This could be "tag" or "/tag"
                        tagName = content.substring(i + 1, content.indexOf('>', i));

                        // If its a closing tag
                        if (tagName[0] == '/') {
                            if (tagName != '/' + openTags[0]) console.log('ERROR en HTML: the top of the stack should be the tag that closes');
                            else
                                openTags.shift(); // Pops the last tag from the open tag stack (the tag is closed in the retult HTML!)
                        } else {
                            // There are some nasty tags that don't have a close tag like <br/>
                            if (tagName.toLowerCase() != 'br')
                                openTags.unshift(tagName); // Add to start the name of the tag that opens
                        }
                    }
                    if (inTag && content[i] == '>') {
                        inTag = false;
                    }

                    if (inTag) bag += content[i]; // Add tag name chars to the result
                    else {
                        if (countChars < config.showChars) {
                            bag += content[i];
                            countChars++;
                        } else // Now I have the characters needed
                        {
                            if (openTags.length > 0) // I have unclosed tags
                            {
                                //console.log('They were open tags');
                                //console.log(openTags);
                                for (j = 0; j < openTags.length; j++) {
                                    //console.log('Cierro tag ' + openTags[j]);
                                    bag += '</' + openTags[j] + '>'; // Close all tags that were opened

                                    // You could shift the tag from the stack to check if you end with an empty stack, that means you have closed all open tags
                                }
                                break;
                            }
                        }
                    }
                }
                c = bag;
            }

            var html = '<span class="shortcontent">' + c + '&nbsp;' + config.ellipsesText +
                '</span><span class="allcontent">' + content +
                '</span>&nbsp;&nbsp;<span><a href="javascript://nop/" class="morelink">' + config.moreText + '</a></span>';

            $this.html(html);
            $(".allcontent").hide(); // Esconde el contenido completo para todos los textos
        }
    });
		
	};

 })(jQuery);

/**
 * bootbox.js v3.2.0
 *
 * http://bootboxjs.com/license.txt
 */
var bootbox=window.bootbox||function(w,n){function k(b,a){"undefined"===typeof a&&(a=p);return"string"===typeof j[a][b]?j[a][b]:a!=t?k(b,t):b}var p="en",t="en",u=!0,s="static",v="",l={},g={},m={setLocale:function(b){for(var a in j)if(a==b){p=b;return}throw Error("Invalid locale: "+b);},addLocale:function(b,a){"undefined"===typeof j[b]&&(j[b]={});for(var c in a)j[b][c]=a[c]},setIcons:function(b){g=b;if("object"!==typeof g||null===g)g={}},setBtnClasses:function(b){l=b;if("object"!==typeof l||null===
l)l={}},alert:function(){var b="",a=k("OK"),c=null;switch(arguments.length){case 1:b=arguments[0];break;case 2:b=arguments[0];"function"==typeof arguments[1]?c=arguments[1]:a=arguments[1];break;case 3:b=arguments[0];a=arguments[1];c=arguments[2];break;default:throw Error("Incorrect number of arguments: expected 1-3");}return m.dialog(b,{label:a,icon:g.OK,"class":l.OK,callback:c},{onEscape:c||!0})},confirm:function(){var b="",a=k("CANCEL"),c=k("CONFIRM"),e=null;switch(arguments.length){case 1:b=arguments[0];
break;case 2:b=arguments[0];"function"==typeof arguments[1]?e=arguments[1]:a=arguments[1];break;case 3:b=arguments[0];a=arguments[1];"function"==typeof arguments[2]?e=arguments[2]:c=arguments[2];break;case 4:b=arguments[0];a=arguments[1];c=arguments[2];e=arguments[3];break;default:throw Error("Incorrect number of arguments: expected 1-4");}var h=function(){if("function"===typeof e)return e(!1)};return m.dialog(b,[{label:a,icon:g.CANCEL,"class":l.CANCEL,callback:h},{label:c,icon:g.CONFIRM,"class":l.CONFIRM,
callback:function(){if("function"===typeof e)return e(!0)}}],{onEscape:h})},prompt:function(){var b="",a=k("CANCEL"),c=k("CONFIRM"),e=null,h="";switch(arguments.length){case 1:b=arguments[0];break;case 2:b=arguments[0];"function"==typeof arguments[1]?e=arguments[1]:a=arguments[1];break;case 3:b=arguments[0];a=arguments[1];"function"==typeof arguments[2]?e=arguments[2]:c=arguments[2];break;case 4:b=arguments[0];a=arguments[1];c=arguments[2];e=arguments[3];break;case 5:b=arguments[0];a=arguments[1];
c=arguments[2];e=arguments[3];h=arguments[4];break;default:throw Error("Incorrect number of arguments: expected 1-5");}var q=n("<form></form>");q.append("<input autocomplete=off type=text value='"+h+"' />");var h=function(){if("function"===typeof e)return e(null)},d=m.dialog(q,[{label:a,icon:g.CANCEL,"class":l.CANCEL,callback:h},{label:c,icon:g.CONFIRM,"class":l.CONFIRM,callback:function(){if("function"===typeof e)return e(q.find("input[type=text]").val())}}],{header:b,show:!1,onEscape:h});d.on("shown",
function(){q.find("input[type=text]").focus();q.on("submit",function(a){a.preventDefault();d.find(".btn-primary").click()})});d.modal("show");return d},dialog:function(b,a,c){function e(){var a=null;"function"===typeof c.onEscape&&(a=c.onEscape());!1!==a&&f.modal("hide")}var h="",l=[];c||(c={});"undefined"===typeof a?a=[]:"undefined"==typeof a.length&&(a=[a]);for(var d=a.length;d--;){var g=null,k=null,j=null,m="",p=null;if("undefined"==typeof a[d].label&&"undefined"==typeof a[d]["class"]&&"undefined"==
typeof a[d].callback){var g=0,k=null,r;for(r in a[d])if(k=r,1<++g)break;1==g&&"function"==typeof a[d][r]&&(a[d].label=k,a[d].callback=a[d][r])}"function"==typeof a[d].callback&&(p=a[d].callback);a[d]["class"]?j=a[d]["class"]:d==a.length-1&&2>=a.length&&(j="btn-primary");g=a[d].label?a[d].label:"Option "+(d+1);a[d].icon&&(m="<i class='"+a[d].icon+"'></i> ");k=a[d].href?a[d].href:"javascript:;";h="<a data-handler='"+d+"' class='btn "+j+"' href='"+k+"'>"+m+""+g+"</a>"+h;l[d]=p}d=["<div class='bootbox modal' tabindex='-1' style='overflow:hidden;'>"];
if(c.header){j="";if("undefined"==typeof c.headerCloseButton||c.headerCloseButton)j="<a href='javascript:;' class='close'>&times;</a>";d.push("<div class='modal-header'>"+j+"<h3>"+c.header+"</h3></div>")}d.push("<div class='modal-body'></div>");h&&d.push("<div class='modal-footer'>"+h+"</div>");d.push("</div>");var f=n(d.join("\n"));("undefined"===typeof c.animate?u:c.animate)&&f.addClass("fade");(h="undefined"===typeof c.classes?v:c.classes)&&f.addClass(h);f.find(".modal-body").html(b);f.on("keyup.dismiss.modal",
function(a){27===a.which&&c.onEscape&&e("escape")});f.on("click","a.close",function(a){a.preventDefault();e("close")});f.on("shown",function(){f.find("a.btn-primary:first").focus()});f.on("hidden",function(){f.remove()});f.on("click",".modal-footer a",function(b){var c=n(this).data("handler"),d=l[c],e=null;"undefined"!==typeof c&&"undefined"!==typeof a[c].href||(b.preventDefault(),"function"===typeof d&&(e=d()),!1!==e&&f.modal("hide"))});n("body").append(f);f.modal({backdrop:"undefined"===typeof c.backdrop?
s:c.backdrop,keyboard:!1,show:!1});f.on("show",function(){n(w).off("focusin.modal")});("undefined"===typeof c.show||!0===c.show)&&f.modal("show");return f},modal:function(){var b,a,c,e={onEscape:null,keyboard:!0,backdrop:s};switch(arguments.length){case 1:b=arguments[0];break;case 2:b=arguments[0];"object"==typeof arguments[1]?c=arguments[1]:a=arguments[1];break;case 3:b=arguments[0];a=arguments[1];c=arguments[2];break;default:throw Error("Incorrect number of arguments: expected 1-3");}e.header=a;
c="object"==typeof c?n.extend(e,c):e;return m.dialog(b,[],c)},hideAll:function(){n(".bootbox").modal("hide")},animate:function(b){u=b},backdrop:function(b){s=b},classes:function(b){v=b}},j={en:{OK:"OK",CANCEL:"Cancel",CONFIRM:"OK"},fr:{OK:"OK",CANCEL:"Annuler",CONFIRM:"D'accord"},de:{OK:"OK",CANCEL:"Abbrechen",CONFIRM:"Akzeptieren"},es:{OK:"OK",CANCEL:"Cancelar",CONFIRM:"Aceptar"},br:{OK:"OK",CANCEL:"Cancelar",CONFIRM:"Sim"},nl:{OK:"OK",CANCEL:"Annuleren",CONFIRM:"Accepteren"},ru:{OK:"OK",CANCEL:"\u041e\u0442\u043c\u0435\u043d\u0430",
CONFIRM:"\u041f\u0440\u0438\u043c\u0435\u043d\u0438\u0442\u044c"},it:{OK:"OK",CANCEL:"Annulla",CONFIRM:"Conferma"}};return m}(document,window.jQuery);window.bootbox=bootbox;

// version 1.6.0
// http://welcome.totheinter.net/columnizer-jquery-plugin/
// created by: Adam Wulf @adamwulf, adam.wulf@gmail.com

(function($){

 $.fn.columnize = function(options) {


	var defaults = {
		// default width of columns
		width: 400,
		// optional # of columns instead of width
		columns : false,
		// true to build columns once regardless of window resize
		// false to rebuild when content box changes bounds
		buildOnce : false,
		// an object with options if the text should overflow
		// it's container if it can't fit within a specified height
		overflow : false,
		// this function is called after content is columnized
		doneFunc : function(){},
		// if the content should be columnized into a 
		// container node other than it's own node
		target : false,
		// re-columnizing when images reload might make things
		// run slow. so flip this to true if it's causing delays
		ignoreImageLoading : true,
		// should columns float left or right
		columnFloat : "left",
		// ensure the last column is never the tallest column
		lastNeverTallest : false,
		// (int) the minimum number of characters to jump when splitting
		// text nodes. smaller numbers will result in higher accuracy
		// column widths, but will take slightly longer
		accuracy : false,
		// don't automatically layout columns, only use manual columnbreak
		manualBreaks : false,
		// previx for all the CSS classes used by this plugin
		// default to empty string for backwards compatibility
		cssClassPrefix : ""
	};
	options = $.extend(defaults, options);

	if(typeof(options.width) == "string"){
		options.width = parseInt(options.width,10);
		if(isNaN(options.width)){
			options.width = defaults.width;
		}
	}

    return this.each(function() {
		var $inBox = options.target ? $(options.target) : $(this);
		var maxHeight = $(this).height();
		var $cache = $('<div></div>'); // this is where we'll put the real content
		var lastWidth = 0;
		var columnizing = false;
		var manualBreaks = options.manualBreaks;
		var cssClassPrefix = defaults.cssClassPrefix;
		if(typeof(options.cssClassPrefix) == "string"){
			cssClassPrefix = options.cssClassPrefix;
		}


		var adjustment = 0;

		$cache.append($(this).contents().clone(true));

		// images loading after dom load
		// can screw up the column heights,
		// so recolumnize after images load
		if(!options.ignoreImageLoading && !options.target){
			if(!$inBox.data("imageLoaded")){
				$inBox.data("imageLoaded", true);
				if($(this).find("img").length > 0){
					// only bother if there are
					// actually images...
					var func = function($inBox,$cache){ return function(){
							if(!$inBox.data("firstImageLoaded")){
								$inBox.data("firstImageLoaded", "true");
								$inBox.empty().append($cache.children().clone(true));
								$inBox.columnize(options);
							}
						};
					}($(this), $cache);
					$(this).find("img").one("load", func);
					$(this).find("img").one("abort", func);
					return;
				}
			}
		}

		$inBox.empty();

		columnizeIt();

		if(!options.buildOnce){
			$(window).resize(function() {
				if(!options.buildOnce){
					if($inBox.data("timeout")){
						clearTimeout($inBox.data("timeout"));
					}
					$inBox.data("timeout", setTimeout(columnizeIt, 200));
				}
			});
		}

		function prefixTheClassName(className, withDot){
			var dot = withDot ? "." : "";
			if(cssClassPrefix.length){
				return dot + cssClassPrefix + "-" + className;
			}
			return dot + className;
		}

		/**
		 * this fuction builds as much of a column as it can without
		 * splitting nodes in half. If the last node in the new column
		 * is a text node, then it will try to split that text node. otherwise
		 * it will leave the node in $pullOutHere and return with a height
		 * smaller than targetHeight.
		 * 
         * Returns a boolean on whether we did some splitting successfully at a text point
         * (so we know we don't need to split a real element). return false if the caller should
         * split a node if possible to end this column.
		 *
		 * @param putInHere, the jquery node to put elements into for the current column
		 * @param $pullOutHere, the jquery node to pull elements out of (uncolumnized html)
		 * @param $parentColumn, the jquery node for the currently column that's being added to
		 * @param targetHeight, the ideal height for the column, get as close as we can to this height
		 */
		function columnize($putInHere, $pullOutHere, $parentColumn, targetHeight){
			//
			// add as many nodes to the column as we can,
			// but stop once our height is too tall
			while((manualBreaks || $parentColumn.height() < targetHeight) &&
				$pullOutHere[0].childNodes.length){
				var node = $pullOutHere[0].childNodes[0];
				//
				// Because we're not cloning, jquery will actually move the element"
				// http://welcome.totheinter.net/2009/03/19/the-undocumented-life-of-jquerys-append/
				if($(node).find(prefixTheClassName("columnbreak", true)).length){
					//
					// our column is on a column break, so just end here
					return;
				}
				if($(node).hasClass(prefixTheClassName("columnbreak"))){
					//
					// our column is on a column break, so just end here
					return;
				}
				$putInHere.append(node);
			}
			if($putInHere[0].childNodes.length === 0) return;

			// now we're too tall, so undo the last one
			var kids = $putInHere[0].childNodes;
			var lastKid = kids[kids.length-1];
			$putInHere[0].removeChild(lastKid);
			var $item = $(lastKid);

			// now lets try to split that last node
			// to fit as much of it as we can into this column
			if($item[0].nodeType == 3){
				// it's a text node, split it up
				var oText = $item[0].nodeValue;
				var counter2 = options.width / 18;
				if(options.accuracy)
				counter2 = options.accuracy;
				var columnText;
				var latestTextNode = null;
				while($parentColumn.height() < targetHeight && oText.length){
					var indexOfSpace = oText.indexOf(' ', counter2);
					if (indexOfSpace != -1) {
						columnText = oText.substring(0, oText.indexOf(' ', counter2));
					} else {
						columnText = oText;
					}
					latestTextNode = document.createTextNode(columnText);
					$putInHere.append(latestTextNode);

					if(oText.length > counter2 && indexOfSpace != -1){
						oText = oText.substring(indexOfSpace);
					}else{
						oText = "";
					}
				}
				if($parentColumn.height() >= targetHeight && latestTextNode !== null){
					// too tall :(
					$putInHere[0].removeChild(latestTextNode);
					oText = latestTextNode.nodeValue + oText;
				}
				if(oText.length){
					$item[0].nodeValue = oText;
				}else{
					return false; // we ate the whole text node, move on to the next node
				}
			}

			if($pullOutHere.contents().length){
				$pullOutHere.prepend($item);
			}else{
				$pullOutHere.append($item);
			}

			return $item[0].nodeType == 3;
		}

		/**
		 * Split up an element, which is more complex than splitting text. We need to create 
		 * two copies of the element with it's contents divided between each
		 */
		function split($putInHere, $pullOutHere, $parentColumn, targetHeight){
			if($putInHere.contents(":last").find(prefixTheClassName("columnbreak", true)).length){
				//
				// our column is on a column break, so just end here
				return;
			}
			if($putInHere.contents(":last").hasClass(prefixTheClassName("columnbreak"))){
				//
				// our column is on a column break, so just end here
				return;
			}
			if($pullOutHere.contents().length){
				var $cloneMe = $pullOutHere.contents(":first");
				//
				// make sure we're splitting an element
				if($cloneMe.get(0).nodeType != 1) return;

				//
				// clone the node with all data and events
				var $clone = $cloneMe.clone(true);
				//
				// need to support both .prop and .attr if .prop doesn't exist.
				// this is for backwards compatibility with older versions of jquery.
				if($cloneMe.hasClass(prefixTheClassName("columnbreak"))){
					//
					// ok, we have a columnbreak, so add it into
					// the column and exit
					$putInHere.append($clone);
					$cloneMe.remove();
				}else if (manualBreaks){
					// keep adding until we hit a manual break
					$putInHere.append($clone);
					$cloneMe.remove();
				}else if($clone.get(0).nodeType == 1 && !$clone.hasClass(prefixTheClassName("dontend"))){
					$putInHere.append($clone);
					if($clone.is("img") && $parentColumn.height() < targetHeight + 20){
						//
						// we can't split an img in half, so just add it
						// to the column and remove it from the pullOutHere section
						$cloneMe.remove();
					}else if(!$cloneMe.hasClass(prefixTheClassName("dontsplit")) && $parentColumn.height() < targetHeight + 20){
						//
						// pretty close fit, and we're not allowed to split it, so just
						// add it to the column, remove from pullOutHere, and be done
						$cloneMe.remove();
					}else if($clone.is("img") || $cloneMe.hasClass(prefixTheClassName("dontsplit"))){
						//
						// it's either an image that's too tall, or an unsplittable node
						// that's too tall. leave it in the pullOutHere and we'll add it to the 
						// next column
						$clone.remove();
					}else{
						//
						// ok, we're allowed to split the node in half, so empty out
						// the node in the column we're building, and start splitting
						// it in half, leaving some of it in pullOutHere
						$clone.empty();
						if(!columnize($clone, $cloneMe, $parentColumn, targetHeight)){
							// this node still has non-text nodes to split
							// add the split class and then recur
							$cloneMe.addClass(prefixTheClassName("split"));
							if($cloneMe.children().length){
								split($clone, $cloneMe, $parentColumn, targetHeight);
							}
						}else{
							// this node only has text node children left, add the
							// split class and move on.
							$cloneMe.addClass(prefixTheClassName("split"));
						}
						if($clone.get(0).childNodes.length === 0){
							// it was split, but nothing is in it :(
							$clone.remove();
						}
					}
				}
			}
		}


		function singleColumnizeIt() {
			if ($inBox.data("columnized") && $inBox.children().length == 1) {
				return;
			}
			$inBox.data("columnized", true);
			$inBox.data("columnizing", true);

			$inBox.empty();
			$inBox.append($("<div class='"
				+ prefixTheClassName("first") + " "
				+ prefixTheClassName("last") + " "
				+ prefixTheClassName("column") + " "
				+ "' style='width:100%; float: " + options.columnFloat + ";'></div>")); //"
			$col = $inBox.children().eq($inBox.children().length-1);
			$destroyable = $cache.clone(true);
			if(options.overflow){
				targetHeight = options.overflow.height;
				columnize($col, $destroyable, $col, targetHeight);
				// make sure that the last item in the column isn't a "dontend"
				if(!$destroyable.contents().find(":first-child").hasClass(prefixTheClassName("dontend"))){
					split($col, $destroyable, $col, targetHeight);
				}

				while($col.contents(":last").length && checkDontEndColumn($col.contents(":last").get(0))){
					var $lastKid = $col.contents(":last");
					$lastKid.remove();
					$destroyable.prepend($lastKid);
				}

				var html = "";
				var div = document.createElement('DIV');
				while($destroyable[0].childNodes.length > 0){
					var kid = $destroyable[0].childNodes[0];
					if(kid.attributes){
						for(var i=0;i<kid.attributes.length;i++){
							if(kid.attributes[i].nodeName.indexOf("jQuery") === 0){
								kid.removeAttribute(kid.attributes[i].nodeName);
							}
						}
					}
					div.innerHTML = "";
					div.appendChild($destroyable[0].childNodes[0]);
					html += div.innerHTML;
				}
				var overflow = $(options.overflow.id)[0];
				overflow.innerHTML = html;

			}else{
				$col.append($destroyable);
			}
			$inBox.data("columnizing", false);

			if(options.overflow && options.overflow.doneFunc){
				options.overflow.doneFunc();
			}

		}

		/**
		 * returns true if the input dom node
		 * should not end a column.
		 * returns false otherwise
		 */
		function checkDontEndColumn(dom){
			if(dom.nodeType == 3){
				// text node. ensure that the text
				// is not 100% whitespace
				if(/^\s+$/.test(dom.nodeValue)){
						//
						// ok, it's 100% whitespace,
						// so we should return checkDontEndColumn
						// of the inputs previousSibling
						if(!dom.previousSibling) return false;
					return checkDontEndColumn(dom.previousSibling);
				}
				return false;
			}
			if(dom.nodeType != 1) return false;
			if($(dom).hasClass(prefixTheClassName("dontend"))) return true;
			if(dom.childNodes.length === 0) return false;
			return checkDontEndColumn(dom.childNodes[dom.childNodes.length-1]);
		}

		function columnizeIt() {
			//reset adjustment var
			adjustment = 0;
			if(lastWidth == $inBox.width()) return;
			lastWidth = $inBox.width();

			var numCols = Math.round($inBox.width() / options.width);
			var optionWidth = options.width;
			var optionHeight = options.height;
			if(options.columns) numCols = options.columns;
			if(manualBreaks){
				numCols = $cache.find(prefixTheClassName("columnbreak", true)).length + 1;
				optionWidth = false;
			}

//			if ($inBox.data("columnized") && numCols == $inBox.children().length) {
//				return;
//			}
			if(numCols <= 1){
				return singleColumnizeIt();
			}
			if($inBox.data("columnizing")) return;
			$inBox.data("columnized", true);
			$inBox.data("columnizing", true);

			$inBox.empty();
			$inBox.append($("<div style='width:" + (Math.floor(100 / numCols))+ "%; float: " + options.columnFloat + ";'></div>")); //"
			$col = $inBox.children(":last");
			$col.append($cache.clone());
			maxHeight = $col.height();
			$inBox.empty();

			var targetHeight = maxHeight / numCols;
			var firstTime = true;
			var maxLoops = 3;
			var scrollHorizontally = false;
			if(options.overflow){
				maxLoops = 1;
				targetHeight = options.overflow.height;
			}else if(optionHeight && optionWidth){
				maxLoops = 1;
				targetHeight = optionHeight;
				scrollHorizontally = true;
			}

			//
			// We loop as we try and workout a good height to use. We know it initially as an average 
			// but if the last column is higher than the first ones (which can happen, depending on split
			// points) we need to raise 'adjustment'. We try this over a few iterations until we're 'solid'.
			//
			// also, lets hard code the max loops to 20. that's /a lot/ of loops for columnizer,
			// and should keep run aways in check. if somehow someone has content combined with
			// options that would cause an infinite loop, then this'll definitely stop it.
			for(var loopCount=0;loopCount<maxLoops && loopCount<20;loopCount++){
				$inBox.empty();
				var $destroyable, className, $col, $lastKid;
				try{
					$destroyable = $cache.clone(true);
				}catch(e){
					// jquery in ie6 can't clone with true
					$destroyable = $cache.clone();
				}
				$destroyable.css("visibility", "hidden");
				// create the columns
				for (var i = 0; i < numCols; i++) {
					/* create column */
					className = (i === 0) ? prefixTheClassName("first") : "";
					className += " " + prefixTheClassName("column");
					className = (i == numCols - 1) ? (prefixTheClassName("last") + " " + className) : className;
					$inBox.append($("<div class='" + className + "' style='width:" + (Math.floor(100 / numCols))+ "%; float: " + options.columnFloat + ";'></div>")); //"
				}

				// fill all but the last column (unless overflowing)
				i = 0;
				while(i < numCols - (options.overflow ? 0 : 1) || scrollHorizontally && $destroyable.contents().length){
					if($inBox.children().length <= i){
						// we ran out of columns, make another
						$inBox.append($("<div class='" + className + "' style='width:" + (Math.floor(100 / numCols))+ "%; float: " + options.columnFloat + ";'></div>")); //"
					}
					$col = $inBox.children().eq(i);
					if(scrollHorizontally){
						$col.width(optionWidth + "px");
					}
					columnize($col, $destroyable, $col, targetHeight);
					// make sure that the last item in the column isn't a "dontend"
					split($col, $destroyable, $col, targetHeight);

					while($col.contents(":last").length && checkDontEndColumn($col.contents(":last").get(0))){
						$lastKid = $col.contents(":last");
						$lastKid.remove();
						$destroyable.prepend($lastKid);
					}
					i++;

					//
					// https://github.com/adamwulf/Columnizer-jQuery-Plugin/issues/47
					//
					// check for infinite loop.
					//
					// this could happen when a dontsplit or dontend item is taller than the column
					// we're trying to build, and its never actually added to a column.
					//
					// this results in empty columns being added with the dontsplit item
					// perpetually waiting to get put into a column. lets force the issue here
					if($col.contents().length === 0 && $destroyable.contents().length){
						//
						// ok, we're building zero content columns. this'll happen forever
						// since nothing can ever get taken out of destroyable.
						//
						// to fix, lets put 1 item from destroyable into the empty column
						// before we iterate
						$col.append($destroyable.contents(":first"));
					}else if(i == numCols - (options.overflow ? 0 : 1) && !options.overflow){
						//
						// ok, we're about to exit the while loop because we're done with all
						// columns except the last column.
						//
						// if $destroyable still has columnbreak nodes in it, then we need to keep
						// looping and creating more columns.
						if($destroyable.find(prefixTheClassName("columnbreak", true)).length){
							numCols ++;
						}
					}
				}
				if(options.overflow && !scrollHorizontally){
					var IE6 = false /*@cc_on || @_jscript_version < 5.7 @*/;
					var IE7 = (document.all) && (navigator.appVersion.indexOf("MSIE 7.") != -1);
					if(IE6 || IE7){
						var html = "";
						var div = document.createElement('DIV');
						while($destroyable[0].childNodes.length > 0){
							var kid = $destroyable[0].childNodes[0];
							for(i=0;i<kid.attributes.length;i++){
								if(kid.attributes[i].nodeName.indexOf("jQuery") === 0){
									kid.removeAttribute(kid.attributes[i].nodeName);
								}
							}
							div.innerHTML = "";
							div.appendChild($destroyable[0].childNodes[0]);
							html += div.innerHTML;
						}
						var overflow = $(options.overflow.id)[0];
						overflow.innerHTML = html;
					}else{
						$(options.overflow.id).empty().append($destroyable.contents().clone(true));
					}
				}else if(!scrollHorizontally){
					// the last column in the series
					$col = $inBox.children().eq($inBox.children().length-1);
					$destroyable.contents().each( function() {
						$col.append( $(this) );
					});
					var afterH = $col.height();
					var diff = afterH - targetHeight;
					var totalH = 0;
					var min = 10000000;
					var max = 0;
					var lastIsMax = false;
					var numberOfColumnsThatDontEndInAColumnBreak = 0;
					$inBox.children().each(function($inBox){ return function($item){
						var $col = $inBox.children().eq($item);
						var endsInBreak = $col.children(":last").find(prefixTheClassName("columnbreak", true)).length;
						if(!endsInBreak){
							var h = $col.height();
							lastIsMax = false;
							totalH += h;
							if(h > max) {
								max = h;
								lastIsMax = true;
							}
							if(h < min) min = h;
							numberOfColumnsThatDontEndInAColumnBreak++;
						}
					};
				}($inBox));

					var avgH = totalH / numberOfColumnsThatDontEndInAColumnBreak;
					if(totalH === 0){
						//
						// all columns end in a column break,
						// so we're done here
						loopCount = maxLoops;
					}else if(options.lastNeverTallest && lastIsMax){
						// the last column is the tallest
						// so allow columns to be taller
						// and retry
						//
						// hopefully this'll mean more content fits into
						// earlier columns, so that the last column
						// can be shorter than the rest
						adjustment += 30;

						targetHeight = targetHeight + 30;
						if(loopCount == maxLoops-1) maxLoops++;
					}else if(max - min > 30){
						// too much variation, try again
						targetHeight = avgH + 30;
					}else if(Math.abs(avgH-targetHeight) > 20){
						// too much variation, try again
						targetHeight = avgH;
					}else {
						// solid, we're done
						loopCount = maxLoops;
					}
				}else{
					// it's scrolling horizontally, fix the width/classes of the columns
					$inBox.children().each(function(i){
						$col = $inBox.children().eq(i);
						$col.width(optionWidth + "px");
						if(i === 0){
							$col.addClass(prefixTheClassName("first"));
						}else if(i==$inBox.children().length-1){
							$col.addClass(prefixTheClassName("last"));
						}else{
							$col.removeClass(prefixTheClassName("first"));
							$col.removeClass(prefixTheClassName("last"));
						}
					});
					$inBox.width($inBox.children().length * optionWidth + "px");
				}
				$inBox.append($("<br style='clear:both;'>"));
			}
			$inBox.find(prefixTheClassName("column", true)).find(":first" + prefixTheClassName("removeiffirst", true)).remove();
			$inBox.find(prefixTheClassName("column", true)).find(':last' + prefixTheClassName("removeiflast", true)).remove();
			$inBox.data("columnizing", false);

			if(options.overflow){
				options.overflow.doneFunc();
			}
			options.doneFunc();
		}
    });
 };
})(jQuery);

/*!
 * jQuery blockUI plugin
 * Version 2.66.0-2013.10.09
 * Requires jQuery v1.7 or later
 *
 * Examples at: http://malsup.com/jquery/block/
 * Copyright (c) 2007-2013 M. Alsup
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * Thanks to Amir-Hossein Sobhi for some excellent contributions!
 */

;(function() {
/*jshint eqeqeq:false curly:false latedef:false */
"use strict";

	function setup($) {
		$.fn._fadeIn = $.fn.fadeIn;

		var noOp = $.noop || function() {};

		// this bit is to ensure we don't call setExpression when we shouldn't (with extra muscle to handle
		// confusing userAgent strings on Vista)
		var msie = /MSIE/.test(navigator.userAgent);
		var ie6  = /MSIE 6.0/.test(navigator.userAgent) && ! /MSIE 8.0/.test(navigator.userAgent);
		var mode = document.documentMode || 0;
		var setExpr = $.isFunction( document.createElement('div').style.setExpression );

		// global $ methods for blocking/unblocking the entire page
		$.blockUI   = function(opts) { install(window, opts); };
		$.unblockUI = function(opts) { remove(window, opts); };

		// convenience method for quick growl-like notifications  (http://www.google.com/search?q=growl)
		$.growlUI = function(title, message, timeout, onClose) {
			var $m = $('<div class="growlUI"></div>');
			if (title) $m.append('<h1>'+title+'</h1>');
			if (message) $m.append('<h2>'+message+'</h2>');
			if (timeout === undefined) timeout = 3000;

			// Added by konapun: Set timeout to 30 seconds if this growl is moused over, like normal toast notifications
			var callBlock = function(opts) {
				opts = opts || {};

				$.blockUI({
					message: $m,
					fadeIn : typeof opts.fadeIn  !== 'undefined' ? opts.fadeIn  : 700,
					fadeOut: typeof opts.fadeOut !== 'undefined' ? opts.fadeOut : 1000,
					timeout: typeof opts.timeout !== 'undefined' ? opts.timeout : timeout,
					centerY: false,
					showOverlay: false,
					onUnblock: onClose,
					css: $.blockUI.defaults.growlCSS
				});
			};

			callBlock();
			var nonmousedOpacity = $m.css('opacity');
			$m.mouseover(function() {
				callBlock({
					fadeIn: 0,
					timeout: 30000
				});

				var displayBlock = $('.blockMsg');
				displayBlock.stop(); // cancel fadeout if it has started
				displayBlock.fadeTo(300, 1); // make it easier to read the message by removing transparency
			}).mouseout(function() {
				$('.blockMsg').fadeOut(1000);
			});
			// End konapun additions
		};

		// plugin method for blocking element content
		$.fn.block = function(opts) {
			if ( this[0] === window ) {
				$.blockUI( opts );
				return this;
			}
			var fullOpts = $.extend({}, $.blockUI.defaults, opts || {});
			this.each(function() {
				var $el = $(this);
				if (fullOpts.ignoreIfBlocked && $el.data('blockUI.isBlocked'))
					return;
				$el.unblock({ fadeOut: 0 });
			});

			return this.each(function() {
				if ($.css(this,'position') == 'static') {
					this.style.position = 'relative';
					$(this).data('blockUI.static', true);
				}
				this.style.zoom = 1; // force 'hasLayout' in ie
				install(this, opts);
			});
		};

		// plugin method for unblocking element content
		$.fn.unblock = function(opts) {
			if ( this[0] === window ) {
				$.unblockUI( opts );
				return this;
			}
			return this.each(function() {
				remove(this, opts);
			});
		};

		$.blockUI.version = 2.66; // 2nd generation blocking at no extra cost!

		// override these in your code to change the default behavior and style
		$.blockUI.defaults = {
			// message displayed when blocking (use null for no message)
			message:  '<h1>Please wait...</h1>',

			title: null,		// title string; only used when theme == true
			draggable: true,	// only used when theme == true (requires jquery-ui.js to be loaded)

			theme: false, // set to true to use with jQuery UI themes

			// styles for the message when blocking; if you wish to disable
			// these and use an external stylesheet then do this in your code:
			// $.blockUI.defaults.css = {};
			css: {
				padding:	0,
				margin:		0,
				width:		'30%',
				top:		'40%',
				left:		'35%',
				textAlign:	'center',
				color:		'#000',
				border:		'3px solid #aaa',
				backgroundColor:'#fff',
				cursor:		'wait'
			},

			// minimal style set used when themes are used
			themedCSS: {
				width:	'30%',
				top:	'40%',
				left:	'35%'
			},

			// styles for the overlay
			overlayCSS:  {
				backgroundColor:	'#000',
				opacity:			0.6,
				cursor:				'wait'
			},

			// style to replace wait cursor before unblocking to correct issue
			// of lingering wait cursor
			cursorReset: 'default',

			// styles applied when using $.growlUI
			growlCSS: {
				width:		'350px',
				top:		'10px',
				left:		'',
				right:		'10px',
				border:		'none',
				padding:	'5px',
				opacity:	0.6,
				cursor:		'default',
				color:		'#fff',
				backgroundColor: '#000',
				'-webkit-border-radius':'10px',
				'-moz-border-radius':	'10px',
				'border-radius':		'10px'
			},

			// IE issues: 'about:blank' fails on HTTPS and javascript:false is s-l-o-w
			// (hat tip to Jorge H. N. de Vasconcelos)
			/*jshint scripturl:true */
			iframeSrc: /^https/i.test(window.location.href || '') ? 'javascript:false' : 'about:blank',

			// force usage of iframe in non-IE browsers (handy for blocking applets)
			forceIframe: false,

			// z-index for the blocking overlay
			baseZ: 1000,

			// set these to true to have the message automatically centered
			centerX: true, // <-- only effects element blocking (page block controlled via css above)
			centerY: true,

			// allow body element to be stetched in ie6; this makes blocking look better
			// on "short" pages.  disable if you wish to prevent changes to the body height
			allowBodyStretch: true,

			// enable if you want key and mouse events to be disabled for content that is blocked
			bindEvents: true,

			// be default blockUI will supress tab navigation from leaving blocking content
			// (if bindEvents is true)
			constrainTabKey: true,

			// fadeIn time in millis; set to 0 to disable fadeIn on block
			fadeIn:  200,

			// fadeOut time in millis; set to 0 to disable fadeOut on unblock
			fadeOut:  400,

			// time in millis to wait before auto-unblocking; set to 0 to disable auto-unblock
			timeout: 0,

			// disable if you don't want to show the overlay
			showOverlay: true,

			// if true, focus will be placed in the first available input field when
			// page blocking
			focusInput: true,

            // elements that can receive focus
            focusableElements: ':input:enabled:visible',

			// suppresses the use of overlay styles on FF/Linux (due to performance issues with opacity)
			// no longer needed in 2012
			// applyPlatformOpacityRules: true,

			// callback method invoked when fadeIn has completed and blocking message is visible
			onBlock: null,

			// callback method invoked when unblocking has completed; the callback is
			// passed the element that has been unblocked (which is the window object for page
			// blocks) and the options that were passed to the unblock call:
			//	onUnblock(element, options)
			onUnblock: null,

			// callback method invoked when the overlay area is clicked.
			// setting this will turn the cursor to a pointer, otherwise cursor defined in overlayCss will be used.
			onOverlayClick: null,

			// don't ask; if you really must know: http://groups.google.com/group/jquery-en/browse_thread/thread/36640a8730503595/2f6a79a77a78e493#2f6a79a77a78e493
			quirksmodeOffsetHack: 4,

			// class name of the message block
			blockMsgClass: 'blockMsg',

			// if it is already blocked, then ignore it (don't unblock and reblock)
			ignoreIfBlocked: false
		};

		// private data and functions follow...

		var pageBlock = null;
		var pageBlockEls = [];

		function install(el, opts) {
			var css, themedCSS;
			var full = (el == window);
			var msg = (opts && opts.message !== undefined ? opts.message : undefined);
			opts = $.extend({}, $.blockUI.defaults, opts || {});

			if (opts.ignoreIfBlocked && $(el).data('blockUI.isBlocked'))
				return;

			opts.overlayCSS = $.extend({}, $.blockUI.defaults.overlayCSS, opts.overlayCSS || {});
			css = $.extend({}, $.blockUI.defaults.css, opts.css || {});
			if (opts.onOverlayClick)
				opts.overlayCSS.cursor = 'pointer';

			themedCSS = $.extend({}, $.blockUI.defaults.themedCSS, opts.themedCSS || {});
			msg = msg === undefined ? opts.message : msg;

			// remove the current block (if there is one)
			if (full && pageBlock)
				remove(window, {fadeOut:0});

			// if an existing element is being used as the blocking content then we capture
			// its current place in the DOM (and current display style) so we can restore
			// it when we unblock
			if (msg && typeof msg != 'string' && (msg.parentNode || msg.jquery)) {
				var node = msg.jquery ? msg[0] : msg;
				var data = {};
				$(el).data('blockUI.history', data);
				data.el = node;
				data.parent = node.parentNode;
				data.display = node.style.display;
				data.position = node.style.position;
				if (data.parent)
					data.parent.removeChild(node);
			}

			$(el).data('blockUI.onUnblock', opts.onUnblock);
			var z = opts.baseZ;

			// blockUI uses 3 layers for blocking, for simplicity they are all used on every platform;
			// layer1 is the iframe layer which is used to supress bleed through of underlying content
			// layer2 is the overlay layer which has opacity and a wait cursor (by default)
			// layer3 is the message content that is displayed while blocking
			var lyr1, lyr2, lyr3, s;
			if (msie || opts.forceIframe)
				lyr1 = $('<iframe class="blockUI" style="z-index:'+ (z++) +';display:none;border:none;margin:0;padding:0;position:absolute;width:100%;height:100%;top:0;left:0" src="'+opts.iframeSrc+'"></iframe>');
			else
				lyr1 = $('<div class="blockUI" style="display:none"></div>');

			if (opts.theme)
				lyr2 = $('<div class="blockUI blockOverlay ui-widget-overlay" style="z-index:'+ (z++) +';display:none"></div>');
			else
				lyr2 = $('<div class="blockUI blockOverlay" style="z-index:'+ (z++) +';display:none;border:none;margin:0;padding:0;width:100%;height:100%;top:0;left:0"></div>');

			if (opts.theme && full) {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockPage ui-dialog ui-widget ui-corner-all" style="z-index:'+(z+10)+';display:none;position:fixed">';
				if ( opts.title ) {
					s += '<div class="ui-widget-header ui-dialog-titlebar ui-corner-all blockTitle">'+(opts.title || '&nbsp;')+'</div>';
				}
				s += '<div class="ui-widget-content ui-dialog-content"></div>';
				s += '</div>';
			}
			else if (opts.theme) {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockElement ui-dialog ui-widget ui-corner-all" style="z-index:'+(z+10)+';display:none;position:absolute">';
				if ( opts.title ) {
					s += '<div class="ui-widget-header ui-dialog-titlebar ui-corner-all blockTitle">'+(opts.title || '&nbsp;')+'</div>';
				}
				s += '<div class="ui-widget-content ui-dialog-content"></div>';
				s += '</div>';
			}
			else if (full) {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockPage" style="z-index:'+(z+10)+';display:none;position:fixed"></div>';
			}
			else {
				s = '<div class="blockUI ' + opts.blockMsgClass + ' blockElement" style="z-index:'+(z+10)+';display:none;position:absolute"></div>';
			}
			lyr3 = $(s);

			// if we have a message, style it
			if (msg) {
				if (opts.theme) {
					lyr3.css(themedCSS);
					lyr3.addClass('ui-widget-content');
				}
				else
					lyr3.css(css);
			}

			// style the overlay
			if (!opts.theme /*&& (!opts.applyPlatformOpacityRules)*/)
				lyr2.css(opts.overlayCSS);
			lyr2.css('position', full ? 'fixed' : 'absolute');

			// make iframe layer transparent in IE
			if (msie || opts.forceIframe)
				lyr1.css('opacity',0.0);

			//$([lyr1[0],lyr2[0],lyr3[0]]).appendTo(full ? 'body' : el);
			var layers = [lyr1,lyr2,lyr3], $par = full ? $('body') : $(el);
			$.each(layers, function() {
				this.appendTo($par);
			});

			if (opts.theme && opts.draggable && $.fn.draggable) {
				lyr3.draggable({
					handle: '.ui-dialog-titlebar',
					cancel: 'li'
				});
			}

			// ie7 must use absolute positioning in quirks mode and to account for activex issues (when scrolling)
			var expr = setExpr && (!$.support.boxModel || $('object,embed', full ? null : el).length > 0);
			if (ie6 || expr) {
				// give body 100% height
				if (full && opts.allowBodyStretch && $.support.boxModel)
					$('html,body').css('height','100%');

				// fix ie6 issue when blocked element has a border width
				if ((ie6 || !$.support.boxModel) && !full) {
					var t = sz(el,'borderTopWidth'), l = sz(el,'borderLeftWidth');
					var fixT = t ? '(0 - '+t+')' : 0;
					var fixL = l ? '(0 - '+l+')' : 0;
				}

				// simulate fixed position
				$.each(layers, function(i,o) {
					var s = o[0].style;
					s.position = 'absolute';
					if (i < 2) {
						if (full)
							s.setExpression('height','Math.max(document.body.scrollHeight, document.body.offsetHeight) - (jQuery.support.boxModel?0:'+opts.quirksmodeOffsetHack+') + "px"');
						else
							s.setExpression('height','this.parentNode.offsetHeight + "px"');
						if (full)
							s.setExpression('width','jQuery.support.boxModel && document.documentElement.clientWidth || document.body.clientWidth + "px"');
						else
							s.setExpression('width','this.parentNode.offsetWidth + "px"');
						if (fixL) s.setExpression('left', fixL);
						if (fixT) s.setExpression('top', fixT);
					}
					else if (opts.centerY) {
						if (full) s.setExpression('top','(document.documentElement.clientHeight || document.body.clientHeight) / 2 - (this.offsetHeight / 2) + (blah = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + "px"');
						s.marginTop = 0;
					}
					else if (!opts.centerY && full) {
						var top = (opts.css && opts.css.top) ? parseInt(opts.css.top, 10) : 0;
						var expression = '((document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + '+top+') + "px"';
						s.setExpression('top',expression);
					}
				});
			}

			// show the message
			if (msg) {
				if (opts.theme)
					lyr3.find('.ui-widget-content').append(msg);
				else
					lyr3.append(msg);
				if (msg.jquery || msg.nodeType)
					$(msg).show();
			}

			if ((msie || opts.forceIframe) && opts.showOverlay)
				lyr1.show(); // opacity is zero
			if (opts.fadeIn) {
				var cb = opts.onBlock ? opts.onBlock : noOp;
				var cb1 = (opts.showOverlay && !msg) ? cb : noOp;
				var cb2 = msg ? cb : noOp;
				if (opts.showOverlay)
					lyr2._fadeIn(opts.fadeIn, cb1);
				if (msg)
					lyr3._fadeIn(opts.fadeIn, cb2);
			}
			else {
				if (opts.showOverlay)
					lyr2.show();
				if (msg)
					lyr3.show();
				if (opts.onBlock)
					opts.onBlock();
			}

			// bind key and mouse events
			bind(1, el, opts);

			if (full) {
				pageBlock = lyr3[0];
				pageBlockEls = $(opts.focusableElements,pageBlock);
				if (opts.focusInput)
					setTimeout(focus, 20);
			}
			else
				center(lyr3[0], opts.centerX, opts.centerY);

			if (opts.timeout) {
				// auto-unblock
				var to = setTimeout(function() {
					if (full)
						$.unblockUI(opts);
					else
						$(el).unblock(opts);
				}, opts.timeout);
				$(el).data('blockUI.timeout', to);
			}
		}

		// remove the block
		function remove(el, opts) {
			var count;
			var full = (el == window);
			var $el = $(el);
			var data = $el.data('blockUI.history');
			var to = $el.data('blockUI.timeout');
			if (to) {
				clearTimeout(to);
				$el.removeData('blockUI.timeout');
			}
			opts = $.extend({}, $.blockUI.defaults, opts || {});
			bind(0, el, opts); // unbind events

			if (opts.onUnblock === null) {
				opts.onUnblock = $el.data('blockUI.onUnblock');
				$el.removeData('blockUI.onUnblock');
			}

			var els;
			if (full) // crazy selector to handle odd field errors in ie6/7
				els = $('body').children().filter('.blockUI').add('body > .blockUI');
			else
				els = $el.find('>.blockUI');

			// fix cursor issue
			if ( opts.cursorReset ) {
				if ( els.length > 1 )
					els[1].style.cursor = opts.cursorReset;
				if ( els.length > 2 )
					els[2].style.cursor = opts.cursorReset;
			}

			if (full)
				pageBlock = pageBlockEls = null;

			if (opts.fadeOut) {
				count = els.length;
				els.stop().fadeOut(opts.fadeOut, function() {
					if ( --count === 0)
						reset(els,data,opts,el);
				});
			}
			else
				reset(els, data, opts, el);
		}

		// move blocking element back into the DOM where it started
		function reset(els,data,opts,el) {
			var $el = $(el);
			if ( $el.data('blockUI.isBlocked') )
				return;

			els.each(function(i,o) {
				// remove via DOM calls so we don't lose event handlers
				if (this.parentNode)
					this.parentNode.removeChild(this);
			});

			if (data && data.el) {
				data.el.style.display = data.display;
				data.el.style.position = data.position;
				if (data.parent)
					data.parent.appendChild(data.el);
				$el.removeData('blockUI.history');
			}

			if ($el.data('blockUI.static')) {
				$el.css('position', 'static'); // #22
			}

			if (typeof opts.onUnblock == 'function')
				opts.onUnblock(el,opts);

			// fix issue in Safari 6 where block artifacts remain until reflow
			var body = $(document.body), w = body.width(), cssW = body[0].style.width;
			body.width(w-1).width(w);
			body[0].style.width = cssW;
		}

		// bind/unbind the handler
		function bind(b, el, opts) {
			var full = el == window, $el = $(el);

			// don't bother unbinding if there is nothing to unbind
			if (!b && (full && !pageBlock || !full && !$el.data('blockUI.isBlocked')))
				return;

			$el.data('blockUI.isBlocked', b);

			// don't bind events when overlay is not in use or if bindEvents is false
			if (!full || !opts.bindEvents || (b && !opts.showOverlay))
				return;

			// bind anchors and inputs for mouse and key events
			var events = 'mousedown mouseup keydown keypress keyup touchstart touchend touchmove';
			if (b)
				$(document).bind(events, opts, handler);
			else
				$(document).unbind(events, handler);

		// former impl...
		//		var $e = $('a,:input');
		//		b ? $e.bind(events, opts, handler) : $e.unbind(events, handler);
		}

		// event handler to suppress keyboard/mouse events when blocking
		function handler(e) {
			// allow tab navigation (conditionally)
			if (e.type === 'keydown' && e.keyCode && e.keyCode == 9) {
				if (pageBlock && e.data.constrainTabKey) {
					var els = pageBlockEls;
					var fwd = !e.shiftKey && e.target === els[els.length-1];
					var back = e.shiftKey && e.target === els[0];
					if (fwd || back) {
						setTimeout(function(){focus(back);},10);
						return false;
					}
				}
			}
			var opts = e.data;
			var target = $(e.target);
			if (target.hasClass('blockOverlay') && opts.onOverlayClick)
				opts.onOverlayClick(e);

			// allow events within the message content
			if (target.parents('div.' + opts.blockMsgClass).length > 0)
				return true;

			// allow events for content that is not being blocked
			return target.parents().children().filter('div.blockUI').length === 0;
		}

		function focus(back) {
			if (!pageBlockEls)
				return;
			var e = pageBlockEls[back===true ? pageBlockEls.length-1 : 0];
			if (e)
				e.focus();
		}

		function center(el, x, y) {
			var p = el.parentNode, s = el.style;
			var l = ((p.offsetWidth - el.offsetWidth)/2) - sz(p,'borderLeftWidth');
			var t = ((p.offsetHeight - el.offsetHeight)/2) - sz(p,'borderTopWidth');
			if (x) s.left = l > 0 ? (l+'px') : '0';
			if (y) s.top  = t > 0 ? (t+'px') : '0';
		}

		function sz(el, p) {
			return parseInt($.css(el,p),10)||0;
		}

	}


	/*global define:true */
	if (typeof define === 'function' && define.amd && define.amd.jQuery) {
		define(['jquery'], setup);
	} else {
		setup(jQuery);
	}

})();

var PaginationViewModel = function (o, caller) {
    var self = this;
    if (!o) o = {};
    if (!caller) caller = self;
    self.rppOptions = [10, 20, 30, 50, 100];
    self.resultsPerPage = ko.observable(self.rppOptions[0]);
    self.totalResults = ko.observable();
    self.currentPage = ko.observable();
    self.start = ko.observable();

    self.lastPage = ko.pureComputed(function() {
        return Math.ceil((self.totalResults() / self.resultsPerPage()));
    });

    self.info = ko.computed(function () {
        if (self.totalResults() > 0) {
            self.start(self.calculatePageOffset(self.currentPage()) + 1);
            var end = Math.min(self.totalResults(), self.start() + self.resultsPerPage() - 1);
            return "Showing " + self.start() + " to " + end + " of " + self.totalResults();
        }
    });

    self.showPagination = ko.computed(function () {
        return self.totalResults() > 0
    }, this);

    self.calculatePageOffset = function (currentPage) {
        return currentPage < 1 ? 0 : (currentPage - 1) * self.resultsPerPage();
    };

    self.next = function () {
        caller.refreshPage(self.calculatePageOffset(self.currentPage() + 1));
        self.currentPage(self.currentPage() + 1);
    };

    self.previous = function () {
        caller.refreshPage(self.calculatePageOffset(self.currentPage() - 1));
        self.currentPage(self.currentPage() - 1);
    };

    self.first = function () {
        caller.refreshPage(0);
        self.currentPage(0)
    };

    self.last = function () {
        caller.refreshPage(self.calculatePageOffset(Math.ceil((self.totalResults() / self.resultsPerPage()))));
        self.currentPage(self.lastPage());
    };

    self.resultsPerPage.subscribe(function () {
        caller.refreshPage(0);
    });

    self.refreshPage = function (rp) {
        // Do nothing.
    };

    self.loadPagination = function (page, total) {
        self.totalResults(total);
        self.currentPage(page < 1 ? 1 : page);
    };
};


