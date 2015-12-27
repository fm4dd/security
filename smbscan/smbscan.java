/* -------------------------------------------------------------- *
 * smbscan.java v1.0 20151211 Frank4dd (http://fm4dd.com/), GPLv3 *
 *                                                                *
 * This program checks for reachable Windows network shares on    *
 * networked systems. Access to shares should be restricted, and  *
 * general access shouldn't be allowed (except if data is public).*
 *                                                                *
 * This program uses the jcifs libary (https://jcifs.samba.org/)  *
 * for SMB functions. It can check hosts in network ranges up to  *
 * class-C (e.g. x.y.z.1-254) by counting up the last octet.      *
 *                                                                *
 * Smbscan first checks if hosts are pingeable, and then tries to *
 * connect via tcp port 445. If successful, it lists up reachable *
 * shares together with directories if they are readable. Results *
 * are written into a file, the Optional parameter csv formats it *
 * for easy import into MS Excel.                                 *
 *                                                                *
 * Compile: javac -cp .:../dist/jcifs.jar smbscan.java            * 
 * -------------------------------------------------------------- */
import jcifs.smb.*;
import jcifs.util.*;
import jcifs.netbios.*;
import java.util.Date;
import java.io.*;
import java.net.*;

public class smbscan {
   static int csv = 0;
   static int wt = 0;
   static String separator = ",";
   static String hostline;
   static int ping_timeout = 1000;
   static int smb_timeout = 1000;

  /* ------------------------------------------------------------ *
   * Before checking for shares, we first ping the host to        *
   * ensure it exists. Otherwise, the smb check 'hangs' and waits *
   * with a long, hard to interrupt timeout. Our ping timeout is  *
   * set to 1 second only, providing a fast scan (ptimeout = 1;). *
   * ------------------------------------------------------------ */
  public static boolean ping(InetAddress inet, int timeout) throws IOException {
  
     /* Use ICMP ECHO REQUESTs if the privilege can be obtained,  *
      * otherwise try a TCP connection on port 7 (Echo) to dest.  *
      * args: null (any IF), 0 (ttl default), timeout (in msec)   */ 
    if(inet.isReachable(null, 0, timeout)) { 
      /* Success results output to console */
      System.out.print(" Ping: OK ");
      /* Success results output to file, txt or csv */
      if(csv==1) { hostline = hostline+"PING OK"+separator; }
      else       { hostline = hostline+" PING: OK "; }
      return true;
    }
    else { 
      /* Failure results output to console */
      System.out.println(" Ping: FAIL");
      /* Failure results output to file, txt or csv */
      if(csv==1) { hostline = hostline+"PING FAIL\n"; }
      else       { hostline = hostline+" PING: FAIL\n"; }
    }
    return false;
  }
  
  /* ------------------------------------------------------------ *
   * Check for port 445. The system may not be Windows, or may    *
   * not have any shares at all.                                  *
   * ------------------------------------------------------------ */
  public static boolean smbcheck(InetAddress inet, int timeout) throws IOException {

    /* Create a tcp stream socket and connect to     *
     * the port at the given IP. Returns IOException *
     * for connection failures. We use SMB port 445  */
    try { 
      Socket smbSocket = new Socket(inet, 445);
      smbSocket.setSoTimeout(timeout);
      /* Success results output to console */
      System.out.print("TCP-445: OK ");
      /* Success results output to file, txt or csv */
      if(csv==1) { hostline = hostline+"TCP-445 OK"+separator; }
      else       { hostline = hostline+"TCP-445: OK "; }
      smbSocket.close();
      return true;
    }
    catch (IOException e) { 
      /* Failure results output to console */
      System.out.println("TCP-445: FAIL");
      /* Failure results output to file, txt or csv */
      if(csv==1) { hostline = hostline+"TCP-445 FAIL\n"; }
      else       { hostline = hostline+"TCP-445: FAIL\n"; }
      return false;
    }
  }
  
  /* ------------------------------------------------------------ *
   * Determine WINS host+domain name, similar to nbtstat -A       *
   * ------------------------------------------------------------ */
  public static boolean smbresolve(String ip) throws IOException {
    String w_name = "";
    String domain = "";
    try { 
      NbtAddress[] addrs = NbtAddress.getAllByAddress(ip);
      w_name = addrs[0].getHostName();
      domain = addrs[1].getHostName();
      //for(int i=0; i<addrs.length; i++) {System.out.println(addrs[i]);}
      System.out.print( "NAME: "+w_name+" DOMAIN: "+domain );
      if(csv==1) { hostline = hostline+w_name+separator+domain; }
      else       { hostline = hostline+"NAME: "+w_name+" DOMAIN: "+domain; }
      return true;
    }
    catch (UnknownHostException e) {
      System.out.print( "NAME: Unknown DOMAIN: Unknown " );
      if(csv==1) { hostline = hostline+"Unknown"+separator+"Unknown"; }
      else       { hostline = hostline+"NAME: Unknown DOMAIN: Unknown "; }
    return false;
    }
  }
  
