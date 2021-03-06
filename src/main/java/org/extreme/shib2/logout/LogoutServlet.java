package org.extreme.shib2.logout;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

//import javax.servlet.ServletConfig;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.opensaml.util.storage.StorageService;
import org.opensaml.xml.util.DatatypeHelper;
import org.opensaml.xml.util.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import edu.internet2.middleware.shibboleth.common.session.SessionManager;
import edu.internet2.middleware.shibboleth.idp.authn.AuthenticationEngine;
import edu.internet2.middleware.shibboleth.idp.authn.LoginContextEntry;
import edu.internet2.middleware.shibboleth.idp.session.ServiceInformation;
import edu.internet2.middleware.shibboleth.idp.session.Session;
import edu.internet2.middleware.shibboleth.idp.util.HttpServletHelper;

public class LogoutServlet extends HttpServlet {

    /** Serial version UID. */
    private static final long serialVersionUID = 8576568847170155493L;

    /** Class logger. */
    private final Logger log = LoggerFactory.getLogger(LogoutServlet.class);
	
    /** init-param which can be passed to the servlet to override the default logout page. */
    private final String logoutPageInitParam = "logoutPage";

    /** init-param which can be passed to the servlet to override the default post-logout page. */
    private final String logoutDonePageInitParam = "logoutDonePage";

    /** Logout page name. */
    private String logoutPage = "xlogout.jsp";

    /** PostLogout page name. */
    private String logoutDonePage = "xlogout-done.jsp";

    private final String logoutAttribute = "j_logout";
	
    private static ServletContext context;
	
    /** Session manager. */
    private SessionManager<Session> sessionManager;

    /** {@inheritDoc} */
    public void init(ServletConfig config) throws ServletException {
        super.init(config);

        if (getInitParameter(logoutPageInitParam) != null) {
            logoutPage = getInitParameter(logoutPageInitParam);
            log.debug("Setting logoutPage from init-parameter.");
        }
        if (getInitParameter(logoutDonePageInitParam) != null) {
            logoutDonePage = getInitParameter(logoutDonePageInitParam);
            log.debug("Setting logoutDonePage from init-parameter.");
        }

        context = config.getServletContext();
        sessionManager = HttpServletHelper.getSessionManager(context);
    }
	
    /** {@inheritDoc} */
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException,
            IOException {

        log.debug("Begin shib2logout servlet");
        String principalName = "";
        String logout = null;
        Session session = HttpServletHelper.getUserSession(request);

        if (session != null) {
            logout = request.getParameter(logoutAttribute);
            principalName = session.getPrincipalName();
        } 

        if (logout == null || session == null) {
            redirectToLogoutPage(request, response, null);
            return;
        }

    	// delete session cookie
        Cookie cookie = new Cookie("_idp_session", "");
        cookie.setMaxAge(0);
        cookie.setPath("/idp");
        response.addCookie(cookie);

        // destroy session
        String sid = session.getSessionID();
        if(session!=null) sessionManager.destroySession(session.getSessionID());
        log.info("Destroyed session {} for {}" , sid, principalName);
        redirectToLogoutDonePage(request, response, null);
    }

    /**
     * Show logout page.
     * @param request
     * @param response
     * @param queryParams
     */
    protected void redirectToLogoutPage(HttpServletRequest request, HttpServletResponse response,
            List<Pair<String, String>> queryParams) {

        String requestContext = DatatypeHelper.safeTrimOrNullString(request.getContextPath());
        if (requestContext == null) {
            requestContext = "/";
        }
        request.setAttribute("actionUrl", requestContext + request.getServletPath());

        if (queryParams != null) {
            for (Pair<String, String> param : queryParams) {
                request.setAttribute(param.getFirst(), param.getSecond());
            }
        }

        try {
            request.getRequestDispatcher(logoutPage).forward(request, response);
            log.debug("Redirecting to logout page {}", logoutPage);
        } catch (IOException ex) {
            log.error("Unable to redirect to logout page.", ex);
        } catch (ServletException ex) {
            log.error("Unable to redirect to logout page.", ex);
        }
    }

    
    /**
     * Show logout success page.
     * @param request
     * @param response
     * @param queryParams
     */
    protected void redirectToLogoutDonePage(HttpServletRequest request, HttpServletResponse response,
            List<Pair<String, String>> queryParams) {
        try {
            request.getRequestDispatcher(logoutDonePage).forward(request, response);
            log.debug("Redirecting to logoutDone page {}", logoutDonePage);
        } catch (IOException ex) {
            log.error("Unable to redirect to logoutDone page.", ex);
        } catch (ServletException ex) {
            log.error("Unable to redirect to logoutDone page.", ex);
        }
    }
	
}
