package org.akisim.ownerfix;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;



public class MySQLDao {
	final Logger log = LoggerFactory.getLogger(OwnerFix.class);

	private Connection connection = null;
	private Statement statement = null;
	@SuppressWarnings("unused")
	private PreparedStatement preparedStatement = null;
	private ResultSet resultSet = null;
	
	
	public MySQLDao(String host, String database, String user, String password) throws Exception {
		super();
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			connection = DriverManager.getConnection(
					"jdbc:mysql://" + host
					+"/" + database
					+"?user=" + user
					+"&password=" + password
					);
		} catch (Exception ex) {
			throw ex;
		}
	}
	
	public List<PrimDto> getPrims(String tableName) throws SQLException {
		ArrayList<PrimDto> primList = new ArrayList<PrimDto>();
		statement = connection.createStatement();
		resultSet = statement.executeQuery("select * from "+tableName);
		
		if (log.isDebugEnabled()) {
			writeMetaData(resultSet);
		}
		
		while( resultSet.next() ) {
			PrimDto primDto = new PrimDto();
			primDto.dbSceneGroupUUID = resultSet.getString("SceneGroupID");
			primDto.dbPrimUUID = resultSet.getString("UUID");
			primDto.dbOwnerUUID = resultSet.getString("OwnerID");
			primDto.dbLastOwnerUUID = resultSet.getString("LastOwnerID");
			primList.add(primDto);
		}
		
		return primList;
	}

	private void writeMetaData(ResultSet resultSet) throws SQLException {
        log.debug("The columns in the table are: ");
        log.debug("Table: " + resultSet.getMetaData().getTableName(1));
        for  (int i = 1; i<= resultSet.getMetaData().getColumnCount(); i++){
            log.debug("Column " +i  + " "+ resultSet.getMetaData().getColumnName(i));
        }		
	}
	
}
