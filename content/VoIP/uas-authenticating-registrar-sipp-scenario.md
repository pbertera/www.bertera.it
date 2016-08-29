Title: UAS Authenticating registrar SIPp scenario
Date: 2013-05-30 16:42
Author: admin
Tags: sip, SIPp, Testing, VoIP
Slug: uas-authenticating-registrar-sipp-scenario
Status: published

[SIPp](http://sipp.sourceforge.net) is a real SIP swiss army knife. You
can create various SIP scenario and test your devices and environments.

I never found a SIPp scenario implementing an UAs (User Agent server)
registrar with authentication.

Following you can find this scenario:

The SIPp XML scenario file: **sipp\_register\_auth\_uas.xml**  

```
<?xml version="1.0" encoding="ISO-8859-1" ?>
<!DOCTYPE scenario SYSTEM "sipp.dtd">
 
<scenario name="Basic UAS registrar with authentication">
  
<label id="badauth"/> 
<recv request="REGISTER" />
  <send><![CDATA[
 
      SIP/2.0 401 Authorization Required
      [last_Via:]
      [last_From:]
      [last_To:];tag=[pid]SIPpTag01[call_number]
      [last_Call-ID:]
      [last_CSeq:]
      Contact: <sip:[local_ip]:[local_port];transport=[transport]>
      WWW-Authenticate: Digest realm="test.example.com", nonce="47ebe028cda119c35d4877b383027d28da013815"
      Content-Length: [len]
 
    ]]>
  </send>
  <recv request="REGISTER" >
        <action>
                <ereg regexp="Digest .*username=\"([^\"]*)\"" search_in="hdr" header="Authorization:" assign_to="junk,username" />
                <lookup assign_to="line" file="users.csv" key="[$username]" />
                <assign assign_to="junk" value="0" />
                <log message="Received REGISTER from user -[$username]-" />
                <log message="searching in file at line [$line]: Username: [field0 line=\"[$line]\"] Pass: [field1 line=\"[$line]\"]"/>
                <verifyauth assign_to="authvalid" username="[field0 line=\"[$line]\"]" password="[field1 line=\"[$line]\"]" />
        </action>
  </recv>
 
  <nop hide="true" test="authvalid" next="goodauth" />
  <nop hide="true" next="badauth" />
   
  <label id="goodauth"/>
  <send>
    <![CDATA[
 
      SIP/2.0 200 OK
      [last_Via:]
      [last_From:]
      [last_To:];tag=[call_number]
      [last_Call-ID:]
      [last_CSeq:]
      Contact: <sip:[local_ip]:[local_port];transport=[transport]>
      Content-Length: 0
      Expires: 3600
 
    ]]>
  </send>
 
  
  <!-- definition of the response time repartition table (unit is ms)   -->
  <ResponseTimeRepartition value="10, 20, 30, 40, 50, 100, 150, 200"/>
 
  <!-- definition of the call length repartition table (unit is ms)     -->
  <CallLengthRepartition value="10, 50, 100, 500, 1000, 5000, 10000"/>
 
</scenario>
```

Here the users file: a CSV containing users and password (first column
is the username, second column the password). **users.csv**

```
USERS  
pippero;1234  
pippo;1234  
```

Now you can run your scenario putting users.csv and
sipp_register_auth_uas.xml in the same directory, and running SIPp
inside the directory (SIPp handle in a stupid manned direcotories..):

```
sipp -sf sipp_register_auth_uas.xml -inf users.csv -infindex users.csv 0 -log_file sipp_register_auth_uas.log -trace_logs  
```

And you will see an output like this:  

```
------------------------------ Scenario Screen -------- [1-9]: Change Screen --
  Port   Total-time  Total-calls  Transport
  5060       4.00 s            0  UDP
 
  0 new calls during 1.001 s period      1 ms scheduler resolution
  0 calls                                Peak was 0 calls, after 0 s
  0 Running, 1 Paused, 3 Woken up
  0 dead call msg (discarded)          
  3 open sockets                        
 
                                 Messages  Retrans   Timeout   Unexpected-Msg
  ----------> REGISTER           0         0         0         0        
  <---------- 401                0         0                            
  ----------> REGISTER           0         0         0         0        
  <---------- 200                0         0                            
------------------------------ Sipp Server Mode -------------------------------
```

Now you can register your device configuring the registrar address and
credentials, when your device will send the REGISTER request you will
the message flow:

```
------------------------------ Scenario Screen -------- [1-9]: Change Screen --
  Port   Total-time  Total-calls  Transport
  5060     161.28 s            1  UDP
 
  0 new calls during 1.001 s period      1 ms scheduler resolution
  0 calls                                Peak was 1 calls, after 157 s
  0 Running, 2 Paused, 4 Woken up
  0 dead call msg (discarded)          
  3 open sockets                        
 
                                 Messages  Retrans   Timeout   Unexpected-Msg
  ----------> REGISTER           1         0         0         0        
  <---------- 401                1         0                            
  ----------> REGISTER           1         0         0         0        
  <---------- 200                1         0                            
------------------------------ Sipp Server Mode -------------------------------
```

Log messages will be saved in **sipp\_register\_auth\_uas.log**.  
Please note that the **verifyauth** needs the OpenSSL support.

