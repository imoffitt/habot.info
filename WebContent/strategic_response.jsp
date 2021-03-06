<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/session.jsp" %> 
<%@ page import="java.text.SimpleDateFormat,java.util.Date" %>
<HEAD><TITLE>Strategic Response - Traffic Expert System - Open University TM470</TITLE>
<link rel="stylesheet" media="screen" href="style.css">
<META http-equiv=Content-Type content="text/html; charset=windows-1252">
<META content="Highways and Byways Traffic Chat Robot - Open University TM470" name=description>
<META content="Highways,Byways,Traffic,Chat,Robot,Open University,TM470.final project" 
name=keywords>
<LINK href="styles.css" type=text/css rel=stylesheet>
<link rel="stylesheet" type="text/css" href="dhtmlxSlider/dhtmlxSlider/codebase/dhtmlxslider.css">
<script src="dhtmlxSlider/dhtmlxSlider/codebase/dhtmlxcommon.js"></script>
<script src="dhtmlxSlider/dhtmlxSlider/codebase/dhtmlxslider.js"></script>    
<script>window.dhx_globalImgPath="dhtmlxSlider/dhtmlxSlider/codebase/imgs/";</script>

<script type="text/javascript" src="nogray_js/1.2.1/ng_all.js"></script>
<script type="text/javascript" src="nogray_js/1.2.1/ng_ui.js"></script>
<script type="text/javascript" src="nogray_js/1.2.1/components/timepicker.js"></script>

<script  src="dhtmlxAjax/dhtmlxAjax/codebase/dhtmlxcommon.js"></script>
</HEAD>
<BODY>
<%
String location = (String) request.getParameter("location");
//out.print ("Location=" + location + "<br>");
String LinkId = "";
if (null != location) {
	int i = location.indexOf(":");
	LinkId = location.substring (i+1);
	location = location.substring (0,i);
}
java.util.Date dNow = new java.util.Date( );
SimpleDateFormat ft =  new SimpleDateFormat ("HH:mm");
%>
<script>
//var url = 'http://localhost:8080/habot.info';
var url = 'http://www.habot.info';

var currentTime = "<%= ft.format(dNow) %>";

function sendRequestTrafficGet () {
	//alert('sendRequestTrafficGet');
	
	var requestUrl = url + "/AjaxHabot?action=traffic&linkId=<%= LinkId %>&derivedDate=2014-01-17 " + currentTime + ".00";
	
	//alert('requestUrl=' + requestUrl);
	
    var loader = dhtmlxAjax.getSync(requestUrl);
	var xmldoc = loader.xmlDoc.responseXML;
	
	var x=xmldoc.getElementsByTagName("fusedSensorData");
	
	document.getElementById("VehicleFlowRate").textContent  = x[0].childNodes[1].firstChild.nodeValue;
	document.getElementById("TravelTime").textContent  = x[0].childNodes[2].firstChild.nodeValue;
	document.getElementById("OccupancyPercentage").textContent  = x[0].childNodes[3].firstChild.nodeValue;
	document.getElementById("FreeFlowTravelTime").textContent  = x[0].childNodes[4].firstChild.nodeValue;
	document.getElementById("AverageTimeHeadway").textContent  = x[0].childNodes[5].firstChild.nodeValue;
	document.getElementById("NormallyExpectedTravelTime").textContent  = x[0].childNodes[6].firstChild.nodeValue;
	document.getElementById("AverageVehicleSpeed").textContent  = x[0].childNodes[7].firstChild.nodeValue;
	document.getElementById("DerivedTime").textContent  = x[0].childNodes[8].firstChild.nodeValue;
}

function timeChanged () {
	alert ("timeChanged");
}

function capacityChanged () {

	var travelTime = document.getElementById("TravelTime").textContent;
	var freeFlowTravelTime = document.getElementById("FreeFlowTravelTime").textContent;
	var normallyExpectedTravelTime = document.getElementById("NormallyExpectedTravelTime").textContent;
	
	if (travelTime == 0.0) {
		travelTime = normallyExpectedTravelTime;
	}
	
	var addition = travelTime * (fromIncident.capacityReduction.value / 100);
	var adjustedTravelTime = (parseFloat(travelTime) + parseFloat(addition)).toFixed(2);
	
	document.getElementById("AdjTravelTime").textContent = adjustedTravelTime;
}

function evaluateEvent () {


	var cheatMode = document.getElementById("cheatMode").checked;
	
	//alert (cheatMode);
	
	var requestUrl = url + "/AjaxHabot?action=evaluateEvent&linkId=<%= LinkId %>&derivedDate=2014-01-17 " + document.getElementById("timepicker_input").value + 
		".00&lstIncidentType=<%= request.getParameter("lstIncidentType") %>&capacityReduction=" + document.getElementById("capacityReduction").value +
		"&cheatMode=" + cheatMode;
		
	makeRequest(requestUrl);
}