  /* ------------------------------------------------------------ *
   * Print the programs usage, and a example with expected args.  *
   * ------------------------------------------------------------ */
  public static void usage() {
    System.out.println( "Usage: java -cp ../jcifs-1.3.18.jar;. smbscan <domain> <user> <pass> <network-base> <start_ip> <end_ip> [csv] [wt]\n" );
    System.out.println( "Example: java -cp ../jcifs-1.3.18.jar;. smbscan WORKGROUP user1 pass1 192.168.1 20 44" ); 
    System.out.println( "This will run the check on these IP's: 192.168.1.20-44." );
    System.out.println( "The optional parameter 'csv' creates Excel-ready output, while 'wt' does an extra write test." );
    System.out.println( "The write test tries to create a small text file and deletes it." );
  }
  
  /* ------------------------------------------------------------ *
   * Decode the access mask from a Windows ACL into a String      *
   * Windows ACE permissions are represented by bits in a 32-bit  *
   * value called an access mask.                                 *
   * ------------------------------------------------------------ */
  public static String acl_decode(int aces) {
    String access_rights = "";
         
    /* ------------------------------------------------------------ *
     * Display the rights in the same way as Windows through decode *
     * of the the known bitmasks. If unknown, show the raw hex data *
     * ------------------------------------------------------------ */
     if ((aces & 0x001F01FFL) != 0)         { access_rights = "Full control"; }
     else if ((aces & 0x00000004L) != 0)    { access_rights = "Read&Execute"; }
     else if ((aces & 0xA0000000L) != 0)    { access_rights = "Read&Execute"; }
     else if ((aces & 0x00000002L) != 0)    { access_rights = "Special"; }
     else if ((aces & 0x10000000L) != 0)    { access_rights = "Special"; }
     else { access_rights = "0x"+Hexdump.toHexString(aces, 8); }
     
    return access_rights;
  }
  
