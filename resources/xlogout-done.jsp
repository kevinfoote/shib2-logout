<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.authn.LoginContext" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.authn.LoginHandler" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.session.*" %>
<%@ page import="edu.internet2.middleware.shibboleth.idp.util.HttpServletHelper" %>
<%@ page import="org.opensaml.saml2.metadata.*" %>
<%@ page import="javax.servlet.http.Cookie" %>
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

			if(!currentUser.equals("")) { %>
				<p>Your session as user &quot;<%=currentUser%>&quot;
				has been destroyed.</p>
				<p><strong>Caution:</strong> If you do not quit your web browser, you may remain
                                logged in at any of the web applications you invoked before.
				<% if(userSession.getServicesInformation().size() > 0) { %>
					These were the web applications you used during your session:</p>
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
					</p>
				<% } %>
			<% } else { %>
				<p>Your session has been destroyed.</p>
			<% } %>

			<p><strong>Please Note:</strong></p>
			<ul>
                                <li><p>To completely log out, you must now exit your Web browser.</p></li>
                                <li><p>You may still be able to visit your previously accessed web applications without having to log in again.</p></li>
			</ul>
		<%}%>

</body>
</html>