function makeRequest(url) {
	
	//alert (url);
	document.getElementById("vmsUnit").innerHTML = url;
	
    if (window.XMLHttpRequest) { // Mozilla, Safari, ...
      httpRequest = new XMLHttpRequest();
    } else if (window.ActiveXObject) { // IE
      try {
        httpRequest = new ActiveXObject("Msxml2.XMLHTTP");
      } 
      catch (e) {
        try {
          httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
        } 
        catch (e) {  }
      }
    }

    if (!httpRequest) {
      alert('Giving up :( Cannot create an XMLHTTP instance');
      return false;
    }
    
    httpRequest.onreadystatechange = alertContents;
    httpRequest.open('GET', url);
    httpRequest.send();
}

function alertContents() {
	
    if (httpRequest.readyState === 4) {	
      if (httpRequest.status === 200) {
		  
        //alert("RESP=" + httpRequest.responseText.substring(1, 200));
        
    	var x=httpRequest.responseXML.getElementsByTagName("evaluateEvent");

		var eventSubType = httpRequest.responseXML.getElementsByTagName("eventSubType")[0].childNodes[0].nodeValue;
		var eventAlternativeRoute = httpRequest.responseXML.getElementsByTagName("eventAlternativeRoute")[0].childNodes[0].nodeValue;
		var eventLocationSuitable = httpRequest.responseXML.getElementsByTagName("eventLocationSuitable")[0].childNodes[0].nodeValue;
		var eventSeveritySuitable = httpRequest.responseXML.getElementsByTagName("eventSeveritySuitable")[0].childNodes[0].nodeValue;
		var eventTypeSuitable = httpRequest.responseXML.getElementsByTagName("eventTypeSuitable")[0].childNodes[0].nodeValue;
		/*
		var eventSubType = httpRequest.responseXML.getElementsByTagName("eventSubType")[0].nodeValue;
		var eventAlternativeRoute = httpRequest.responseXML.getElementsByTagName("eventAlternativeRoute")[0].nodeValue;
		var eventLocationSuitable = httpRequest.responseXML.getElementsByTagName("eventLocationSuitable")[0].nodeValue;
		var eventSeveritySuitable = httpRequest.responseXML.getElementsByTagName("eventSeveritySuitable")[0].nodeValue;
		var eventTypeSuitable = httpRequest.responseXML.getElementsByTagName("eventTypeSuitable")[0].nodeValue;*/
		
		var startIdx = httpRequest.responseText.indexOf("<object-stream>");
		var endIdx = httpRequest.responseText.indexOf("</object-stream>");		
		var explanation = httpRequest.responseText.substring(startIdx, endIdx);
				
		var resultsText = "eventSubType=" + eventSubType + "<br>" +
			"eventAlternativeRoute=" + eventAlternativeRoute + "<br>" +
			"eventLocationSuitable=" + eventLocationSuitable + "<br>" +
			"eventSeveritySuitable=" + eventSeveritySuitable + "<br>" +
			"eventTypeSuitable=" + eventTypeSuitable;
			
		// VMSUnit
		document.getElementById("vmsline1").innerHTML = httpRequest.responseXML.getElementsByTagName("MessageLine1")[0].childNodes[0].nodeValue;
		document.getElementById("vmsline2").innerHTML = httpRequest.responseXML.getElementsByTagName("MessageLine2")[0].childNodes[0].nodeValue;
		document.getElementById("vmsline3").innerHTML = httpRequest.responseXML.getElementsByTagName("MessageLine3")[0].childNodes[0].nodeValue;
		
		var vmsText = "Electronic Address : " + httpRequest.responseXML.getElementsByTagName("vmsUnitElectronicAddress")[0].childNodes[0].nodeValue + 
			", Geog Address : " + httpRequest.responseXML.getElementsByTagName("vmsUnitIdentifier")[0].childNodes[0].nodeValue +
			"<br>" + httpRequest.responseXML.getElementsByTagName("vmsType")[0].childNodes[0].nodeValue + " (" + 
			httpRequest.responseXML.getElementsByTagName("vmsTypeCode")[0].childNodes[0].nodeValue + "), [Lat=" + 
			httpRequest.responseXML.getElementsByTagName("Lattitude")[0].childNodes[0].nodeValue + "Long=" +
			httpRequest.responseXML.getElementsByTagName("Lontitude")[0].childNodes[0].nodeValue + "]";
		
		document.getElementById("vmsUnit").innerHTML = vmsText;
			
		document.getElementById("explanationArea").rows=30;
		document.getElementById("explanationArea").innerHTML = explanation;
		document.getElementById("explanationDiv").style.visibility="visible";
		
		document.getElementById("defaultRouteDiv").style.visibility="visible";
		document.getElementById("alternativeRouteDiv").style.visibility="visible";
		
		// Alt Route
		var altRoute=httpRequest.responseXML.getElementsByTagName("AlternativeRoute");	
			resultsText = resultsText + "<br>Alternative Travel Time=" + altRoute[0].getElementsByTagName("travelTime")[0].childNodes[0].nodeValue;
		
		var altRoutes = altRoute[0].getElementsByTagName("AlternativeRouteExplantion");
		
		var altRouteText = "";
		for (i=0;i<altRoutes.length;i++) {
	  		//alert (altRoutes[i].getElementsByTagName("locationName")[0].childNodes[0].nodeValue);
			altRouteText = altRouteText + altRoutes[i].getElementsByTagName("locationName")[0].childNodes[0].nodeValue + "\n";
		}

		document.getElementById("alternativeRouteTxt").innerHTML = altRouteText;
		document.getElementById("alternativeRouteTxt").rows=10;
		
		// Curr Route
		var currRoute=httpRequest.responseXML.getElementsByTagName("DefaultRoute");	
		resultsText = resultsText + "<br>Default Travel Time=" + currRoute[0].getElementsByTagName("travelTime")[0].childNodes[0].nodeValue;
		var currRoutes = currRoute[0].getElementsByTagName("DefaultRouteExplantion");
		
		var currRouteText = "";
		for (i=0;i<currRoutes.length;i++) {
	  		//alert (altRoutes[i].getElementsByTagName("locationName")[0].childNodes[0].nodeValue);
			currRouteText = currRouteText + currRoutes[i].getElementsByTagName("locationName")[0].childNodes[0].nodeValue + "\n";
		}

		document.getElementById("defaultRouteTxt").innerHTML = currRouteText;
		document.getElementById("defaultRouteTxt").rows=10;
		
		document.getElementById("resultsPanel").innerHTML = "<p>" + resultsText + "</p>";
	  
      } else {
        alert('There was a problem with the request. status=' + httpRequest.status);
		document.getElementById("vmsUnit").innerHTML = httpRequest.responseText;
      }
    }
}