  /* ------------------------------------------------------------ *
   * Below is the main program structure.                         *
   * ------------------------------------------------------------ */
  public static void main( String[] argv ) throws Exception {
    File outfile;
    String pstate;
    String port;
    String hostname;
    String hostdomain;

     /* ------------------------------------------------------------ *
      * Simple check of commandline args, generate usage description *
      * ------------------------------------------------------------ */    
    if (argv.length < 6) {
      System.out.println( "\nError: Insufficient args ("+argv.length+")." );
      usage();
      System.exit (-1);
    }
    if (argv.length > 8) {
      System.out.println( "\nError: To many args ("+argv.length+")." );
      usage();
      System.exit (-1);
    }
    if (argv.length > 6 && argv[6].equals("csv")) {
      csv = 1;
      System.out.println( "Received arg "+argv[6]+" - Using CSV format with separator: "+separator);
    }
    
    if (argv.length > 7 && argv[7].equals("wt")) {
      wt = 1;
      System.out.println( "Received arg "+argv[7]+" - Adding write tests.");
    }

    String domain=argv[0];
    String user=argv[1];
    String pass=argv[2];
    String basenet=argv[3];
    int start_host= Integer.parseInt(argv[4]);
    int end_host= Integer.parseInt(argv[5]);
    
    if ((start_host < 1) || (end_host > 254)) {
      System.out.println( "\nError: Start-IP < 1, or End-IP > 254." );
      usage();
      System.exit (-1);
    }

     /* ------------------------------------------------------------ *
      * Create the output file, arg "csv" creates a .csv, else .txt  *
      * ------------------------------------------------------------ */
    if (csv == 1) { outfile = new File (basenet+"-smbscan.csv"); }
    else          { outfile = new File (basenet+"-smbscan.txt"); }
    
    /* Overwrite existing, and create new file if i doesnt exist   */
    if (!outfile.exists()) { outfile.createNewFile(); }
    
    /* Create the writer streams, buffered needs a flush to disk   */
    FileWriter fw = new FileWriter(outfile.getAbsoluteFile());
    BufferedWriter bw = new BufferedWriter(fw);
    
    /* Get this programs name to write it onto the file header */
    String callerClassName = new Exception().getStackTrace()[0].getClassName();
    
    /* Write a header line with the commandline parameter reference */
    NtlmPasswordAuthentication auth = new NtlmPasswordAuthentication(domain, user, pass);
    
    /* For csv files, write the column headers */
    if (csv == 1) {
      bw.write("IP-ADDRESS"+separator+
               "PING"+separator+
               "PORT UP"+separator+
               "HOSTNAME"+separator+
               "DOMAIN"+separator+
               "SHARE"+separator+
               "EXPORT ACL"+separator+
               "FOLDER ACL"+separator+
               "READ ACCESS");
                
      if (wt == 1) { bw.write(separator+"WRITE TEST"); }
      bw.write("\n");
    }
    else {
      bw.write("Executing "+callerClassName+" as "+domain+"\\"+user+"\n"); 
    }
      
   /* ------------------------------------------------------------ * 
    * loop through the given IP range and test the hosts           *
    * ------------------------------------------------------------ */
    int host = start_host;
    while(host<=end_host) {
      hostline = "";
     /* ------------------------------------------------------------ *
      * Generate the IP object using a string of the hosts name      *
      * (e.g. "java.sun.com"), or of its IP address (IPv4 or v6).    *
      * ------------------------------------------------------------ */
      String ip = basenet+"."+host;
      InetAddress inet = InetAddress.getByName(ip);
      
     /* Output the tested IP address to console and file */
      System.out.print("TEST: "+ip);
      if(csv==1) { hostline = ip+separator; }
      else       { hostline = "TEST: "+ip; }
    
     /* Ping the IP */
      if (! ping(inet, ping_timeout)) { bw.write(hostline); host++; continue; }
    
     /* Check TCP-445 */
      if(! smbcheck(inet, smb_timeout)) { bw.write(hostline); host++; continue; }
    
     /* Try to get the hosts WINS Name */
     smbresolve(ip);
    
      /* Try to authenticate to the host */
      SmbFile smb_obj = new SmbFile( "smb://"+domain+";"+user+":"+pass+"@"+ip+"/" );
      
      /* Try to get a list of share objects, if they are readable */
      SmbFile[] obj_list;
      try {
        obj_list = smb_obj.listFiles();
      }
      catch( SmbAuthException sae ) {
        System.out.print( " SHARE: SmbAuthException\n" );
        if(csv==1) { bw.write(hostline+separator+"SmbAuthException\n"); }
        else       { bw.write(hostline+" SHARE: SmbAuthException\n"); }
        host++;
        continue;
      } 
      catch( SmbException se ) {
        System.out.print( " SHARE: SmbException\n" );
        if(csv==1) { bw.write(hostline+separator+"SmbException\n"); }
        else       { bw.write(hostline+" SHARE: SmbException\n"); }
        host++;
        continue;
      }
      
      /* ------------------------------------------------------------ *
       * cyle through all SMB objects (Shares, Pipes, Printers)       *
       * ------------------------------------------------------------ */
      for( int i = 0; i < obj_list.length; i++ ) {
        String share_name = "";
        String export_sec = "";
        String folder_sec = "";
         String share_url = "";

        /* ------------------------------------------------------------ *
         * Return only Shares, which are type=8                         *
         * ------------------------------------------------------------ */          
        if(obj_list[i].getType() == 8) {

          share_name = obj_list[i].getName();
           
          /* Eliminate the share name trailing slash */
          share_name = share_name.substring(0, share_name.length()-1);
          
          System.out.print( " SHARE: " + share_name);
          
          /* If CSV, create the share URI for easy point & click access */
          if(csv==1) { share_url = "file:\\\\"+ip+"\\"+share_name; }
            
          /* ------------------------------------------------------------ *
           * Check share export permissions ACL, if readable.             *
           * Display ACL entries similar to Win Adv. Security Permissions *
           * [ Type - (Resolved) Name - Permission - Inheritance ]        *
           * ------------------------------------------------------------ */
          try {
            ACE[] export_acl = obj_list[i].getShareSecurity(true);
            
            for (int ai = 0; ai < export_acl.length; ai++) {
              String acl_user = "";
              
              /* Check if the acl type is "allow" or "deny": */
              String acl_type = "";
              if(export_acl[ai].isAllow() == true) { acl_type = "Allow "; }
              else { acl_type = "Deny "; }
              
              /* decode the access mask into a string */
              String acl_rights = acl_decode(export_acl[ai].getAccessMask());
              
              /* add the the ACL type first */
              acl_user="["+acl_type+
              /* get the SID type, e.g. User, Local group, Builtin group */ 
              export_acl[ai].getSID().getTypeText()+" "+
              /* get the SID ID resolved to a name, if possible */
              export_acl[ai].getSID().toDisplayString()+" "+
              /* add the ACL access mask string */
              acl_rights+" "+
              /* get the ACL inheritance information */
              /* For CSV we eliminate all the commas */
              export_acl[ai].getApplyToText().replaceAll(",", "")+"] ";
             
              export_sec = export_sec + acl_user;
            } // end for
          System.out.print(" EXPORT: analyzed " + export_acl.length + " ACE");
          } // end try
          catch (Exception e) {
            export_sec = "No Access";
            System.out.print(" EXPORT: No Access");
          }
         

    
          /* ------------------------------------------------------------ *
           * Check share folder permissions ACL, if readable              *
           * ------------------------------------------------------------ */
          try {
            ACE[] folder_acl = obj_list[i].getSecurity(true);
            
            for (int ai = 0; ai < folder_acl.length; ai++) {
              String acl_user = "";

              /* Check if the acl type is "allow" or "deny": */
              String acl_type = "";
              if(folder_acl[ai].isAllow() == true) { acl_type = "Allow "; }
              else { acl_type = "Deny "; }
              
              /* decode the access mask into a string */
              String acl_rights = acl_decode(folder_acl[ai].getAccessMask());
              
              /* add the the ACL type first */
              acl_user="["+acl_type+
              /* get the SID type, e.g. User, Local group, Builtin group */
              folder_acl[ai].getSID().getTypeText()+" "+
              /* Get the SID ID resolved to a name, if possible */
              folder_acl[ai].getSID().toDisplayString()+" "+
              /* Get the ACL access mask information */
              acl_rights+" "+
              /* Get the ACL inheritance information */
              /* For CSV we eliminate all the commas */
              folder_acl[ai].getApplyToText().replaceAll(",", "")+"] ";
                
              folder_sec = folder_sec + acl_user;
            }
            System.out.print(" FOLDER: analyzed " + folder_acl.length + " ACE");
          }
          catch (Exception e) { 
            folder_sec = "No Access"; 
            System.out.print(" FOLDER: No Access");
         } 
          
          /* ------------------------------------------------------------ *
           * List the top-5 files and directories, if possible. This      *
           * confirms the read access to the share.                       *
           * ------------------------------------------------------------ */
          String read_test = "";  
          try {        
            SmbFile[] file_list = obj_list[i].listFiles();

            for(int fi = 0; file_list != null && fi < file_list.length; fi++ ) {
              read_test = read_test + file_list[fi].getName() + " ";
              if(fi > 5) { break; }
            }
            if ( file_list.length < 5) {
              System.out.print(" READ: checked " + file_list.length + "/" + file_list.length+ " share entries");
            } else {
              System.out.print(" READ: checked 5/" + file_list.length + " share entries");
            }
          }
          catch( SmbException se ) {
            read_test = "No Read Access";
            System.out.print(" READ: No Read Access");
          }
          
          if (wt == 1) {
            /* ------------------------------------------------------------ *
             * Try to write a dummy file into the share, and afterwards try *
             * deleting it. This confirms the write access to the share.    *
             * ------------------------------------------------------------ */
            String write_test = "";
            String rdnfile = "test"+System.currentTimeMillis()+".txt";
            try {
              String testurl = "smb://"+domain+";"+user+":"+pass+"@"+ip+"/"+share_name+"/"+rdnfile;
              System.out.print(" WRITE: "+rdnfile);
              
              SmbFile test_file = new SmbFile(testurl);
              test_file.createNewFile();
              test_file.delete();
              write_test = "Write Access OK";
            }
            catch( Exception e ) {
              write_test = "No Write Access";
            }
            System.out.println(" "+write_test);
          
            /* Here we do the final line output to file */
            if(csv==1) { bw.write(hostline+separator+share_url+separator
                                +export_sec+separator+folder_sec+separator+read_test+separator+write_test+"\n"); }
            else  { bw.write(hostline+" SHARE: "+share_name+" EXPORT: "
                            +export_sec+" FOLDER: "+folder_sec+" READ: "+read_test+" WRITE: "+write_test+"\n"); }
          } // end if condition write test
          else {
            System.out.println();
            
          }  
        } // end if condition obj = fileshare
      } // end for loop over share objects
      host++;
    } // end while loop over all ip
  bw.close();
  } // end main
}  //end class
