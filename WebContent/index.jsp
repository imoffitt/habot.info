<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/include/session.jsp" %> 
<HEAD><TITLE>Strategic Response Expert System - Open University TM470</TITLE>
<link rel="stylesheet" media="screen" href="style.css">
<META http-equiv=Content-Type content="text/html; charset=windows-1252">
<META content="Strategic Response Expert System - Open University TM470" name=description>
<META content="Highways,ai,Traffic,expert system,expert,Open University,TM470.final project" 
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
<script>
var url = 'http://localhost:8080/habot.info';
//var url = 'http://www.habot.info';
var httpRequest;

function createTestEventA556 () {	
	var element = document.getElementById('roadNameList');
    element.value = 'A556';
	document.getElementById('roadDirectionDiv').innerHTML = "Direction <select onchange=\"sendRequestLocationGet ();\" name=\"direction\" id=\"direction\"><option value='northbound'  selected=\"selected\">northbound</option></select>";
	document.getElementById('roadLocationDiv').innerHTML = "Location <select name=\"location\" id=\"location\"><option value='A556 northbound between A50 and A5034:125000501' selected=\"selected\">A556 northbound between A50 and A5034</option></select>";
	
	return false;
}

function sendRequestDirectionGet () {
	
	var roadNameList = document.getElementById("roadNameList").options[document.getElementById("roadNameList").selectedIndex].value;
	var requestUrl = url + "/AjaxHabot?action=direction&roadName=" + roadNameList;
	
	//alert('requestUrl=' + requestUrl);
	makeRequest(requestUrl);
}


function sendRequestLocationGet () {
	//alert('sendRequestLocationGet');
		
	var roadNameList = document.getElementById("roadNameList").options[document.getElementById("roadNameList").selectedIndex].value;
	var roadDirectionList = document.getElementById("direction").options[document.getElementById("direction").selectedIndex].value;
	var requestUrl = url + "/AjaxHabot?action=location&roadName=" + roadNameList + "&direction="  + roadDirectionList;
    var loader = dhtmlxAjax.getSync(requestUrl);
	var xmldoc = loader.xmlDoc.responseXML;
		
	var x=xmldoc.getElementsByTagName("roadLocation");
	var roadLocationOptions = "";

	for (i=0;i<x.length;i++) {
	
	  roadLocationOptions = roadLocationOptions + "<option value='" + x[i].childNodes[0].nodeValue + ":" + x[i].getAttribute('linkId') + "'>" + x[i].childNodes[0].nodeValue + "</option>";
	  
	}
	
	document.getElementById('roadLocationDiv').innerHTML = "Location <select name=\"location\" id=\"location\">" + roadLocationOptions + "</select>";
}

function makeRequest(url) {
	
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
    	  
// alert("RESP=" + httpRequest.responseText);
        
    	var x=httpRequest.responseXML.getElementsByTagName("roadDirection");
    	var roadDirectionOptions = "";

    	for (i=0;i<x.length;i++) {
    	
    	  //alert ("option=" + x[i].childNodes[0].nodeValue );
    		
    	  roadDirectionOptions = roadDirectionOptions + "<option value='" + x[i].childNodes[0].nodeValue + "'>" + x[i].childNodes[0].nodeValue + "</option>";
    	}
    	
    	document.getElementById('roadDirectionDiv').innerHTML = "Direction <select onchange=\"sendRequestLocationGet ();\" name=\"direction\" id=\"direction\">" + roadDirectionOptions + "</select>";
        
      } else {
        alert('There was a problem with the request.');
      }
    }
}
</script>
<%
StringBuffer roadNameList = new StringBuffer();
		try {
		
        // dynamic query
		
		ArrayList<Map<String, Object>> lstRoadNames = sqlLookupBean.getValue ("SELECT distinct roadNumber FROM Network_Links order by roadNumber");

		for (Map<String, Object> mapRoadNames : lstRoadNames)
		{
			String roadName = (String) mapRoadNames.get("roadNumber");
			roadNameList.append("<option value=\"" + roadName + "\">" + roadName + "</option>");
		}

		} catch (Exception ex) { out.print ("size=" + ex.getMessage() + "<br>"); }
%>
<h2 align=center>Highways  Traffic Management Expert System- Open University TM470</h2>
<table width="100%" border="0" cellspacing="3" cellpadding="3">
  <tr>
    <td valign="top"><p>Step 1. Create an Incident on the network </p>
      <form action="strategic_response.jsp" method="post" name="fromIncident" id="fromIncident">
        <table width="100%" border="1" cellspacing="3" cellpadding="3">
          <tr>
            <td width="22%">Incident Type </td>
            <td width="78%"><label>
              <select name="lstIncidentType" id="lstIncidentType">
                  <option value="Accident">Accident</option>
              </select>
            </label></td>
          </tr>
          <tr>
            <td>Location</td>
            <td>Road 
              <select name="roadNameList" id="roadNameList" onchange="sendRequestDirectionGet ();">
                <%= roadNameList %>
              </select>&nbsp;&nbsp;<div style="display: inline;" id="roadDirectionDiv"></div>&nbsp;&nbsp;
              <div style="display: inline;" id="roadLocationDiv"></div>
              &nbsp;</td>
          </tr>
		            <tr>
		              <td>&nbsp;</td>
		              <td></td>
          </tr>
		            <tr>
            <td>&nbsp;</td>
            <td><label>
              <input type="submit" name="Submit" value="Create Event"> &nbsp;&nbsp;&nbsp;
              <input name="btnTestEvent" type="button" id="btnTestEvent" value="Test Event A556" onclick="createTestEventA556();" />
            </label></td>
          </tr>
        </table>
      </form>      <p>&nbsp;</p></td>
    <td width="521" valign="top"><div align="center"><a href="images/Highways_Agency_Network_Map_-_November_2011.gif"><img src="images/Highways_Agency_Network_Map_-_November_2011-352x450.gif" width="352" height="450" border="0"></a><br>
    Source : <a href="http://www.highways.gov.uk/our-road-network/our-network/" target="_parent">highways.gov.uk</a></div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td width="521">&nbsp;</td>
  </tr>
</table>
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

document.getElementById('roadDirectionDiv').innerHTML = "Direction <select name=\"direction\"  id=\"direction\"></select>";
document.getElementById('roadLocationDiv').innerHTML = "Location <select name=\"location\" id=\"location\"></select>";

     var sld = new dhtmlxSlider("slider", {
              size:150,           
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
          });
	 sld.init();
</script>
</BODY>
</HTML>