document.getElementById("explanationArea").style.visibility="hidden";
</script>
<h2 align=center>Highways  Traffic Management Expert System- Open University TM470</h2>
<a href="/">Home</a>
<form action="#" method="post" name="fromIncident" id="fromIncident">
<table width="100%" border="0" cellspacing="3" cellpadding="3">
  <tr>
    <td valign="top"><p>Step 2. Strategic Response Management </p>
      
        <table width="100%" border="1" cellspacing="3" cellpadding="3">
          <tr>
            <td width="22%">Incident  </td>
            <td width="78%"><b><%= request.getParameter("lstIncidentType") %></b><input name="lstIncidentType" type="hidden" value="<%= request.getParameter("lstIncidentType") %>" /></td>
          </tr>
          <tr>
            <td>Location</td>
            <td>Road <b><%= request.getParameter("roadNameList") %></b><input name="roadNameList" type="hidden" value="<%= request.getParameter("roadNameList") %>" />
&nbsp;&nbsp;
			  Direction <b><%= request.getParameter("direction") %></b><input name="direction" type="hidden" value="<%= request.getParameter("direction") %>" />&nbsp;&nbsp;
              Location  <b><%= location %></b><input name="location" type="hidden" value="<%= location %>:<%= LinkId %>" /><input name="linkId" type="hidden" value="<%= LinkId %>" />
              &nbsp;</td>
          </tr>
		            <tr>
            <td>Capacity Reduction </td>
            <td><input onchange="capacityChanged();" id="capacityReduction" name="capacityReduction" type="text" value="5" size="2" maxlength="2" readonly="true" />%
            <div id="slider"></div></td>
          </tr>
		            <tr>
		              <td>Current Time </td>
		              <td><input name="timepicker_input" type="text" id="timepicker_input" value="<%= ft.format(dNow) %>" size="10" maxlength="10">
<script type="text/javascript">
ng.ready( function() {
    var tp = new ng.TimePicker({
        input: 'timepicker_input',  // the input field id
        events: {
            onChange:function () {
                /* this will refer to the time picker object */
                alert('onChange Event');
            }
        },
		picker_image:'nogray_js/1.2.1/assets/components/timepicker/images/clock_icon.png',
        format:'H:i',
        server_format:'H:i',
        use24:true,
		value:'<%= ft.format(dNow) %>',
        top_hour: 24  // what's the top hour (in the clock face, 0 = midnight)
    });
});
</script></td>
          </tr>
<tr>
            <td height="39">&nbsp;</td>
            <td valign="top">
