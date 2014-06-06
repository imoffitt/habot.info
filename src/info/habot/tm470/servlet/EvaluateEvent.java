package info.habot.tm470.servlet;

import java.text.SimpleDateFormat;
import java.util.Date;

import info.habot.tm470.dao.drools.EventSuitability;
import info.habot.tm470.dao.drools.RouteDetermination;
import info.habot.tm470.dao.pojo.StrategicEvent;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;

/**
 * EvaluateEvent - Where information from the operator is evaluated using rules
 * and the results returned to the UI
 * 
 * @author Ian Moffitt
 * @version 0.1
 * @see www.habot.info
 */
public class EvaluateEvent {

	private static final Logger log = Logger.getLogger(EvaluateEvent.class
			.getName());

	static final boolean lowMemory = false;

	public EvaluateEvent() {

	}

	/**
	 * @param request
	 */
	static public StringBuffer evaluateEvent(HttpServletRequest request) {

		// 2014-05-03 00:00:00
		final SimpleDateFormat simpleDateFormat = new SimpleDateFormat("2014-01-17 HH:mm:ss");
		Date now = new Date();
		
		StringBuffer sb = new StringBuffer();

		StrategicEvent strategicEvent = new StrategicEvent();

		strategicEvent.setEvent_type((String) request
				.getParameter("lstIncidentType"));
		strategicEvent.setLink_id(new Integer(request.getParameter("linkId"))
				.intValue());
		strategicEvent.setCapacity_reduction(new Float(request
				.getParameter("capacityReduction")).floatValue());
		
		strategicEvent.setDateCreated(simpleDateFormat.format(now));
	
		log.debug ("SE=" + strategicEvent.toString());
		

		EventSuitability eventSuitability = new EventSuitability();

		try {
			strategicEvent = eventSuitability
					.evaluateStrategicEvent(strategicEvent);
		} catch (Exception ex) {
			log.error("EventSuitability : " + ex.getMessage());
			sb.append("<error3>" + ex.getStackTrace() + "</error3>");
			log.debug ("SE=" + strategicEvent.toString());
		}

		try {
			sb.append("<eventSubType>" + strategicEvent.getEvent_sub_type()
					+ "</eventSubType>");
			sb.append("<eventAlternativeRoute>"
					+ strategicEvent.isConsider_alternative_route()
					+ "</eventAlternativeRoute>");
			sb.append("<eventLocationSuitable>"
					+ strategicEvent.isLocation_suitable()
					+ "</eventLocationSuitable>");
			sb.append("<eventSeveritySuitable>"
					+ strategicEvent.isSeverity_suitable()
					+ "</eventSeveritySuitable>");
			sb.append("<eventTypeSuitable>" + strategicEvent.isType_suitable()
					+ "</eventTypeSuitable>");

		} catch (Exception ex) {
			log.error("EventSuitability : " + ex.getMessage());
			sb.append("<error4>" + ex.getMessage() + "</error4>");
		}

		RouteDetermination routeDetermination = new RouteDetermination();

		if (lowMemory) {
			// This is a fudge to overcome the out of memory error on server
			sb.append(routeDetermination.getDefaultA556XML(strategicEvent));

			sb.append(routeDetermination
					.getVMSEquipmentBeforeDecisionPoint(strategicEvent));

			sb.append(eventSuitability.getExplantion());
		} else {
			try {
				strategicEvent = routeDetermination
						.evaluateRoute(strategicEvent);

				if (strategicEvent.getAlternativeRoute() != null) {
					sb.append("<isAlternativeValid>"
							+ strategicEvent.getAlternativeRoute()
									.getIs_valid() + "</isAlternativeValid>");
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

					sb.append(eventSuitability.getExplantion());
				} else {
					log.error("EventSuitability : strategicEvent.getAlternativeRoute() is null");
					sb.append("<error4>strategicEvent.getAlternativeRoute() is null</error4>");
				}

			} catch (Exception ex) {
				log.error("EventSuitability : " + ex.getMessage());
				sb.append("<error5>" + ex.getMessage() + "</error5>");
			}
		}

		return sb;
	}
}
