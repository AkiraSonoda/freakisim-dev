package org.akisim.ownerfix;

import java.io.FileInputStream;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;



public class XMLDao {
	final Logger log = LoggerFactory.getLogger(OwnerFix.class);
	
	DocumentBuilderFactory documentBuilderFactory = null;
	DocumentBuilder documentBuilder = null;
	Document document = null;
	XPath xPath = XPathFactory.newInstance().newXPath();
	
	public XMLDao(String xmlFilePath) {
		super();
		DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
		
		try {
			
			documentBuilder = documentBuilderFactory.newDocumentBuilder();
			document = documentBuilder.parse(
					new FileInputStream(xmlFilePath));
			
		} catch (ParserConfigurationException e) {
			e.printStackTrace();
		} catch (SAXException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public String searchOwnerIDInSceneObjectPart(String uuid) throws XPathExpressionException {

		String expression = "/scene/SceneObjectGroup/SceneObjectPart[UUID/UUID='"+uuid+"']/OwnerID/UUID";
		String owenerId = xPath.compile(expression).evaluate(document).trim();
		log.debug("OwnerId: {}", owenerId);
		return(owenerId);
	}

	public String searchOwnerIDOtherPartsInSceneObjectPart(String uuid) throws XPathExpressionException {

		String expression = "/scene/SceneObjectGroup/OtherParts/SceneObjectPart[UUID/UUID='"+uuid+"']/OwnerID/UUID";
		String owenerId = xPath.compile(expression).evaluate(document).trim();
		log.debug("OwnerId: {}", owenerId);
		return(owenerId);
	}
	
	
	public String searchLastOwnerIDInSceneObjectPart(String uuid) throws XPathExpressionException {

		String expression = "/scene/SceneObjectGroup/SceneObjectPart[UUID/UUID='"+uuid+"']/LastOwnerID/UUID";
		String owenerId = xPath.compile(expression).evaluate(document).trim();
		log.debug("LastOwnerId: {}", owenerId);
		return(owenerId);
	}

	public String searchLastOwnerIDOtherPartsInSceneObjectPart(String uuid) throws XPathExpressionException {

		String expression = "/scene/SceneObjectGroup/OtherParts/SceneObjectPart[UUID/UUID='"+uuid+"']/LastOwnerID/UUID";
		String owenerId = xPath.compile(expression).evaluate(document).trim();
		log.debug("LastOwnerId: {}", owenerId);
		return(owenerId);
	}
	
}