<table width="100%" border="0" cellspacing="3" cellpadding="3">
  <tr>
    <td>VehicleFlowRate = <div style="display: inline;" id="VehicleFlowRate"></div></td>
    <td>TravelTime = <div style="display: inline;" id="TravelTime"></div>, Adj = (<div class=error style="display: inline;" id="AdjTravelTime"></div>)</td>
  </tr>
  <tr>
    <td>OccupancyPercentage = <div style="display: inline;" id="OccupancyPercentage"></div></td>
    <td>FreeFlowTravelTime = <div style="display: inline;" id="FreeFlowTravelTime"></div></td>
  </tr>
  <tr>
    <td>AverageTimeHeadway = <div style="display: inline;" id="AverageTimeHeadway"></td>
    <td>NormallyExpectedTravelTime = <div style="display: inline;" id="NormallyExpectedTravelTime"></div></td>
  </tr>
  <tr>
    <td>AverageVehicleSpeed = <div style="display: inline;" id="AverageVehicleSpeed"></div></td>
    <td>DerivedTime = <div style="display: inline;" id="DerivedTime"></div></td>
  </tr>
</table></td>
          </tr>
<tr>
  <td height="39">&nbsp;</td>
  <td valign="top"><input name="btnTestEvent" type="button" id="btnTestEvent" value="Evaluate by Expert System" onclick="evaluateEvent();" /> &nbsp;&nbsp;&nbsp;&nbsp; CheatMode <input alt="Defaults to A556 Route" id="cheatMode" name="cheatMode" type="checkbox" value="1" checked="checked" />
    </td>
</tr>
        </table></td>
    <td width="521" valign="top"><div id="resultsPanel" align="center"><a href="images/Highways_Agency_Network_Map_-_November_2011.gif"><img src="images/Highways_Agency_Network_Map_-_November_2011-352x450.gif" width="352" height="450" border="0"></a><br>
    Source : <a href="http://www.highways.gov.uk/our-road-network/our-network/" target="_parent">highways.gov.uk</a></div>
      <table width="300" border="0" cellpadding="1" cellspacing="1" bgcolor="#000000">
        <tr  align="center">
          <td  class="vmsUnit"><div id="vmsline1"></div></td>
          </tr>
        <tr align="center">
          <td class="vmsUnit"><div id="vmsline2"></div></td>
          </tr>
        <tr align="center">
          <td class="vmsUnit"><div id="vmsline3"></div></td>
          </tr>
      </table>
    <div align="left" id="vmsUnit"></div></td>
  </tr>
  <tr><td width="50%"><div id="defaultRouteDiv" style="visibility:hidden"><fieldset>
    <legend>Default Route</legend><textarea name="defaultRouteTxt" style="width:100%" rows="1" id="defaultRouteTxt"></textarea>
	</fieldset></div></td>
	<td width="50%"><div id="alternativeRouteDiv" style="visibility:hidden"><fieldset>
    <legend>Alternative Route</legend><textarea name="alternativeRouteTxt" style="width:100%" rows="1" id="alternativeRouteTxt"></textarea>
	</fieldset></div></td></tr>
  <tr>
    <td colspan="2"><div id="explanationDiv" style="visibility:hidden"><fieldset>
    <legend>Explanation</legend><textarea name="explanationArea" style="width:100%" rows="1" id="explanationArea"></textarea>
	</fieldset></div></td>
  </tr>
</table>
</form>
<div class="footer">
<p>Afoot and light-hearted I take to the open road,
  Healthy, free, the world before me,
  The long brown path before me leading wherever I choose.</p>
<p> Henceforth I ask not good-fortune, I myself am good-fortune,
  Henceforth I whimper no more, postpone no more, need nothing,
  Done with indoor complaints, libraries, querulous criticisms,
  Strong and content I travel the open road. </p>
<p> The earth, that is sufficient,
  I do not want the constellations any nearer,
  I know they are very well where they are,
  I know they suffice for those who belong to them. </p>
<p> (Still here I carry my old delicious burdens,
  I carry them, men and women, I carry them with me wherever I go,
  I swear it is impossible for me to get rid of them,
  I am fill&rsquo;d with them, and I will fill them in return.) </p>
<p>Song of the Open Road - BY WALT WHITMAN</p></div>

<script>
sendRequestTrafficGet ();

     var sld = new dhtmlxSlider("slider", {
              size:250,           
                 skin: "ball",
                 vertical:false,
                 step:5,
                 min:0,
                 max:100,
                 value:10           
          });
	 sld.setImagePath("dhtmlxSlider/dhtmlxSlider/codebase/imgs/"); 
	 sld.attachEvent("onChange",function(newValue,sliderObj){
		 fromIncident.capacityReduction.value = newValue;
		 capacityChanged (); 
     }) 

	 sld.init();
</script>
</BODY>
</HTML>