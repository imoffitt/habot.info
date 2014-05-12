<%@ page import="java.util.*, java.sql.*,info.habot.tm470.dao.*" %>
<%
String driverName = application.getInitParameter("driverName");
String dbUrl = application.getInitParameter("dbUrl");
String userId = application.getInitParameter("userId");
String passWord = application.getInitParameter("passWord");
%>
<jsp:useBean id="sqlLookupBean" class="info.habot.tm470.dao.SqlLookupBean" scope="page">
<jsp:setProperty name="sqlLookupBean" property="driverName" value="<%= driverName %>"/>
<jsp:setProperty name="sqlLookupBean" property="dbUrl" value="<%= dbUrl %>"/>
<jsp:setProperty name="sqlLookupBean" property="userId" value="<%= userId %>"/>
<jsp:setProperty name="sqlLookupBean" property="passWord" value="<%= passWord %>"/>
</jsp:useBean>