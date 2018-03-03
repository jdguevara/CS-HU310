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

    public static void runGetItems(Connection conn, String code) {
    	PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.prepareStatement("call GetItems(?)");
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
    public static void runItemsAvailable(Connection conn, String code) {

        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.prepareStatement("call ItemsAvailable(?)");
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
            rs = stmt.executeQuery("SELECT * FROM Item Limit 1;");
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
            if (args[0] == "/?" || (args.length < 1)){
              System.out.println ("Usage :   GetItems code");
              System.out.println ("Usage :   ItemsAvailable code");
              System.out.println ("Usage :   test");
              return;
            }
            else {
                System.out.println(args[0]);
                System.out.println(args[1]);

            }

            Connection conn = makeConnection("5739", "cs310project","SolidDonut_93");

            if (args[0].equals("GetItems"))
            {
                 System.out.println("Running GetItems");
                runGetItems(conn, args[1]);    
            }
            else if (args[0].equals( "ItemsAvailable") ){
                System.out.println("Running ItemsAvailable");
                runItemsAvailable(conn, args[1]);
            }
            else if (args[0].equals( "test") ){
                 System.out.println("Running test");
                runQuery(conn);
            }
            else {
                System.out.println("No proces requested");
            }
            conn.close();
            System.out.println();
            System.out.println("Database cs310project connection closed");
            System.out.println();
        } catch (Exception ex) {
            // handle the error
            System.err.println(ex);
        }
    }
}

