package org.akisim.ownerfix;

import static org.junit.Assert.fail;
import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

public class MySqlDaoTest {
	private MySQLDao mysqlDao = null;
	
	@Before
	public void initialize() throws Exception {
		mysqlDao = new MySQLDao("db.docker", "akisim", "akisim", "akisim");
	}
	
	@Test
	public void testGetAllPrims(){ 
		try {
			List<PrimDto> prims = mysqlDao.getPrims("akisim.prims");
			assertTrue(prims.size() == 10259);
		} catch (Exception ex) {
			fail("Test Failed because of exception: " + ex.getMessage());
			ex.printStackTrace();
		}
	}

}
