package org.akisim.ownerfix;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * OwnerFix
 *
 */
public class OwnerFix {
	
	public static void main(String[] args) {
		final Logger log = LoggerFactory.getLogger(OwnerFix.class);
		String host = args[0]; 
		String database = args[1];
		String user = args[2];
		String password = args[3];
		String xmlFilePath = args[4];

		log.info("Starting OwnerFix");
		DbFix dbFix = new DbFix(host, database, user, password, xmlFilePath);
		try {
			dbFix.initialize();
			dbFix.fixPrimDatabase();
			dbFix.toString();
		} catch (Exception ex) {
			log.error("Exception in OwnerFix: ", ex);
		}
	}
}
