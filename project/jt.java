import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

// don’t forget to set up your classpath. 
// export CLASSPATH=/opt/mysql/mysql-connector-java-5.1.45-bin.jar:$CLASSPATH

// don’t forget that you need Procedures in your database 
class project {
    public static Connection makeConnection(String port, String database, String password) {
        try {
            Connection conn = null;
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:" + port+ "/" + database+
                    "?verifyServerCertificate=false&useSSL=true", "msandbox",
                    password);
            // Do something with the Connection
            System.out.println("Database " + database +" connection succeeded!");
            System.out.println();
            return conn;
        } catch (SQLException ex) {
            // handle any errors
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
        }
        return null;
    }

    public static void runGetClassesWithNoStudents(Connection conn) {

        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.prepareStatement("call GetClassesWithNoStudents()");
            rs = stmt.executeQuery();
            // Now do something with the ResultSet ....
            boolean rowsLeft = true;
            rs.beforeFirst();
            while (rs.next()) {
                System.out.println(rs.getInt(1) 
                        + ":" + rs.getString(2) 
                        + ":" + rs.getString(3) 
                        + ":" + rs.getString(4)
                        + ":" + rs.getString(5)
                        + ":" + rs.getString(6)
                        + ":" + rs.getString(7)
                        + ":" + rs.getString(8));
            }
        } catch (SQLException ex) {
            // handle any errors
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
        } finally {
            // it is a good idea to release resources in a finally{} block
            // in reverse-order of their creation if they are no-longer needed
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                } // ignore
                rs = null;
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                } // ignore
                stmt = null;
            }
        }
    }

	/**
	 * This method is my own, from Assignment 6, which deals
	 * with getting the student count of a class given a 
	 * particular class code
	 *
	 * @param conn, code
	 * needs both a connection and code with which to know what
	 * connection to use, and what code to search with
	 */
	public static void runGetClassStudentCountByCode(Connection conn, String code) {

		PreparedStatement stmt = null;
		ResultSet rs = null;

		// Attempt to run the stored procedure in the database
		try {
			stmt = conn.prepareStatement("call GetClassStudentCountByCode(?)");
			stmt.setString(1, code);
			rs = stmt.executeQuery();

			// Print out the result
			rs.beforeFirst();
			while (rs.next()) {
				System.out.println("Number of students in " + code + " is: " + rs.getInt(1));
			}
		} catch (SQLException ex) {
			// handle errors
			System.err.println("SQLException: " + ex.getMessage());
			System.err.println("SQLState: " + ex.getSQLState());
			System.err.println("VendorError: " + ex.getErrorCode());
		} finally {
			// Release resources in reverse order of creation
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException sqlEx) {
				} //ignore
				rs = null;
			}
			if (stmt != null) {
				try {
					stmt.close();
				} catch (SQLException sqlEx) {
				} //ignore
				stmt = null;
			}
		}
	}

    public static void runGetClassStudentsByCode(Connection conn, String code) {

        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.prepareStatement("call GetClassStudentsByCode(?)");
            stmt.setString(1, code);
            rs = stmt.executeQuery();
            // Now do something with the ResultSet ....
            
            rs.beforeFirst();
            while (rs.next()) {
                System.out.println(rs.getInt(1) 
                        + ":" + rs.getString(2) 
                        + ":" + rs.getString(3) 
                        );
            }
        } catch (SQLException ex) {
            // handle any errors
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
        } finally {
            // it is a good idea to release resources in a finally{} block
            // in reverse-order of their creation if they are no-longer needed
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                } // ignore
                rs = null;
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                } // ignore
                stmt = null;
            }
        }
    }

    public static void runQuery(Connection conn) {

        Statement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM Student Limit 1;");
            // Now do something with the ResultSet ....
            
            rs.beforeFirst();
            while (rs.next()) {
                System.out.println(rs.getInt(1) 
                        + ":" + rs.getString(2) 
                        + ":" + rs.getString(3) 
                        + ":" + rs.getString(4)
                        + ":" + rs.getString(5));
            }
        } catch (SQLException ex) {
            // handle any errors
            System.err.println("SQLException: " + ex.getMessage());
            System.err.println("SQLState: " + ex.getSQLState());
            System.err.println("VendorError: " + ex.getErrorCode());
        } finally {
            // it is a good idea to release resources in a finally{} block
            // in reverse-order of their creation if they are no-longer needed
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                } // ignore
                rs = null;
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                } // ignore
                stmt = null;
            }
        }
    }

    public static void main(String[] args) {
        try {
            // The newInstance() call is a work around for some broken Java implementations
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            System.out.println();
            System.out.println("JDBC driver loaded");
            System.out.println();
            if (args[0] == "/?" || (args.length <4)){
              System.out.println ("Usage :   GetClassesWithNoStudents   port dbname password");
              System.out.println ("Usage :   GetClassStudentsByCode     port dbname password code");
			  System.out.println ("Usage :   GetClassStudentCountByCode port dbname password code");
              System.out.println ("Usage :   test    port dbname password");
              return;
            }
            else {
                System.out.println(args[0]);
                System.out.println(args[1]);
                System.out.println(args[2]);
                System.out.println("**");

                if (args.length == 5)
                {
                    System.out.println(args[4]);
                }
            }

            Connection conn = makeConnection(args[1], args[2],args[3]);

            if (args.length == 5)
            {
				if (args[0].equals("GetClassStudentsByCode")) {
	                System.out.println("Running GetClassStudentByCode");
		            runGetClassStudentsByCode(conn, args[4]);    
				} else {
					System.out.println("Running GetClassStudentCountByCode");
					runGetClassStudentCountByCode(conn, args[4]);
				}
            }
            else if (args[0].equals( "GetClassesWithNoStudents") ){
                System.out.println("Running GetClassesWithNoStudents");
                runGetClassesWithNoStudents(conn);
            }
            else if (args[0].equals( "test") ){
                 System.out.println("Running test");
                runQuery(conn);
            }
            else {
                System.out.println("No process requested");
            }
            conn.close();
            System.out.println();
            System.out.println("Database " +  args [2] + " connection closed");
            System.out.println();
        } catch (Exception ex) {
            // handle the error
            System.err.println(ex);
        }
    }
}

