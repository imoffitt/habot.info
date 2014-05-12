<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page isErrorPage="true"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Page Not found</title>
</head>
<body>
    <p align="center">
    <%
        out.println("Requested resource: " + request.getRequestURL()+ " not found<br>");
		
String statusCocde = (String) request.getAttribute("javax.servlet.error.status_code");
String exceptionType = (String) request.getAttribute("javax.servlet.error.exception_type");
String errorMsg = (String) request.getAttribute("javax.servlet.error.message");
String uri = (String) request.getAttribute("javax.servlet.error.request_uri");

out.println("statusCocde: " + statusCocde + "<br>");
out.println("exceptionType: " + exceptionType + "<br>");
out.println("errorMsg: " + errorMsg + "<br>");
out.println("uri: " + uri + "<br>");
    %>
</body>