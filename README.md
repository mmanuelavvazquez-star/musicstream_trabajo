##README 




This is the instruction file for our project "Music Streaming Platform", a project in which we created a database from scratch to design a platform that allows us to enjoy music listening, with personalized recommendations and listening statistics. 

This project is for the "Database" course and was created by Group 30. It is still in the implementation stage, with the objective of developing a fully functional database that allows us to design this platform. This project will be carried out entirely using PostgreSQL.


We are attaching a folder schema that contains all the tables and data of our database.

project-streaming/
│
├── schema.sql          # Table creation, relationships, constraints
├── data.sql            # Test data insertion (~1000 records)
├── procedures.sql      # Complex procedures and functions
├── queries.sql         # Functional queries and reports
├── README.md           # This file
└── report.pdf          # Technical document (max. 15 pages)

To be able to create this database, it is necessary to have the following programs installed beforehand for the proper functioning of the project:

-PostgreSQL 15+

-DBeaver (to run the scripts)

-GitHub (if version control is used in a team)

-Visual Studio Code (optional for SQL editing)

To install our database, we will open PostgreSQL and create a database using the following command:
CREATE DATABASE streaming_db;

Next, we need to connect to this database in order to execute all the data. We then create all our files in this database using the command 
\c streaming_db;


Now we will execute all the tables along with their constraints, and we will also run the triggers using the following command:

\i schema.sql

This file will generate the tables and their respective integrity relationships. Tables such as users, User_Premium, User_Free, and device... will be created. We run the data.sql file to populate the tables with data. 
\i data.sql

