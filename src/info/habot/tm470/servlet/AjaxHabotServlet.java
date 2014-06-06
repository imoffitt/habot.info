package info.habot.tm470.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import info.habot.tm470.dao.FusedSensorDataImpl;
import info.habot.tm470.dao.SqlLookupBean;
import info.habot.tm470.dao.pojo.FusedSensorData;

/**
* AjaxHabotServlet for returning xml data to the jsp pages.
* 
* @author Ian Moffitt
* @version 0.1
* @see www.habot.info
*/
public class AjaxHabotServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final Logger log = Logger.getLogger(AjaxHabotServlet.class
			.getName());

	private ServletContext context;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public AjaxHabotServlet() {
		super();
	}

	@Override
	public void init(ServletConfig config) throws ServletException {
		this.context = config.getServletContext();
	}

	/**
	 * @see Servlet#getServletConfig()
	 */
	public ServletConfig getServletConfig() {
		return null;
	}

	/**
	 * @see Servlet#getServletInfo()
	 */
	public String getServletInfo() {
		return null;
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	@SuppressWarnings("unused")
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		response.setContentType("text/html;charset=UTF-8");

		log.debug("HttpServletRequest");

		String action = request.getParameter("action");
		String roadName = request.getParameter("roadName");
		String roadDirection = request.getParameter("direction");

		log.debug("action=" + action);
//		log.debug("roadName=" + roadName);
//		log.debug("roadDirection=" + roadDirection);

		ApplicationContext applicationContext = new ClassPathXmlApplicationContext(
				"Beans.xml");

		log.debug("context=" + context);
		
		if (action == null) {
			action = "direction";
		}

		if (applicationContext != null) {

			if (action != null) {
				StringBuffer sb = new StringBuffer();

				/*
				 * AjaxHabot?action=direction&roadName=M6
				 * AjaxHabot?action=location&roadName=M6&direction=northbound
				 */
				if (action.equals("direction") || (action.equals("location"))) {

					SqlLookupBean lookupBeanDao = (SqlLookupBean) applicationContext
							.getBean("sqlLookupBean");

					DataSource dataSource = (DataSource) applicationContext
							.getBean("dataSource");

					lookupBeanDao.setDataSource(dataSource);

					if (action.equals("direction")) {
						sb = getDirectionXML(lookupBeanDao, roadName);
					} else {
						sb = getLocationXML(lookupBeanDao, roadName,
								roadDirection);
					}
				} else if (action.equals("traffic")) {
					sb = getTrafficDataXML(applicationContext,
							request.getParameter("linkId"),
							request.getParameter("derivedDate"));
				}  else if (action.equals("evaluateEvent")) {
					sb = EvaluateEvent.evaluateEvent(request);
				}  else if (action.equals("evaluateRoute")) {
					sb = EvaluateRoute.evaluateRoute(request);
				}
				
				if (sb == null) {
					response.setStatus(HttpServletResponse.SC_NO_CONTENT);
				} else {
					response.setContentType("text/xml");
					response.setHeader("Cache-Control", "no-cache");
					response.getWriter().write("<" + action + ">" + sb.toString()
							+ "</" + action + ">");
				}
			} else {
				log.debug("action is null");
			}
		} else {
			log.debug("ApplicationContext is null");
		}
	}

	/**
	 * @param lookupBeanDao
	 * @param roadName
	 * @return
	 */
	private StringBuffer getDirectionXML(SqlLookupBean lookupBeanDao,
			String roadName) {

		StringBuffer sb = new StringBuffer();
		ArrayList<Map<String, Object>> lstRoadDirections = lookupBeanDao
				.getValue("select distinct directionBound from Network_Links where roadNumber = '"
						+ roadName + "' order by directionBound");
		
		if (!lstRoadDirections.isEmpty()) {
			for (Map<String, Object> roadIter : lstRoadDirections) {

				sb.append("<roadDirection>" + roadIter.get("directionBound")
						+ "</roadDirection>");
			}
		}

		return sb;
	}

	/**
	 * @param lookupBeanDao
	 * @param roadName
	 * @param roadDirection
	 * @return
	 */
	private StringBuffer getLocationXML(SqlLookupBean lookupBeanDao,
			String roadName, String roadDirection) {

		StringBuffer sb = new StringBuffer();
		ArrayList<Map<String, Object>> lstRoadLocations = lookupBeanDao
				.getValue("select locationName, linkId from Network_Links where roadNumber = '"
						+ roadName
						+ "' and directionBound = '"
						+ roadDirection
						+ "' group by locationName, linkId order by locationName, linkId");
		
		if (!lstRoadLocations.isEmpty()) {
			for (Map<String, Object> roadIter : lstRoadLocations) {

				sb.append("<roadLocation linkId=\"" + roadIter.get("linkId") + "\">" + roadIter.get("locationName")
						+ "</roadLocation>");
			}
		}

		return sb;
	}

	/**
	 * @param applicationContext
	 * @param linkId
	 * @param derivedDate
	 * @return
	 */
	private StringBuffer getTrafficDataXML(
			ApplicationContext applicationContext, String linkId,
			String derivedDate) {

		StringBuffer sb = new StringBuffer();

		log.debug("linkId=" + linkId);
		log.debug("derivedDate=" + derivedDate);

		FusedSensorDataImpl fusedSensorDataImpl = (FusedSensorDataImpl) applicationContext
				.getBean("fusedSensorImpl");

		if (linkId != null && derivedDate != null) {
			List<FusedSensorData> fusedSensorDataList = fusedSensorDataImpl
					.getFusedSensorData(new Integer(linkId).intValue(),
							derivedDate);

			log.debug("fusedSensorDataList=" + fusedSensorDataList.toString());

			if (!fusedSensorDataList.isEmpty()) {
				for (FusedSensorData roadIter : fusedSensorDataList) {

					sb.append("<fusedSensorData>");

					sb.append("<networkLinkId>" + roadIter.getNetworkLinkId()
							+ "</networkLinkId>");
					sb.append("<vehicleFlowRate>"
							+ roadIter.getVehicleFlowRate()
							+ "</vehicleFlowRate>");
					sb.append("<occupancyPercentage>"
							+ roadIter.getOccupancyPercentage()
							+ "</occupancyPercentage>");
					sb.append("<averageTimeHeadway>"
							+ roadIter.getAverageTimeHeadway()
							+ "</averageTimeHeadway>");
					sb.append("<averageVehicleSpeed>"
							+ roadIter.getAverageVehicleSpeed()
							+ "</averageVehicleSpeed>");
					sb.append("<travelTime>" + roadIter.getTravelTime()
							+ "</travelTime>");
					sb.append("<freeFlowTravelTime>"
							+ roadIter.getFreeFlowTravelTime()
							+ "</freeFlowTravelTime>");
					sb.append("<normallyExpectedTravelTime>"
							+ roadIter.getNormallyExpectedTravelTime()
							+ "</normallyExpectedTravelTime>");
					sb.append("<derivedTime>" + roadIter.getDerivedTime()
							+ "</derivedTime>");
					sb.append("</fusedSensorData>");
				}
			}
		}
		return sb;
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		doGet(request, response);
	}
}
