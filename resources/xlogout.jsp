<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.authn.LoginContext" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.authn.LoginHandler" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.session.*" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.util.HttpServletHelper" %>
<%@ page import="org.opensaml.saml2.metadata.*" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="org.extreme.shib2.logout.LogoutServlet" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.session.ServiceInformation" %>
<%@ page import="org.slf4j.Logger" %>
<%@ page import="org.slf4j.LoggerFactory" %>

<html><head><title>Logout from authentication service</title></head><body>
<%
    Logger log = LoggerFactory.getLogger(HttpServletHelper.class); 
    Session userSession = HttpServletHelper.getUserSession(request);
%>



		<% if (userSession == null) { %>
			<h1>Logout from authentication service</h1>
			<p>You are not logged in to the authentication service, or your session has expired.</p>
			<p>In order to perform a complete logout, <strong>please quit your web browser,</strong>
                        as otherwise you may remain logged in at any of the web applications you invoked before.
			</p>
		<% } else { %>

			<h1>Logout from authentication service</h1>

			<%
			String currentPrincipal = "";
			if (userSession!=null) {
				currentPrincipal = userSession.getPrincipalName();
			}
			

			String currentUser = currentPrincipal;

			%>
			<% if(!currentUser.equals("")) { %>
				<p>You are currently logged in as &quot;<%=currentUser%>&quot;
				.</p>
				<% if(userSession.getServicesInformation().size() > 0) { %>
					<p>During this session, you invoked the following web applications:</p>
					<ul>
					<% for(java.util.Map.Entry<String, ServiceInformation> entry : userSession.getServicesInformation().entrySet()) {
						String spId = entry.getValue().getEntityID();
						String spTitle = spId;
						String spUrl = spId;
						if(spId.indexOf("://")>=0) {
							spUrl = spId.substring(0,spId.indexOf("://")+3+spId.substring(spId.indexOf("://")+3).indexOf("/"));
						}
					 %>
						<li><a href="<%= spUrl %>" title="<%= spId %>" target="_blank"><%= spTitle %></a></li>
					<% } %>
					</ul>
				<% } else { %>
					
				<% } %>
				<p><strong>Caution:</strong> If you logout now, only your session at the authentication service
                                will be destroyed, and you cannot invoke additional web applications without re-authentication.
                                Please note that you may still be logged in at any of the web applications you invoked before!
				<strong>Due to technical reasons, you need to quit your web browser in order to complete the logout process.</strong></p>

				<p>Please click here to logout from the authentication service:</p>
				<form action="<%=request.getAttribute("actionUrl")%>" method="post" name="logoutform">
					<input name="j_logout" type="submit" value="Logout now"/>
				</form>
			<% } else { %>
				You are not logged in to the authentication service.<br /><br />
			<% } %>

		<%}%>

</body>
</html>

