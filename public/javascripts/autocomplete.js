function initAC() {
var oDS = new YAHOO.util.XHRDataSource(urlAutoCompUser+"&");

    oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSARRAY;
oDS.responseSchema = {
    fields: ["name"]
};


      var formUser = new inputEx.Form( { 
            fields: [ 
               {
									name:"id",
									type: "autocomplete",
									label: 'Type a User',
									datasource: oDS, 
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



};
 YAHOO.util.Event.onDOMReady(initAC);
