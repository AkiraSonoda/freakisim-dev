package org.akisim.ownerfix;

import java.util.UUID;

public class PrimDto {
	
	// Values to identify the prim properly
	public UUID dbPrimUUID = UUID.fromString("00000000-0000-0000-0000-000000000000");
	public UUID dbSceneGroupUUID = UUID.fromString("00000000-0000-0000-0000-000000000000");
	
	// Values retrieved from Database
	public UUID dbOwnerUUID = UUID.fromString("00000000-0000-0000-0000-000000000000");
	public UUID dbLastOwnerUUID = UUID.fromString("00000000-0000-0000-0000-000000000000");
	
	// Values retrieved from XML 
	public UUID xmlOwnerUUID = UUID.fromString("00000000-0000-0000-0000-000000000000");
	public UUID xmlLastOwnerUUID = UUID.fromString("00000000-0000-0000-0000-000000000000");

}
