// Make sure the dom loads
document.observe('dom:loaded', function() {

	$('add_button').observe('click', respondToClick);

	$('nature').observe('change', respondToListClick);

	var array_list = new Array();

	function respondToClick(event) {
  		var text = $('existing_custom_field')[$('existing_custom_field').selectedIndex].text;
  		var id_value = $('existing_custom_field')[$('existing_custom_field').selectedIndex].value;
  		 $('table_body').insert({
 			bottom: '<tr><td>'+text+':'+'</td><td><input type="text" name="'+id_value+'"/></td></tr>'                            
		});

  		array_list.push($('existing_custom_field')[$('existing_custom_field').selectedIndex]);
  		$('existing_custom_field')[$('existing_custom_field').selectedIndex].remove();
	}

	function respondToListClick(event) {

		var nature_state = $('nature')[$('nature').selectedIndex].text;

		if (nature_state == 'AssetGroup') 
		{
			$('attribute_toggler').hide();

			var count = 1;
			//All the custom attribute should be removed as well
			$$('#table_body tr').each(function(i)  
       			 {
       			 	console.log(i);
            		if ( count > 4 )
            		{
            			i.remove();
            		}
            		count = count + 1 ;
       			 });

			array_list.each(function(i)
			{
				$('existing_custom_field').insert(i);
			});

			array_list = [];
		}
		else
		{
			$('attribute_toggler').show();
		}
	}

});


