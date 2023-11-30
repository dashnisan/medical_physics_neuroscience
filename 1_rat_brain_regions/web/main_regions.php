<!DOCTYPE html>
<html>
<!------------------------------------------------------------------------------------------------------------------------------------->
<body class="default_layout">
<!------------------------------------------------------------------------------------------------------------------------------------->
															<!-- HEADER / BANNER -->
<?php include("INCLUDE/header.php"); ?>

<!------------------------------------------------------------------------------------------------------------------------------------->	
															<!-- CONTENT -->

<div class="content">
	
			<h4 class="center"> MAPPED BRAIN REGIONS</h4>
			<!-- <h3>MAIN REGIONS (LEVEL1)</h3> -->
			
		<?php
		require_once "connect.php";
		if ($mysqli->connect_error){
			echo "				ERROR: no db connection!";
			exit();
		}

		# Cokie to distinguish from where arrived to show data for l2-regions 
		#setcookie("from_l2rel_details", "0"); # moved to index.php (main_region.php used to be index.php)
	
		
		# Name of script to be called in the query:
		$php_script = "show_l2.php";
		
			
			if($stmt = $mysqli->prepare("SELECT Name, Abbreviation
			FROM LEVEL1_REGIONLIST")) {
			  $stmt->execute();
		  	  $stmt->bind_result($Name, $Abbreviation);
			  echo "<table  class='altrowstable' id='main_regions' border='1'>\n <tr><strong> </strong> \n <tr><td><strong> NAME </strong></td><td><strong> ABBREVIATION </strong></td>\n";
			  #echo "<table border='1'>\n <tr><strong> MAIN REGIONS (LEVEL 1) </strong> \n <tr><td><strong> NAME </strong></td><td><strong> ABBREVIATION </strong></td>\n";
			  while($stmt->fetch()) {
			
		echo "<tr><td><a class='info_link' href='".$php_script."'>" .htmlspecialchars($Name). "</a></td>
			 <td>" .htmlspecialchars($Abbreviation). "</td>	
			 </tr>\n";

				  
			  } 
			  $stmt->close();
			}

		$mysqli->close();
		?>
		</table>
</div> <!-- content>
<!------------------------------------------------------------------------------------------------------------------------------------->
									<!-- FOOTER -->
<?php include("INCLUDE/footer.html"); ?>
<!------------------------------------------------------------------------------------------------------------------------------------->
</div> <!--main_box-->
<!------------------------------------------------------------------------------------------------------------------------------------->
</body>	
<!------------------------------------------------------------------------------------------------------------------------------------->		
									<!-- JS -->
		
<script type="text/javascript"> // GETTING NAME OF SELECTED L1 REGION FOR SQL QUERY:

function altRows(id){
	if(document.getElementsByTagName){  
		
		var table = document.getElementById(id);  
		var rows = table.getElementsByTagName("tr"); 
		 
		for(i = 0; i < rows.length; i++){          
			if(i % 2 == 0){
				rows[i].className = "evenrowcolor";
			}else{
				rows[i].className = "oddrowcolor";
			}      
		}
	}
}


window.onload=function(){
	altRows('main_regions');
}


$(function(){
//alert("hi");
	$('.info_link').click(function(){
	//alert($(this).text());
	// or alert($(this).hash();
		
	//var l1_selection = $(this).text();
	//alert(l1_selection);

	// Create a Cookie:
	$.cookie("l1_selection", $(this).text());
	//alert($.cookie("l1_selection"));
	});
});
</script>

<!------------------------------------------------------------------------------------------------------------------------------------->
		
</html>


