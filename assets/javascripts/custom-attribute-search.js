// Make sure the dom loads
document.observe('dom:loaded', function() {

	$('add_button').observe('click', respondToClick);

	function respondToClick(event) {
  		var text = $('existing_custom_field')[$('existing_custom_field').selectedIndex].text;
  		 $('table_body').insert({
 			bottom: '<tr><td>'+text+':'+'</td><td><input type="text" name="'+text+'"/></td></tr>'                            
		});

  		$('existing_custom_field')[$('existing_custom_field').selectedIndex].remove();
	}

});


