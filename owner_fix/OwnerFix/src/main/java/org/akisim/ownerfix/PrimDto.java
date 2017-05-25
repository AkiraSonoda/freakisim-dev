package org.akisim.ownerfix;


public class PrimDto {
	
	// Values to identify the prim properly
	public String dbPrimUUID = "00000000-0000-0000-0000-000000000000";
	public String dbSceneGroupUUID = "00000000-0000-0000-0000-000000000000";
	
	// Values retrieved from Database
	public String dbOwnerUUID = "00000000-0000-0000-0000-000000000000";
	public String dbLastOwnerUUID = "00000000-0000-0000-0000-000000000000";
	
	// Values retrieved from XML 
	private String xmlOwnerUUID = "00000000-0000-0000-0000-000000000000";
	private String xmlLastOwnerUUID = "00000000-0000-0000-0000-000000000000";

	public boolean isFoundInXml = false;
	public boolean isOwnerIdDifferent = false;
	public boolean isLastOwnerIdDifferent = false;
	
	public String getXmlOwnerUUID() {
		return xmlOwnerUUID;
	}
	
	public void setXmlOwnerUUID(String xmlOwnerUUID) {
		this.xmlOwnerUUID = xmlOwnerUUID;
		if(!xmlOwnerUUID.equals(dbOwnerUUID)) {
			isOwnerIdDifferent = true;
		} else {
			isOwnerIdDifferent = false;		
		}
	}
	
	public String getXmlLastOwnerUUID() {
		return xmlLastOwnerUUID;
	}
	
	public void setXmlLastOwnerUUID(String xmlLastOwnerUUID) {
		this.xmlLastOwnerUUID = xmlLastOwnerUUID;
		if(!xmlLastOwnerUUID.equals(dbLastOwnerUUID)) {
			isLastOwnerIdDifferent = true;			
		} else {
			isLastOwnerIdDifferent = false;						
		}
	}
	
}
