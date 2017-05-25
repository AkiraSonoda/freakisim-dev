package org.akisim.ownerfix;

import static org.junit.Assert.*;

import javax.xml.xpath.XPathExpressionException;

import org.junit.Before;
import org.junit.Test;

public class XmlDaoTest {
	private XMLDao xmlDao = null;

	@Before
	public void initialize() throws Exception {
		xmlDao = new XMLDao("data/region.xml");
		
	}
	
	// OwnerID in SceneObjectParts
	@Test 
	public void testSearchOwnerIDInSceneObjectPart() throws XPathExpressionException {
		String ownerId = xmlDao.searchOwnerIDInSceneObjectPart("70fdc43d-65f0-4baa-a5ca-b9fdec449cbb");
		assertTrue(ownerId.equals("4110af95-ef10-4e2e-870c-0aa4c8e787f7"));
	}
	
	@Test 
	public void testSearchOwnerIDInSceneObjectPartEmpty() throws XPathExpressionException {
		String ownerId = xmlDao.searchOwnerIDInSceneObjectPart("70fdc43d-65f0-4baa-a5ca-b9fdec449cbc");
		assertTrue(ownerId.isEmpty());
	}

	// OwnerID in OteherParts SceneObjectParts
	@Test
	public void testSearchOwnerIDInOtherPartsSceneObjectPart() throws XPathExpressionException {
		String ownerId = xmlDao.searchOwnerIDOtherPartsInSceneObjectPart("2f080270-935b-44cd-963b-5ca9b70fcc8c");
		assertTrue(ownerId.equals("489508ef-0e4c-4ee5-9e47-4c97dc5bbcd7"));
	}
	@Test
	public void testSearchOwnerIDInOtherPartsSceneObjectPartEmpty() throws XPathExpressionException {
		String ownerId = xmlDao.searchOwnerIDOtherPartsInSceneObjectPart("2f080270-935b-44cd-963b-5ca9b70fcc8d");
		assertTrue(ownerId.isEmpty());
	}

	// LastOwnerId in SceneObjectParts	
	@Test 
	public void testSearchLastOwnerIDInSceneObjectPart() throws XPathExpressionException {
		String ownerId = xmlDao.searchLastOwnerIDInSceneObjectPart("70fdc43d-65f0-4baa-a5ca-b9fdec449cbb");
		assertTrue(ownerId.equals("4110af95-ef10-4e2e-870c-0aa4c8e787f7"));
	}
	
	@Test 
	public void testSearchLastOwnerIDInSceneObjectPartEmpty() throws XPathExpressionException {
		String ownerId = xmlDao.searchOwnerIDInSceneObjectPart("70fdc43d-65f0-4baa-a5ca-b9fdec449cbc");
		assertTrue(ownerId.isEmpty());
	}

	// LastOwnerId in OtherParts SceneObjectParts
	@Test 
	public void testSearchLastOwnerIDInOtherPartsSceneObjectPart() throws XPathExpressionException {
		String ownerId = xmlDao.searchLastOwnerIDOtherPartsInSceneObjectPart("2f080270-935b-44cd-963b-5ca9b70fcc8c");
		assertTrue(ownerId.equals("489508ef-0e4c-4ee5-9e47-4c97dc5bbcd7"));
	}
	
	@Test 
	public void testSearchLastOwnerIDInOtherPartsSceneObjectPartEmpty() throws XPathExpressionException {
		String ownerId = xmlDao.searchLastOwnerIDOtherPartsInSceneObjectPart("2f080270-935b-44cd-963b-5ca9b70fcc8d");
		assertTrue(ownerId.isEmpty());
	}
	
}
