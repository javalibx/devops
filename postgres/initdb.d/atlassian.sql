CREATE DATABASE IF NOT EXISTS `dev_jira`;
GRANT ALL ON `dev_jira`.* TO 'admin'@'%';
FLUSH PRIVILEGES;


CREATE DATABASE IF NOT EXISTS `dev_confluence`;
GRANT ALL ON `dev_confluence`.* TO 'admin'@'%';
FLUSH PRIVILEGES;