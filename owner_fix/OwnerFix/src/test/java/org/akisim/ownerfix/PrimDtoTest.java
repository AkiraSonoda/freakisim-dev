package org.akisim.ownerfix;

import static org.junit.Assert.*;

import org.junit.Test;

public class PrimDtoTest {

	@Test
	public void differentOwnerId() {
		PrimDto primDto = new PrimDto();
		primDto.setXmlOwnerUUID("d56d560b-536e-4f63-a1a3-8af4be8f0e6d");
		assertTrue(primDto.isOwnerIdDifferent == true);
	}

	@Test
	public void sameOwnerId() {
		PrimDto primDto = new PrimDto();
		primDto.dbOwnerUUID = "d56d560b-536e-4f63-a1a3-8af4be8f0e6d";
		primDto.setXmlOwnerUUID("d56d560b-536e-4f63-a1a3-8af4be8f0e6d");
		assertTrue(primDto.isOwnerIdDifferent == false);
	}
	
	
	@Test
	public void differentLastOwnerId() {
		PrimDto primDto = new PrimDto();
		primDto.setXmlLastOwnerUUID("d56d560b-536e-4f63-a1a3-8af4be8f0e6d");
		assertTrue(primDto.isLastOwnerIdDifferent == true);
	}

	@Test
	public void sameLastOwnerId() {
		PrimDto primDto = new PrimDto();
		primDto.dbLastOwnerUUID = "d56d560b-536e-4f63-a1a3-8af4be8f0e6d";
		primDto.setXmlLastOwnerUUID("d56d560b-536e-4f63-a1a3-8af4be8f0e6d");
		assertTrue(primDto.isLastOwnerIdDifferent == false);
	}
	
}
