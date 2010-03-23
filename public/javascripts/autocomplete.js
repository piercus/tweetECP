function initAC() {
var oDS1 = new YAHOO.util.XHRDataSource(urlAutoCompUser+"&");
var oDS2 = new YAHOO.util.XHRDataSource(urlAutoCompTag+"&");

    oDS1.responseType = YAHOO.util.XHRDataSource.TYPE_JSARRAY;
    oDS2.responseType = YAHOO.util.XHRDataSource.TYPE_JSARRAY;
oDS1.responseSchema = {
    fields: ["name"]
};
oDS2.responseSchema = {
    fields: ["name"]
};


      var formUser = new inputEx.Form( { 
            fields: [ 
               {
									name:"id",
									type: "autocomplete",
									label: 'Type a User',
									datasource: oDS1, 
									// Format the hidden value (value returned by the form)
									returnValue: function(oResultItem) {
										return oResultItem[0];
									},
									autoComp: {
										forceSelection: true,
										queryQuestionMark: false,
										minQueryLength: 2,
										maxResultsDisplayed: 50
									}
								},
								{type: 'hidden', name:'type', value:'user'}
            ], 
						action: urlAction,
            buttons: [{type: 'submit', value: 'Search'}],
            parentEl: 'user_screen_name'
         });
      var formTag = new inputEx.Form( { 
            fields: [ 
               {
									name:"id",
									type: "autocomplete",
									label: 'Type a Tag',
									datasource: oDS2, 
									// Format the hidden value (value returned by the form)
									returnValue: function(oResultItem) {
										return oResultItem[0];
									},
									autoComp: {
										forceSelection: true,
										queryQuestionMark: false,
										minQueryLength: 2,
										maxResultsDisplayed: 50
									}
								},
								{type: 'hidden', name:'type', value:'tag'}
            ], 
						action: urlAction,
            buttons: [{type: 'submit', value: 'Search'}],
            parentEl: 'tag_screen_name'
         });



};
 YAHOO.util.Event.onDOMReady(initAC);
