// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/sql;
import ballerina/test;
import ballerina/time;

// The `BinaryType` record to represent the `BINARY_TYPES` database table.
type BinaryType record {|
    int row_id;
    byte[] blob_type;
    byte[] binary_type;
|};

// The `JsonType` record to represent the `JSON_TYPES` database table.
type JsonType record {|
    int row_id;
    json json_doc;
    json json_array;
|};

// The `DateTimeType` record to represent the `DATE_TIME_TYPES` database table.
type DateTimeType record {|
    int row_id;
    string date_type;
    int time_type;
    time:Utc timestamp_type;
    string datetime_type;
|};

@test:Config {enable:true}
public function testComplexQueries() returns error? {
    // Runs the prerequisite setup for the example.
    check beforeExample4();

    // Initializes the MySQL client.
    Client mysqlClient = check new (host = host, user = user, password = password, database = "MYSQL_BBE_3", port =
                             port, options = {serverTimezone: serverTimezone});

    // Since the `rowType` is provided as a `BinaryType`, the `resultStream`
    // will have `BinaryType` records.
    stream<record{}, error> resultStream =
                mysqlClient->query(`SELECT * FROM BINARY_TYPES`, BinaryType);
    stream<BinaryType, sql:Error> binaryResultStream =
                <stream<BinaryType, sql:Error>> resultStream;

    io:println("Binary types Result :");
    // Iterates the `binaryResultStream`.
    error? e = binaryResultStream.forEach(function(BinaryType result) {
        io:println(result);
    });

    // Since the `rowType` is provided as an `JsonType`, the `resultStream2` will
    // have `JsonType` records.
    stream<record{}, error> resultStream2 =
                mysqlClient->query(`SELECT * FROM JSON_TYPES`, JsonType);
    stream<JsonType, sql:Error> jsonResultStream =
                <stream<JsonType, sql:Error>> resultStream2;

    io:println("Json type Result :");
    // Iterates the `jsonResultStream`.
    error? e2 = jsonResultStream.forEach(function(JsonType result) {
        io:println(result);
    });

    // Since the `rowType` is provided as a `DateTimeType`, the `resultStream3`
    // will have `DateTimeType` records. The `Date`, `Time`, `DateTime`, and
    // `Timestamp` fields of the database table can be mapped to `time:Utc`,
    // string, and int types in Ballerina.
    stream<record{}, error> resultStream3 =
                mysqlClient->query(`SELECT * FROM DATE_TIME_TYPES`,
                                     DateTimeType);
    stream<DateTimeType, sql:Error> dateResultStream =
                <stream<DateTimeType, sql:Error>>resultStream3;

    io:println("DateTime types Result :");
    // Iterates the `dateResultStream`.
    error? e3 = dateResultStream.forEach(function(DateTimeType result) {
        io:println(result);
    });

    // Performs the cleanup after the example.
    check afterExample4(mysqlClient);
}

// Initializes the database as a prerequisite to the example.
function beforeExample4() returns sql:Error? {
    Client mysqlClient = check new (host = host, user = user, password = password, options = {serverTimezone: serverTimezone});

    // Creates a database.
    sql:ExecutionResult result =
        check mysqlClient->execute(`CREATE DATABASE MYSQL_BBE_3`);
    
    // Creates complex data type tables in the database.
    result = check mysqlClient->execute(`CREATE TABLE MYSQL_BBE_3.BINARY_TYPES
            (row_id INTEGER NOT NULL, blob_type BLOB(1024),  
            binary_type BINARY(27), PRIMARY KEY (row_id))`);
    result = check mysqlClient->execute(`CREATE TABLE MYSQL_BBE_3.JSON_TYPES
            (row_id INTEGER NOT NULL, json_doc JSON, json_array JSON,
            PRIMARY KEY (row_id))`);
    result = check mysqlClient->execute(
            `CREATE TABLE MYSQL_BBE_3.DATE_TIME_TYPES (row_id
            INTEGER NOT NULL, date_type DATE, time_type TIME, 
            timestamp_type timestamp, datetime_type  datetime, 
            PRIMARY KEY (row_id))`);

    // Adds the records to the newly-created tables.
    result = check mysqlClient->execute(`INSERT INTO MYSQL_BBE_3.BINARY_TYPES
            (row_id, blob_type, binary_type) VALUES (1,
            X'77736F322062616C6C6572696E6120626C6F6220746573742E',  
            X'77736F322062616C6C6572696E612062696E61727920746573742E')`);
    result = check mysqlClient->execute(`INSERT INTO MYSQL_BBE_3.JSON_TYPES
            (row_id, json_doc, json_array) VALUES (1, '{"firstName" : "Jhon",
            "lastName" : "Bob", "age" : 18}', JSON_ARRAY(1, 2, 3))`);
    result = check mysqlClient->execute(
            `Insert into MYSQL_BBE_3.DATE_TIME_TYPES (row_id,
            date_type, time_type, timestamp_type, datetime_type) values (1, 
            '2017-05-23', '14:15:23', '2017-01-25 16:33:55', 
            '2017-01-25 16:33:55')`);

    check mysqlClient.close();        
}

// Cleans up the database after running the example.
function afterExample4(Client mysqlClient) returns sql:Error? {
    // Cleans the database.
    sql:ExecutionResult result =
            check mysqlClient->execute(`DROP DATABASE MYSQL_BBE_3`);
    // Closes the MySQL client.
    check mysqlClient.close();
}
