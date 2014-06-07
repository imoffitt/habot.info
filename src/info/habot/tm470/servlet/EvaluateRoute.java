package info.habot.tm470.servlet;

import info.habot.tm470.dao.drools.RouteDetermination;
import info.habot.tm470.dao.pojo.StrategicEvent;

import javax.servlet.http.HttpServletRequest;

public class EvaluateRoute {

	public EvaluateRoute() {

	}

	/**
	 * @param request
	 */
	static public StringBuffer evaluateRoute(HttpServletRequest request) {

		StringBuffer sb = new StringBuffer();

		StrategicEvent strategicEvent = new StrategicEvent();
		
		strategicEvent.setEvent_type((String) request
				.getParameter("lstIncidentType"));
		strategicEvent.setLink_id(new Integer(request.getParameter("LinkId"))
				.intValue());
		strategicEvent.setCapacity_reduction(new Float(request
				.getParameter("capacityReduction")).floatValue());
		strategicEvent.setDateCreated((String) request
				.getParameter("derivedDate"));

		RouteDetermination routeDetermination = new RouteDetermination();

		try {
			strategicEvent = routeDetermination.evaluateRoute(strategicEvent);

			sb.append("<isAlternativeValid>"
					+ strategicEvent.getAlternativeRoute().getIs_valid()
					+ "</isAlternativeValid>");

			sb.append("<AlternativeRoute>"
					+ routeDetermination
							.getAlternativeRouteExplantion(strategicEvent
									.getAlternativeRoute())
					+ "</AlternativeRoute>");
			sb.append("<DefaultLocationSuitable>"
					+ routeDetermination
							.getDefaultRouteExplantion(strategicEvent
									.getDefaultRoute())
					+ "</DefaultLocationSuitable>");

			sb.append(routeDetermination
					.getVMSEquipmentBeforeDecisionPoint(strategicEvent));

			sb.append(routeDetermination.getExplantion());
		} catch (Exception ex) {
			sb.append("<Exception>" + ex.getMessage() + "</Exception>");
		}

		return sb;
	}
}
