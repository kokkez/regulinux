-- Adminer 4.2.2 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `AdminUsers`;
CREATE TABLE `AdminUsers` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `AdminUsersRight`;
CREATE TABLE `AdminUsersRight` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `BackDNS`;
CREATE TABLE `BackDNS` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `BATVTag`;
CREATE TABLE `BATVTag` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `delaydb`;
CREATE TABLE `delaydb` (
  `pkey` varchar(511) NOT NULL,
  `pvalue` longblob,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `delaywhitedb`;
CREATE TABLE `delaywhitedb` (
  `pkey` varchar(511) NOT NULL,
  `pvalue` longblob,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `DKIMCache`;
CREATE TABLE `DKIMCache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `ldaplist`;
CREATE TABLE `ldaplist` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_alias`;
CREATE TABLE `mail_alias` (
  `aid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'alias id',
  `dyn` varchar(16) NOT NULL DEFAULT '0',
  `created` int(10) unsigned NOT NULL DEFAULT '0',
  `changed` int(10) unsigned NOT NULL DEFAULT '0',
  `active` int(1) unsigned NOT NULL DEFAULT '1',
  `sort` int(10) unsigned NOT NULL DEFAULT '0',
  `did` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'domain id',
  `prefix` varchar(32) NOT NULL,
  `target` text NOT NULL COMMENT 'destination',
  `notes` text NOT NULL,
  PRIMARY KEY (`aid`),
  KEY `did` (`did`),
  KEY `target` (`target`(32)),
  KEY `prefix` (`prefix`),
  KEY `active` (`active`,`prefix`(12))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_domain`;
CREATE TABLE `mail_domain` (
  `did` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'domain id',
  `dyn` varchar(16) NOT NULL DEFAULT '0',
  `created` int(10) unsigned NOT NULL DEFAULT '0',
  `changed` int(10) unsigned NOT NULL DEFAULT '0',
  `active` int(1) unsigned NOT NULL DEFAULT '1',
  `sort` int(10) unsigned NOT NULL DEFAULT '0',
  `domain` varchar(64) NOT NULL DEFAULT '',
  `aid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'alias of domain id',
  `notes` text NOT NULL,
  PRIMARY KEY (`did`),
  UNIQUE KEY `domain` (`domain`),
  KEY `active` (`active`),
  KEY `aid` (`aid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_route`;
CREATE TABLE `mail_route` (
  `rid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'route id',
  `dyn` varchar(16) NOT NULL DEFAULT '0',
  `created` int(10) unsigned NOT NULL DEFAULT '0',
  `changed` int(10) unsigned NOT NULL DEFAULT '0',
  `active` int(1) unsigned NOT NULL DEFAULT '1',
  `sort` int(10) unsigned NOT NULL DEFAULT '0',
  `did` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'domain id',
  `prefix` varchar(32) NOT NULL,
  `tid` int(1) unsigned NOT NULL DEFAULT '1' COMMENT 'transport id',
  `extransport` varchar(127) NOT NULL COMMENT 'ex transport value',
  `notes` text NOT NULL,
  PRIMARY KEY (`rid`),
  UNIQUE KEY `unique` (`did`,`prefix`(20),`tid`),
  KEY `did` (`did`),
  KEY `active` (`active`),
  KEY `tid` (`tid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_sasl`;
CREATE TABLE `mail_sasl` (
  `sid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'transport id',
  `dyn` varchar(16) NOT NULL DEFAULT '0',
  `created` int(10) unsigned NOT NULL DEFAULT '0',
  `changed` int(10) unsigned NOT NULL DEFAULT '0',
  `active` int(1) unsigned NOT NULL DEFAULT '1',
  `sort` int(10) unsigned NOT NULL DEFAULT '0',
  `username` text NOT NULL,
  `password` text NOT NULL COMMENT 'username:password',
  `notes` text NOT NULL,
  PRIMARY KEY (`sid`),
  UNIQUE KEY `unique` (`username`(32)),
  KEY `active` (`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_transport`;
CREATE TABLE `mail_transport` (
  `tid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'transport id',
  `dyn` varchar(16) NOT NULL DEFAULT '0',
  `created` int(10) unsigned NOT NULL DEFAULT '0',
  `changed` int(10) unsigned NOT NULL DEFAULT '0',
  `active` int(1) unsigned NOT NULL DEFAULT '1',
  `sort` int(10) unsigned NOT NULL DEFAULT '0',
  `transport` text NOT NULL COMMENT 'hostname & port',
  `credentials` text NOT NULL COMMENT 'username:password',
  `notes` text NOT NULL,
  PRIMARY KEY (`tid`),
  KEY `active` (`active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `MXACache`;
CREATE TABLE `MXACache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `PBBlack`;
CREATE TABLE `PBBlack` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `PBTrap`;
CREATE TABLE `PBTrap` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `PBWhite`;
CREATE TABLE `PBWhite` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `persblack`;
CREATE TABLE `persblack` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `PTRCache`;
CREATE TABLE `PTRCache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `RBLCache`;
CREATE TABLE `RBLCache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `redlist`;
CREATE TABLE `redlist` (
  `pkey` varchar(511) NOT NULL,
  `pvalue` longblob,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `RWLCache`;
CREATE TABLE `RWLCache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SBCache`;
CREATE TABLE `SBCache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `spamdb`;
CREATE TABLE `spamdb` (
  `pkey` varchar(511) NOT NULL,
  `pvalue` longblob,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `spamdbhelo`;
CREATE TABLE `spamdbhelo` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `SPFCache`;
CREATE TABLE `SPFCache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `URIBLCache`;
CREATE TABLE `URIBLCache` (
  `pkey` varbinary(254) NOT NULL,
  `pvalue` varbinary(255) DEFAULT NULL,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `whitelist`;
CREATE TABLE `whitelist` (
  `pkey` varchar(511) NOT NULL,
  `pvalue` longblob,
  `pfrozen` tinyint(4) NOT NULL,
  PRIMARY KEY (`pkey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- 2016-04-24 08:37:06
