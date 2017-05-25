package org.akisim.ownerfix;

import java.sql.SQLException;
import java.util.List;

import javax.xml.xpath.XPathExpressionException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DbFix {
	final Logger log = LoggerFactory.getLogger(OwnerFix.class);

	private String host = null; 
	private String database = null;
	private String user = null;
	private String password = null;
	private String xmlFilePath = null;
	private MySQLDao mysqlDao = null;
	private XMLDao xmlDao = null;
	private List<PrimDto> primDtoList = null;
	
	public DbFix(String host, String database, String user, String password, String xmlFilePath) {
		super();
		this.host = host;
		this.database = database;
		this.user = user;
		this.password = password;
		this.xmlFilePath = xmlFilePath;
	}
	
	public void initialize() throws Exception {
		mysqlDao = new MySQLDao(host, database, user, password);
		xmlDao = new XMLDao(xmlFilePath);			
	}
	
	public void fixPrimDatabase() {
		try {
			primDtoList = mysqlDao.getPrims(database +".prims");
			String ownerId = null;
			String lastOwnerId = null;
			for (PrimDto primDto : primDtoList) {
				// Process the OwnerID
				ownerId = xmlDao.searchOwnerIDInSceneObjectPart(primDto.dbPrimUUID);
				if(ownerId.isEmpty()) {
					ownerId = xmlDao.searchOwnerIDOtherPartsInSceneObjectPart(primDto.dbPrimUUID);
					if(ownerId.isEmpty()) {
						log.warn("Prim {} not found in XML", primDto.dbPrimUUID);
					} else {
						primDto.setXmlOwnerUUID(ownerId);
						primDto.isFoundInXml = true;						
					}
				} else {
					primDto.setXmlOwnerUUID(ownerId);
					primDto.isFoundInXml = true;
				}
				
				// Process the LastOwnerID
				lastOwnerId = xmlDao.searchLastOwnerIDInSceneObjectPart(primDto.dbPrimUUID);
				if(lastOwnerId.isEmpty()) {
					lastOwnerId = xmlDao.searchLastOwnerIDOtherPartsInSceneObjectPart(primDto.dbPrimUUID);
					if(lastOwnerId.isEmpty()) {
						log.warn("Prim {} not found in XML", primDto.dbPrimUUID);
					} else {
						primDto.setXmlLastOwnerUUID(lastOwnerId);
					}
				} else {
					primDto.setXmlLastOwnerUUID(lastOwnerId);
				}
			
			}
		} catch (SQLException ex) {
			log.error("SQLException: ", ex);
		} catch (XPathExpressionException ex) {
			log.error("XPathExpressionException: ", ex);
		}
		
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		for (PrimDto primDto : primDtoList) {
			sb.append("isFoundInXml: ");
			sb.append(primDto.isFoundInXml);
			sb.append(" isOwnerIdDifferent: ");
			sb.append(primDto.isOwnerIdDifferent);
			sb.append(" isLastOwnerIdDifferent: ");
			sb.append(primDto.isLastOwnerIdDifferent);
			sb.append(" dbSceneGroupUUID: ");
			sb.append(primDto.dbSceneGroupUUID);
			sb.append(" dbPrimUUID: ");
			sb.append(primDto.dbPrimUUID);
			sb.append(System.lineSeparator());
		}
		
		return sb.toString();
	}
	
	
}
