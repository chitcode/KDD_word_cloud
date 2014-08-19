<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

<style>
	body {
	  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
	  width: 960px;
	  height: 500px;
	  position: relative;
	}

	form {
	  position: absolute;
	  top: 1em;
	  left: 1em;
	}

	path {
	  fill-rule: evenodd;
	  stroke: #333;
	  stroke-width: 2px;
	}

</style>

<script type="text/javascript">

</script>
</head>

<body onload = updateViz();>
  <%
    import pandas as pd
    import numpy as np
    import re
 	data = pd.read_csv('data/essay_sample.csv',nrows = 2)
    headers = data.columns
    
  %>
  <form id="colheads">
  	<table>
  	    <tr>
  		%for col in headers:  		
  		  <td>  		   
  		   <input type="checkbox" name="colheader" value={{col}} checked>{{col}}</input> 
  		  </td>  		   
  		%end
  		</tr>	
  	</table>
  </form>

   <p></p>
  
  <script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
  <script src="static/d3.layout.cloud.js"></script>
  <script>  
  
  
  
	var frequency_list = [];
	
	
	d3.selectAll("input")
		.on("change",function(d){updateViz()});	
    
	
	function updateViz(){
		var selectedVals = [];
						d3.selectAll("input")
						.filter(function(d,i){return this.checked})
						.each(function(d,i){selectedVals.push(d3.select(this).attr("value"))});
		
		var xmlhttp;
			if (window.XMLHttpRequest)
  				{// code for IE7+, Firefox, Chrome, Opera, Safari
  					xmlhttp=new XMLHttpRequest();
  				}
			else
 				 {// code for IE6, IE5
  					xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  				}
  			xmlhttp.onreadystatechange=function(){
  				if (xmlhttp.readyState==4 && xmlhttp.status==200){
    				result=xmlhttp.responseText;
    				
    				frequency_list = JSON.parse(result);  				
    				
    				
    				d3.select('p').selectAll("*").remove();
    				updateCloud();
    				}
  				}
  				
  			xmlhttp.open("GET","getUpdatedData?columns=" + selectedVals,true);
			xmlhttp.send();
		
		}
		
	
	function updateCloud(){	
		
             
          var color = d3.scale.category20();          	
            //.domain([0,5,10,20,30,40,50,60,75,80,90]);
            //.range(["#ddd", "#ccc", "#bbb", "#aaa", "#999", "#888", "#777", "#666", "#555", "#444", "#333", "#222"]);
            
         
         var size_scale = d3.scale.log()
         	.domain([d3.min(frequency_list,function(d){return d['size'];}),d3.max(frequency_list,function(d){return d['size'];})])
         	//.domain([word_count_min,word_count_max])
         	.range([0,40]);
        
        var tooltip = d3.select("body")
    					.append("div")
						.style("position", "absolute")
    					.style("z-index", "10")
   					    .style("visibility", "hidden")
   					    .text('tooltip text');
         

    d3.layout.cloud().size([800, 600])
            .words(frequency_list)
            .rotate(0)
            .fontSize(function(d) { return d.size; })
            .on("end", draw)
            .start();

    function draw(words) {   			
    			
        		d3.select("p").append("svg:svg")
                .attr("width", 1250)
                .attr("height", 650)
                .attr("class", "wordcloud")
                .append("g")
                // without the transform, words words would get cutoff to the left and top, they would
                // appear outside of the SVG area
                .attr("transform", "translate(500,400)")
                .selectAll("text")
                .data(words)
                .enter().append("text")
                .style("font-size", function(d) { return size_scale(d.size) + "px"; })
                .style("fill", function(d, i) { return color(i); })
                .attr("transform", function(d) {
                    return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
                })
                .text(function(d) { return d.text; })
                .on("mouseover", function(d){return tooltip.style("visibility", "visible")+
					    tooltip.text(d.text+" : "+d.size);})
				.on("mousemove", function(){return tooltip.style("top",
    					(d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
				.on("mouseout", function(){return tooltip.style("visibility", "hidden");});
    }	
		}
		
  </script>
  
</body>
</html>
