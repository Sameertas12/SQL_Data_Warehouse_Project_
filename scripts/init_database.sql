/*
-----------------------------------------------------------------------------------
Creating Databases for Bronze, Silver and Gold Layers.
-----------------------------------------------------------------------------------

Script Purpose:
  This script creates new databases named bronze, silver and gold after checking already if it exists. 
  No harmful code like dropping the database if exists is included in the script.
*/

-- Creating Databases for Three Layers
CREATE DATABASE IF NOT EXISTS Bronze;
CREATE DATABASE IF NOT EXISTS Silver;
CREATE DATABASE IF NOT EXISTS Gold;
