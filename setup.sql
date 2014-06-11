SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;


CREATE TABLE IF NOT EXISTS `sw_users` (
  `sw_uid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'SuccessWhale user ID',
  `secret` varchar(100) NOT NULL COMMENT 'API access token',
  `username` varchar(50) DEFAULT NULL COMMENT 'Alternative login username',
  `password` varchar(200) DEFAULT NULL COMMENT 'Alternative login password (bcrypt hash)',
  `columns` varchar(1000) DEFAULT NULL COMMENT 'Column data',
  `colsperscreen` smallint(6) NOT NULL DEFAULT '3' COMMENT 'Number of columns to display per screen width in clients',
  `posttoservices` varchar(1000) DEFAULT NULL COMMENT 'Services to post to by default',
  `theme` varchar(50) NOT NULL DEFAULT 'default' COMMENT 'Theme to use in clients',
  `blocklist` varchar(1000) DEFAULT NULL COMMENT 'Phrases that will cause items to be hidden from the user',
  `utcoffset` varchar(20) NOT NULL DEFAULT '0' COMMENT 'Users time zone',
  `highlighttime` int(11) NOT NULL DEFAULT '15' COMMENT 'Clients highlight new items until they are X minutes old',
  `inlinemedia` BOOLEAN NOT NULL DEFAULT '1' COMMENT 'Display inline media in columns when using a client?',
  `tokencreated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Token creation date for calculating expiry',
  PRIMARY KEY (`sw_uid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 COMMENT='SuccessWhale user data';

CREATE TABLE IF NOT EXISTS `facebook_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sw_uid` int(11) NOT NULL,
  `uid` varchar(80) NOT NULL,
  `access_token` varchar(500) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `twitter_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sw_uid` int(11) NOT NULL,
  `uid` varchar(80) NOT NULL,
  `username` varchar(80) NOT NULL,
  `access_token` varchar(500) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `twitter_oauth_sessions` (
  `key` varchar(255) NOT NULL COMMENT 'Twitter OAuth Session key, managed by SW',
  `request_token` varchar(255) NOT NULL COMMENT 'Request Token used to start OAuth',
  `request_token_secret` varchar(255) NOT NULL COMMENT 'Request Token Secret used to start OAuth',
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Cache of Twitter Oauth Request Tokens so session can be recovered by callback';