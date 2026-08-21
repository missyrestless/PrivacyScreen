/*  teacup.js v0.5.1 <!-- */

var u0=function(){//-- faster!
	if(window.addEventListener){
		return function(l0,l1,l2){
			l0.addEventListener(l1,l2,false);
		};
	}else if(window.attachEvent){
		return function(l0,l1,l2){
			l0.attachEvent('on'+l1,l2);
		};
	}
}();

function u1(l0){
	if (l0.preventDefault){
		l0.preventDefault();
	}//-- cross-compat?
	v1=document.createElement('script');
	document.head.appendChild(v1);
	u0(v1,'load',u2);//-- no 'type' breaks standards
	v1.src=(typeof(this.href)!='undefined')?this.href:l0;
	v2=setTimeout('u2(\'504 Gateway Timeout or 404 Not Found\')',23000);
}
//-- v0,v1,v2 exist here
function u2(l0){//-- Achtung Baby!
	clearTimeout(v2);
	if(typeof(v0)=='undefined'){
		if (typeof(l0)!='object'){
			alert(l0+'\n'+v1.src.substring(81)+'\n');
		}//-- catches timeouts, send js to alert others
	}else{
		document.body.innerHTML=v0;
		for(var l1=0;l1<document.links.length;l1++){
			if (~document.links[l1].href.indexOf('.tsp')){
				u0(document.links[l1],'click',u1);
			}
		}//-- the double split seemed more effective than the regex
		document.title=decodeURI(v1.src.split(document.head.getElementsByTagName('base')[0].href)[1].split('.tsp')[0]);
		var l2;
		v2=document.body.getElementsByTagName('script');
		for(l1=0;l1<v2.length;l1++){
			l2=document.createElement('script');
			if(~v2[l1].src.indexOf('.js')){
				l2.src=v2[l1].src;//-- no 'type' breaks standards
			}else if(v2[l1].childNodes.length){
				l2.appendChild(v2[l1].childNodes[0]);
			}
			v2[l1].parentNode.replaceChild(l2,v2[l1]);
		}//-- extend script jumpstarter to link/css?
	}//-- next line: clean up; aisle 2
	document.head.removeChild(v1);
	v0=v1=v2=(function(){})();
}//-- like that evil 'undefined' hack?

window.onload=function(){//-- webkit is stupid and doesn't obey script tag defer/async attributes
	document.head=document.head||document.getElementsByTagName('head')[0];
	document.body=document.body||document.getElementsByTagName('body')[0];
	u1('index.tsp');//-- default page name
};

/* -->
  (C)2011 (CC-BY) [ http://creativecommons.org/licenses/by/3.0 ]
 Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ] */
