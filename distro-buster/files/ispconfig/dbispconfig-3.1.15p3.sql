-- Adminer 4.3.1 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `aps_instances`;
CREATE TABLE `aps_instances` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `customer_id` int(4) NOT NULL DEFAULT '0',
  `package_id` int(4) NOT NULL DEFAULT '0',
  `instance_status` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `aps_instances_settings`;
CREATE TABLE `aps_instances_settings` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `instance_id` int(4) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `aps_packages`;
CREATE TABLE `aps_packages` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `path` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `category` varchar(255) NOT NULL DEFAULT '',
  `version` varchar(20) NOT NULL DEFAULT '',
  `release` int(4) NOT NULL DEFAULT '0',
  `package_url` text,
  `package_status` int(1) NOT NULL DEFAULT '2',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `aps_settings`;
CREATE TABLE `aps_settings` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `aps_settings` (`id`, `name`, `value`) VALUES
(1,	'ignore-php-extension',	''),
(2,	'ignore-php-configuration',	''),
(3,	'ignore-webserver-module',	'');

DROP TABLE IF EXISTS `attempts_login`;
CREATE TABLE `attempts_login` (
  `ip` varchar(39) NOT NULL DEFAULT '',
  `times` int(11) DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `client`;
CREATE TABLE `client` (
  `client_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `company_name` varchar(64) DEFAULT NULL,
  `company_id` varchar(255) DEFAULT NULL,
  `gender` enum('','m','f') NOT NULL DEFAULT '',
  `contact_firstname` varchar(64) NOT NULL DEFAULT '',
  `contact_name` varchar(64) DEFAULT NULL,
  `customer_no` varchar(64) DEFAULT NULL,
  `vat_id` varchar(64) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `zip` varchar(32) DEFAULT NULL,
  `city` varchar(64) DEFAULT NULL,
  `state` varchar(32) DEFAULT NULL,
  `country` char(2) DEFAULT NULL,
  `telephone` varchar(32) DEFAULT NULL,
  `mobile` varchar(32) DEFAULT NULL,
  `fax` varchar(32) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `internet` varchar(255) NOT NULL DEFAULT '',
  `icq` varchar(16) DEFAULT NULL,
  `notes` text,
  `bank_account_owner` varchar(255) DEFAULT NULL,
  `bank_account_number` varchar(255) DEFAULT NULL,
  `bank_code` varchar(255) DEFAULT NULL,
  `bank_name` varchar(255) DEFAULT NULL,
  `bank_account_iban` varchar(255) DEFAULT NULL,
  `bank_account_swift` varchar(255) DEFAULT NULL,
  `paypal_email` varchar(255) DEFAULT NULL,
  `default_mailserver` int(11) unsigned NOT NULL DEFAULT '1',
  `mail_servers` text,
  `limit_maildomain` int(11) NOT NULL DEFAULT '-1',
  `limit_mailbox` int(11) NOT NULL DEFAULT '-1',
  `limit_mailalias` int(11) NOT NULL DEFAULT '-1',
  `limit_mailaliasdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_mailforward` int(11) NOT NULL DEFAULT '-1',
  `limit_mailcatchall` int(11) NOT NULL DEFAULT '-1',
  `limit_mailrouting` int(11) NOT NULL DEFAULT '0',
  `limit_mailfilter` int(11) NOT NULL DEFAULT '-1',
  `limit_fetchmail` int(11) NOT NULL DEFAULT '-1',
  `limit_mailquota` int(11) NOT NULL DEFAULT '-1',
  `limit_spamfilter_wblist` int(11) NOT NULL DEFAULT '0',
  `limit_spamfilter_user` int(11) NOT NULL DEFAULT '0',
  `limit_spamfilter_policy` int(11) NOT NULL DEFAULT '0',
  `default_xmppserver` int(11) unsigned NOT NULL DEFAULT '1',
  `xmpp_servers` text,
  `limit_xmpp_domain` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_user` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_muc` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_anon` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_auth_options` varchar(255) NOT NULL DEFAULT 'plain,hashed,isp',
  `limit_xmpp_vjud` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_proxy` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_status` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_pastebin` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_httparchive` enum('n','y') NOT NULL DEFAULT 'n',
  `default_webserver` int(11) unsigned NOT NULL DEFAULT '1',
  `web_servers` text,
  `limit_web_ip` text,
  `limit_web_domain` int(11) NOT NULL DEFAULT '-1',
  `limit_web_quota` int(11) NOT NULL DEFAULT '-1',
  `web_php_options` varchar(255) NOT NULL DEFAULT 'no,fast-cgi,cgi,mod,suphp,php-fpm,hhvm',
  `limit_cgi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_perl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ruby` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_python` enum('n','y') NOT NULL DEFAULT 'n',
  `force_suexec` enum('n','y') NOT NULL DEFAULT 'y',
  `limit_hterror` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_wildcard` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl_letsencrypt` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_web_subdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_web_aliasdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_ftp_user` int(11) NOT NULL DEFAULT '-1',
  `limit_shell_user` int(11) NOT NULL DEFAULT '0',
  `ssh_chroot` varchar(255) NOT NULL DEFAULT 'no,jailkit,ssh-chroot',
  `limit_webdav_user` int(11) NOT NULL DEFAULT '0',
  `limit_backup` enum('n','y') NOT NULL DEFAULT 'y',
  `limit_directive_snippets` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_aps` int(11) NOT NULL DEFAULT '-1',
  `default_dnsserver` int(11) unsigned NOT NULL DEFAULT '1',
  `db_servers` text,
  `limit_dns_zone` int(11) NOT NULL DEFAULT '-1',
  `default_slave_dnsserver` int(11) unsigned NOT NULL DEFAULT '1',
  `limit_dns_slave_zone` int(11) NOT NULL DEFAULT '-1',
  `limit_dns_record` int(11) NOT NULL DEFAULT '-1',
  `default_dbserver` int(11) NOT NULL DEFAULT '1',
  `dns_servers` text,
  `limit_database` int(11) NOT NULL DEFAULT '-1',
  `limit_database_user` int(11) NOT NULL DEFAULT '-1',
  `limit_database_quota` int(11) NOT NULL DEFAULT '-1',
  `limit_cron` int(11) NOT NULL DEFAULT '0',
  `limit_cron_type` enum('url','chrooted','full') NOT NULL DEFAULT 'url',
  `limit_cron_frequency` int(11) NOT NULL DEFAULT '5',
  `limit_traffic_quota` int(11) NOT NULL DEFAULT '-1',
  `limit_client` int(11) NOT NULL DEFAULT '0',
  `limit_domainmodule` int(11) NOT NULL DEFAULT '0',
  `limit_mailmailinglist` int(11) NOT NULL DEFAULT '-1',
  `limit_openvz_vm` int(11) NOT NULL DEFAULT '0',
  `limit_openvz_vm_template_id` int(11) NOT NULL DEFAULT '0',
  `parent_client_id` int(11) unsigned NOT NULL DEFAULT '0',
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(200) DEFAULT NULL,
  `language` char(2) NOT NULL DEFAULT 'en',
  `usertheme` varchar(32) NOT NULL DEFAULT 'default',
  `template_master` int(11) unsigned NOT NULL DEFAULT '0',
  `template_additional` text,
  `created_at` bigint(20) DEFAULT NULL,
  `locked` enum('n','y') NOT NULL DEFAULT 'n',
  `canceled` enum('n','y') NOT NULL DEFAULT 'n',
  `can_use_api` enum('n','y') NOT NULL DEFAULT 'n',
  `tmp_data` mediumblob,
  `id_rsa` varchar(2000) NOT NULL DEFAULT '',
  `ssh_rsa` varchar(600) NOT NULL DEFAULT '',
  `customer_no_template` varchar(255) DEFAULT 'R[CLIENTID]C[CUSTOMER_NO]',
  `customer_no_start` int(11) NOT NULL DEFAULT '1',
  `customer_no_counter` int(11) NOT NULL DEFAULT '0',
  `added_date` date DEFAULT NULL,
  `added_by` varchar(255) DEFAULT NULL,
  `validation_status` enum('accept','review','reject') NOT NULL DEFAULT 'accept',
  `risk_score` int(10) unsigned NOT NULL DEFAULT '0',
  `activation_code` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `client` (`client_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `company_name`, `company_id`, `gender`, `contact_firstname`, `contact_name`, `customer_no`, `vat_id`, `street`, `zip`, `city`, `state`, `country`, `telephone`, `mobile`, `fax`, `email`, `internet`, `icq`, `notes`, `bank_account_owner`, `bank_account_number`, `bank_code`, `bank_name`, `bank_account_iban`, `bank_account_swift`, `paypal_email`, `default_mailserver`, `mail_servers`, `limit_maildomain`, `limit_mailbox`, `limit_mailalias`, `limit_mailaliasdomain`, `limit_mailforward`, `limit_mailcatchall`, `limit_mailrouting`, `limit_mailfilter`, `limit_fetchmail`, `limit_mailquota`, `limit_spamfilter_wblist`, `limit_spamfilter_user`, `limit_spamfilter_policy`, `default_xmppserver`, `xmpp_servers`, `limit_xmpp_domain`, `limit_xmpp_user`, `limit_xmpp_muc`, `limit_xmpp_anon`, `limit_xmpp_auth_options`, `limit_xmpp_vjud`, `limit_xmpp_proxy`, `limit_xmpp_status`, `limit_xmpp_pastebin`, `limit_xmpp_httparchive`, `default_webserver`, `web_servers`, `limit_web_ip`, `limit_web_domain`, `limit_web_quota`, `web_php_options`, `limit_cgi`, `limit_ssi`, `limit_perl`, `limit_ruby`, `limit_python`, `force_suexec`, `limit_hterror`, `limit_wildcard`, `limit_ssl`, `limit_ssl_letsencrypt`, `limit_web_subdomain`, `limit_web_aliasdomain`, `limit_ftp_user`, `limit_shell_user`, `ssh_chroot`, `limit_webdav_user`, `limit_backup`, `limit_directive_snippets`, `limit_aps`, `default_dnsserver`, `db_servers`, `limit_dns_zone`, `default_slave_dnsserver`, `limit_dns_slave_zone`, `limit_dns_record`, `default_dbserver`, `dns_servers`, `limit_database`, `limit_database_user`, `limit_database_quota`, `limit_cron`, `limit_cron_type`, `limit_cron_frequency`, `limit_traffic_quota`, `limit_client`, `limit_domainmodule`, `limit_mailmailinglist`, `limit_openvz_vm`, `limit_openvz_vm_template_id`, `parent_client_id`, `username`, `password`, `language`, `usertheme`, `template_master`, `template_additional`, `created_at`, `locked`, `canceled`, `can_use_api`, `tmp_data`, `id_rsa`, `ssh_rsa`, `customer_no_template`, `customer_no_start`, `customer_no_counter`, `added_date`, `added_by`, `validation_status`, `risk_score`, `activation_code`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	'Drawing',	'',	'm',	'',	'System',	'DW',	'',	'',	'',	'',	'',	'IT',	'',	'',	'',	'k-system@rete.us',	'http://',	'',	'',	'',	'',	'',	'',	'',	'',	'',	0,	'1',	-1,	-1,	-1,	-1,	-1,	-1,	0,	-1,	-1,	-1,	0,	0,	0,	0,	'',	-1,	-1,	'n',	'n',	'plain,hashed,isp',	'n',	'n',	'n',	'n',	'n',	0,	'1',	NULL,	-1,	-1,	'no,fast-cgi,mod,php-fpm,hhvm',	'n',	'n',	'n',	'n',	'n',	'y',	'y',	'y',	'y',	'n',	-1,	-1,	-1,	0,	'no,jailkit',	0,	'y',	'n',	-1,	0,	'1',	-1,	0,	-1,	-1,	0,	'',	-1,	-1,	-1,	0,	'url',	5,	-1,	0,	0,	-1,	0,	0,	0,	'system',	'$1$X/P1DVWs$oOg7Ua6eabfMuO2Gy0hsw0',	'en',	'default',	0,	'',	1557678212,	'n',	'n',	'n',	NULL,	'-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAw5Lro2DqZaJe7ym5n3vM1dMxD+pSjwKnTunOuCEtj+wLVWd5\nAVlGZk7k88rJhiuciee42raHbNkgnPZ2h7AMYcaYAzgde1pvb7H+V3aynU0RJ59J\n5kCxicANeG8IfkpxEcv8q6I0jgWRv8dZdFATpJIdiqBwsoZL6iEde0dlBLUQ30pK\n11thgItw0D752kXRv+E/J5/OR7rk3n+FGDYsIy1jCX9VXzRpALJUNul6X/4Jgm4a\nsK8TBNmEMuyHFWmEMa9EfoAsphHwyiJCqmrvngm3RQTns16hJhbp2p3bQxhaqOTh\nfnfWqI7gM1JrNOTQNeHu+BSQW2ViqPjVxWJ1XQIDAQABAoIBAEerwuD3tk6Sp3m7\n78OLafB+Wb98Xs776PZZZqFBv2G73hdpOQYOgmchyHOzQBEEUHSVT8APHif8liAP\njjaBhLgcQD8FxIAdDzN+pjfFTwWoZX4AuONBmA5kLEuTXShy/WbJO4pmgh392oDO\nfHDMm7Y2uc7Apyw1XQKrKhOwgUusruhSCRMTREBdRawkvaCPGUX5rEKAjB8vX+Zv\neyYS1j2RooANDQvoJEiaprHSEsCXADi3mA4ITrZrIofpkveuXgg2QBWjuOWYEtIH\n05EwJ70OhU+c6t7Ctjl4R8LwEcQugx+8+A1uIaj8RoqCvGRhiHBs5l2ymy/4Bd6g\nM0Gd7GECgYEA70+VrMmm29BIBfGgWEjGwovP+423JGqX94F/Iff9OrgxCxN4qioA\nAGx4IfeuAw91bS+kHWit0HHibAplQEosMX+EDrx4cnPtSCeKHeyqVAhp6+rYpowO\nU6d35mHRiWm5DdjjZXnubXf/rkHpGqJobhWz2aAHBA9AYLn4z8LgJNkCgYEA0TZ/\n//IYK7rByqMooGHJ/qje4DwstGXbCozK/U3X9opmQzNPYl0nMG3zfb2RDXva27+G\nTnGahQEunkVUB16TsmieLRJpouGKDfLs2FubLzNHyewoXpN/XOUlU52NdJWhb8WR\nzOqJhvWYA+XdVxrhdzMAGifPX+gguWxh7cBo8iUCgYB9DtHg4eBYrpd0w7hPaniz\n4exmQMCcPzf7F6kgTz/+F5NJfntoMVqe3hBJb+13m/R5gpP46mMqstjoLOaMmjZO\nB50zNjqbVQmC02bSDINWNq9joe5l2nsCLFn0AtpFPQJ/wf/TX8zBWBw9LCRszsJU\nBPNfnskLzgyOf6EOsYAAwQKBgGYLbTeMABokR63tEz3XNM1P1RYOg8eh/ssQjVos\nA/Cu5N5WQpw5z4mht6hXNE8dYEzbCEluw+2n+/Ma4beOfAADY1OcrYXS+KGBIeEO\nHY1SN+vXkoE+9Fp9Mk2shXieG1YHSexnYZlAZVtRXTrFU7/uUlhvnoirEnse0E1F\nEms5AoGAHaLjUcp82lxuUT3c+07nf6xRRS4g1G+hd9M1++lgxAAy5DaYR4k3FJrt\n1nvlPbKdSzCHkF9vajo9CaqEDKMnvGJ7gsuqpVVX6ZfdyrDWb1cJoQxfs01XxFeC\nDzdCTx3+cxWlfZNuZrzGaMA10C8Kbs3rrdT+s2UlXSLaXaIs6Js=\n-----END RSA PRIVATE KEY-----\n',	'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDkuujYOplol7vKbmfe8zV0zEP6lKPAqdO6c64IS2P7AtVZ3kBWUZmTuTzysmGK5yJ57jatods2SCc9naHsAxhxpgDOB17Wm9vsf5XdrKdTREnn0nmQLGJwA14bwh+SnERy/yrojSOBZG/x1l0UBOkkh2KoHCyhkvqIR17R2UEtRDfSkrXW2GAi3DQPvnaRdG/4T8nn85HuuTef4UYNiwjLWMJf1VfNGkAslQ26Xpf/gmCbhqwrxME2YQy7IcVaYQxr0R+gCymEfDKIkKqau+eCbdFBOezXqEmFunandtDGFqo5OF+d9aojuAzUms05NA14e74FJBbZWKo+NXFYnVd system-rsa-key-1557678212\n',	'R[CLIENTID]C[CUSTOMER_NO]',	1,	0,	'2019-05-12',	'admin',	'accept',	0,	'');

DROP TABLE IF EXISTS `client_circle`;
CREATE TABLE `client_circle` (
  `circle_id` int(11) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `circle_name` varchar(64) DEFAULT NULL,
  `client_ids` text,
  `description` text,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`circle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `client_message_template`;
CREATE TABLE `client_message_template` (
  `client_message_template_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `template_type` varchar(255) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text,
  PRIMARY KEY (`client_message_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `client_template`;
CREATE TABLE `client_template` (
  `template_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `template_name` varchar(64) NOT NULL DEFAULT '',
  `template_type` varchar(1) NOT NULL DEFAULT 'm',
  `mail_servers` text,
  `limit_maildomain` int(11) NOT NULL DEFAULT '-1',
  `limit_mailbox` int(11) NOT NULL DEFAULT '-1',
  `limit_mailalias` int(11) NOT NULL DEFAULT '-1',
  `limit_mailaliasdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_mailforward` int(11) NOT NULL DEFAULT '-1',
  `limit_mailcatchall` int(11) NOT NULL DEFAULT '-1',
  `limit_mailrouting` int(11) NOT NULL DEFAULT '0',
  `limit_mailfilter` int(11) NOT NULL DEFAULT '-1',
  `limit_fetchmail` int(11) NOT NULL DEFAULT '-1',
  `limit_mailquota` int(11) NOT NULL DEFAULT '-1',
  `limit_spamfilter_wblist` int(11) NOT NULL DEFAULT '0',
  `limit_spamfilter_user` int(11) NOT NULL DEFAULT '0',
  `limit_spamfilter_policy` int(11) NOT NULL DEFAULT '0',
  `default_xmppserver` int(11) unsigned NOT NULL DEFAULT '1',
  `xmpp_servers` text,
  `limit_xmpp_domain` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_user` int(11) NOT NULL DEFAULT '-1',
  `limit_xmpp_muc` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_anon` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_vjud` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_proxy` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_status` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_pastebin` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_xmpp_httparchive` enum('n','y') NOT NULL DEFAULT 'n',
  `web_servers` text,
  `limit_web_ip` text,
  `limit_web_domain` int(11) NOT NULL DEFAULT '-1',
  `limit_web_quota` int(11) NOT NULL DEFAULT '-1',
  `web_php_options` varchar(255) NOT NULL DEFAULT 'no',
  `limit_cgi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssi` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_perl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ruby` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_python` enum('n','y') NOT NULL DEFAULT 'n',
  `force_suexec` enum('n','y') NOT NULL DEFAULT 'y',
  `limit_hterror` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_wildcard` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_ssl_letsencrypt` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_web_subdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_web_aliasdomain` int(11) NOT NULL DEFAULT '-1',
  `limit_ftp_user` int(11) NOT NULL DEFAULT '-1',
  `limit_shell_user` int(11) NOT NULL DEFAULT '0',
  `ssh_chroot` varchar(255) NOT NULL DEFAULT 'no',
  `limit_webdav_user` int(11) NOT NULL DEFAULT '0',
  `limit_backup` enum('n','y') NOT NULL DEFAULT 'y',
  `limit_directive_snippets` enum('n','y') NOT NULL DEFAULT 'n',
  `limit_aps` int(11) NOT NULL DEFAULT '-1',
  `dns_servers` text,
  `limit_dns_zone` int(11) NOT NULL DEFAULT '-1',
  `default_slave_dnsserver` int(11) NOT NULL DEFAULT '0',
  `limit_dns_slave_zone` int(11) NOT NULL DEFAULT '-1',
  `limit_dns_record` int(11) NOT NULL DEFAULT '-1',
  `db_servers` text,
  `limit_database` int(11) NOT NULL DEFAULT '-1',
  `limit_database_user` int(11) NOT NULL DEFAULT '-1',
  `limit_database_quota` int(11) NOT NULL DEFAULT '-1',
  `limit_cron` int(11) NOT NULL DEFAULT '0',
  `limit_cron_type` enum('url','chrooted','full') NOT NULL DEFAULT 'url',
  `limit_cron_frequency` int(11) NOT NULL DEFAULT '5',
  `limit_traffic_quota` int(11) NOT NULL DEFAULT '-1',
  `limit_client` int(11) NOT NULL DEFAULT '0',
  `limit_domainmodule` int(11) NOT NULL DEFAULT '0',
  `limit_mailmailinglist` int(11) NOT NULL DEFAULT '-1',
  `limit_openvz_vm` int(11) NOT NULL DEFAULT '0',
  `limit_openvz_vm_template_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `client_template_assigned`;
CREATE TABLE `client_template_assigned` (
  `assigned_template_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_id` bigint(11) NOT NULL DEFAULT '0',
  `client_template_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`assigned_template_id`),
  KEY `client_id` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `country`;
CREATE TABLE `country` (
  `iso` char(2) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `printable_name` varchar(64) NOT NULL DEFAULT '',
  `iso3` char(3) DEFAULT NULL,
  `numcode` smallint(6) DEFAULT NULL,
  `eu` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`iso`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `country` (`iso`, `name`, `printable_name`, `iso3`, `numcode`, `eu`) VALUES
('AD',	'ANDORRA',	'Andorra',	'AND',	20,	'n'),
('AE',	'UNITED ARAB EMIRATES',	'United Arab Emirates',	'ARE',	784,	'n'),
('AF',	'AFGHANISTAN',	'Afghanistan',	'AFG',	4,	'n'),
('AG',	'ANTIGUA AND BARBUDA',	'Antigua and Barbuda',	'ATG',	28,	'n'),
('AI',	'ANGUILLA',	'Anguilla',	'AIA',	660,	'n'),
('AL',	'ALBANIA',	'Albania',	'ALB',	8,	'n'),
('AM',	'ARMENIA',	'Armenia',	'ARM',	51,	'n'),
('AN',	'NETHERLANDS ANTILLES',	'Netherlands Antilles',	'ANT',	530,	'n'),
('AO',	'ANGOLA',	'Angola',	'AGO',	24,	'n'),
('AQ',	'ANTARCTICA',	'Antarctica',	NULL,	NULL,	'n'),
('AR',	'ARGENTINA',	'Argentina',	'ARG',	32,	'n'),
('AS',	'AMERICAN SAMOA',	'American Samoa',	'ASM',	16,	'n'),
('AT',	'AUSTRIA',	'Austria',	'AUT',	40,	'y'),
('AU',	'AUSTRALIA',	'Australia',	'AUS',	36,	'n'),
('AW',	'ARUBA',	'Aruba',	'ABW',	533,	'n'),
('AZ',	'AZERBAIJAN',	'Azerbaijan',	'AZE',	31,	'n'),
('BA',	'BOSNIA AND HERZEGOVINA',	'Bosnia and Herzegovina',	'BIH',	70,	'n'),
('BB',	'BARBADOS',	'Barbados',	'BRB',	52,	'n'),
('BD',	'BANGLADESH',	'Bangladesh',	'BGD',	50,	'n'),
('BE',	'BELGIUM',	'Belgium',	'BEL',	56,	'y'),
('BF',	'BURKINA FASO',	'Burkina Faso',	'BFA',	854,	'n'),
('BG',	'BULGARIA',	'Bulgaria',	'BGR',	100,	'y'),
('BH',	'BAHRAIN',	'Bahrain',	'BHR',	48,	'n'),
('BI',	'BURUNDI',	'Burundi',	'BDI',	108,	'n'),
('BJ',	'BENIN',	'Benin',	'BEN',	204,	'n'),
('BM',	'BERMUDA',	'Bermuda',	'BMU',	60,	'n'),
('BN',	'BRUNEI DARUSSALAM',	'Brunei Darussalam',	'BRN',	96,	'n'),
('BO',	'BOLIVIA',	'Bolivia',	'BOL',	68,	'n'),
('BR',	'BRAZIL',	'Brazil',	'BRA',	76,	'n'),
('BS',	'BAHAMAS',	'Bahamas',	'BHS',	44,	'n'),
('BT',	'BHUTAN',	'Bhutan',	'BTN',	64,	'n'),
('BV',	'BOUVET ISLAND',	'Bouvet Island',	NULL,	NULL,	'n'),
('BW',	'BOTSWANA',	'Botswana',	'BWA',	72,	'n'),
('BY',	'BELARUS',	'Belarus',	'BLR',	112,	'n'),
('BZ',	'BELIZE',	'Belize',	'BLZ',	84,	'n'),
('CA',	'CANADA',	'Canada',	'CAN',	124,	'n'),
('CC',	'COCOS (KEELING) ISLANDS',	'Cocos (Keeling) Islands',	NULL,	NULL,	'n'),
('CD',	'CONGO, THE DEMOCRATIC REPUBLIC OF THE',	'Congo, the Democratic Republic of the',	'COD',	180,	'n'),
('CF',	'CENTRAL AFRICAN REPUBLIC',	'Central African Republic',	'CAF',	140,	'n'),
('CG',	'CONGO',	'Congo',	'COG',	178,	'n'),
('CH',	'SWITZERLAND',	'Switzerland',	'CHE',	756,	'n'),
('CI',	'COTE D\'IVOIRE',	'Cote D\'Ivoire',	'CIV',	384,	'n'),
('CK',	'COOK ISLANDS',	'Cook Islands',	'COK',	184,	'n'),
('CL',	'CHILE',	'Chile',	'CHL',	152,	'n'),
('CM',	'CAMEROON',	'Cameroon',	'CMR',	120,	'n'),
('CN',	'CHINA',	'China',	'CHN',	156,	'n'),
('CO',	'COLOMBIA',	'Colombia',	'COL',	170,	'n'),
('CR',	'COSTA RICA',	'Costa Rica',	'CRI',	188,	'n'),
('CU',	'CUBA',	'Cuba',	'CUB',	192,	'n'),
('CV',	'CAPE VERDE',	'Cape Verde',	'CPV',	132,	'n'),
('CX',	'CHRISTMAS ISLAND',	'Christmas Island',	NULL,	NULL,	'n'),
('CY',	'CYPRUS',	'Cyprus',	'CYP',	196,	'y'),
('CZ',	'CZECH REPUBLIC',	'Czech Republic',	'CZE',	203,	'y'),
('DE',	'GERMANY',	'Germany',	'DEU',	276,	'y'),
('DJ',	'DJIBOUTI',	'Djibouti',	'DJI',	262,	'n'),
('DK',	'DENMARK',	'Denmark',	'DNK',	208,	'y'),
('DM',	'DOMINICA',	'Dominica',	'DMA',	212,	'n'),
('DO',	'DOMINICAN REPUBLIC',	'Dominican Republic',	'DOM',	214,	'n'),
('DZ',	'ALGERIA',	'Algeria',	'DZA',	12,	'n'),
('EC',	'ECUADOR',	'Ecuador',	'ECU',	218,	'n'),
('EE',	'ESTONIA',	'Estonia',	'EST',	233,	'y'),
('EG',	'EGYPT',	'Egypt',	'EGY',	818,	'n'),
('EH',	'WESTERN SAHARA',	'Western Sahara',	'ESH',	732,	'n'),
('ER',	'ERITREA',	'Eritrea',	'ERI',	232,	'n'),
('ES',	'SPAIN',	'Spain',	'ESP',	724,	'y'),
('ET',	'ETHIOPIA',	'Ethiopia',	'ETH',	231,	'n'),
('FI',	'FINLAND',	'Finland',	'FIN',	246,	'y'),
('FJ',	'FIJI',	'Fiji',	'FJI',	242,	'n'),
('FK',	'FALKLAND ISLANDS (MALVINAS)',	'Falkland Islands (Malvinas)',	'FLK',	238,	'n'),
('FM',	'MICRONESIA, FEDERATED STATES OF',	'Micronesia, Federated States of',	'FSM',	583,	'n'),
('FO',	'FAROE ISLANDS',	'Faroe Islands',	'FRO',	234,	'n'),
('FR',	'FRANCE',	'France',	'FRA',	250,	'y'),
('GA',	'GABON',	'Gabon',	'GAB',	266,	'n'),
('GB',	'UNITED KINGDOM',	'United Kingdom',	'GBR',	826,	'y'),
('GD',	'GRENADA',	'Grenada',	'GRD',	308,	'n'),
('GE',	'GEORGIA',	'Georgia',	'GEO',	268,	'n'),
('GF',	'FRENCH GUIANA',	'French Guiana',	'GUF',	254,	'n'),
('GH',	'GHANA',	'Ghana',	'GHA',	288,	'n'),
('GI',	'GIBRALTAR',	'Gibraltar',	'GIB',	292,	'n'),
('GL',	'GREENLAND',	'Greenland',	'GRL',	304,	'n'),
('GM',	'GAMBIA',	'Gambia',	'GMB',	270,	'n'),
('GN',	'GUINEA',	'Guinea',	'GIN',	324,	'n'),
('GP',	'GUADELOUPE',	'Guadeloupe',	'GLP',	312,	'n'),
('GQ',	'EQUATORIAL GUINEA',	'Equatorial Guinea',	'GNQ',	226,	'n'),
('GR',	'GREECE',	'Greece',	'GRC',	300,	'y'),
('GS',	'SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS',	'South Georgia and the South Sandwich Islands',	NULL,	NULL,	'n'),
('GT',	'GUATEMALA',	'Guatemala',	'GTM',	320,	'n'),
('GU',	'GUAM',	'Guam',	'GUM',	316,	'n'),
('GW',	'GUINEA-BISSAU',	'Guinea-Bissau',	'GNB',	624,	'n'),
('GY',	'GUYANA',	'Guyana',	'GUY',	328,	'n'),
('HK',	'HONG KONG',	'Hong Kong',	'HKG',	344,	'n'),
('HM',	'HEARD ISLAND AND MCDONALD ISLANDS',	'Heard Island and Mcdonald Islands',	NULL,	NULL,	'n'),
('HN',	'HONDURAS',	'Honduras',	'HND',	340,	'n'),
('HR',	'CROATIA',	'Croatia',	'HRV',	191,	'y'),
('HT',	'HAITI',	'Haiti',	'HTI',	332,	'n'),
('HU',	'HUNGARY',	'Hungary',	'HUN',	348,	'y'),
('ID',	'INDONESIA',	'Indonesia',	'IDN',	360,	'n'),
('IE',	'IRELAND',	'Ireland',	'IRL',	372,	'y'),
('IL',	'ISRAEL',	'Israel',	'ISR',	376,	'n'),
('IN',	'INDIA',	'India',	'IND',	356,	'n'),
('IO',	'BRITISH INDIAN OCEAN TERRITORY',	'British Indian Ocean Territory',	NULL,	NULL,	'n'),
('IQ',	'IRAQ',	'Iraq',	'IRQ',	368,	'n'),
('IR',	'IRAN, ISLAMIC REPUBLIC OF',	'Iran, Islamic Republic of',	'IRN',	364,	'n'),
('IS',	'ICELAND',	'Iceland',	'ISL',	352,	'n'),
('IT',	'ITALY',	'Italy',	'ITA',	380,	'y'),
('JM',	'JAMAICA',	'Jamaica',	'JAM',	388,	'n'),
('JO',	'JORDAN',	'Jordan',	'JOR',	400,	'n'),
('JP',	'JAPAN',	'Japan',	'JPN',	392,	'n'),
('KE',	'KENYA',	'Kenya',	'KEN',	404,	'n'),
('KG',	'KYRGYZSTAN',	'Kyrgyzstan',	'KGZ',	417,	'n'),
('KH',	'CAMBODIA',	'Cambodia',	'KHM',	116,	'n'),
('KI',	'KIRIBATI',	'Kiribati',	'KIR',	296,	'n'),
('KM',	'COMOROS',	'Comoros',	'COM',	174,	'n'),
('KN',	'SAINT KITTS AND NEVIS',	'Saint Kitts and Nevis',	'KNA',	659,	'n'),
('KP',	'KOREA, DEMOCRATIC PEOPLE\'S REPUBLIC OF',	'Korea, Democratic People\'s Republic of',	'PRK',	408,	'n'),
('KR',	'KOREA, REPUBLIC OF',	'Korea, Republic of',	'KOR',	410,	'n'),
('KW',	'KUWAIT',	'Kuwait',	'KWT',	414,	'n'),
('KY',	'CAYMAN ISLANDS',	'Cayman Islands',	'CYM',	136,	'n'),
('KZ',	'KAZAKHSTAN',	'Kazakhstan',	'KAZ',	398,	'n'),
('LA',	'LAO PEOPLE\'S DEMOCRATIC REPUBLIC',	'Lao People\'s Democratic Republic',	'LAO',	418,	'n'),
('LB',	'LEBANON',	'Lebanon',	'LBN',	422,	'n'),
('LC',	'SAINT LUCIA',	'Saint Lucia',	'LCA',	662,	'n'),
('LI',	'LIECHTENSTEIN',	'Liechtenstein',	'LIE',	438,	'n'),
('LK',	'SRI LANKA',	'Sri Lanka',	'LKA',	144,	'n'),
('LR',	'LIBERIA',	'Liberia',	'LBR',	430,	'n'),
('LS',	'LESOTHO',	'Lesotho',	'LSO',	426,	'n'),
('LT',	'LITHUANIA',	'Lithuania',	'LTU',	440,	'y'),
('LU',	'LUXEMBOURG',	'Luxembourg',	'LUX',	442,	'y'),
('LV',	'LATVIA',	'Latvia',	'LVA',	428,	'y'),
('LY',	'LIBYAN ARAB JAMAHIRIYA',	'Libyan Arab Jamahiriya',	'LBY',	434,	'n'),
('MA',	'MOROCCO',	'Morocco',	'MAR',	504,	'n'),
('MC',	'MONACO',	'Monaco',	'MCO',	492,	'n'),
('MD',	'MOLDOVA, REPUBLIC OF',	'Moldova, Republic of',	'MDA',	498,	'n'),
('ME',	'MONTENEGRO',	'Montenegro',	'MNE',	382,	'n'),
('MG',	'MADAGASCAR',	'Madagascar',	'MDG',	450,	'n'),
('MH',	'MARSHALL ISLANDS',	'Marshall Islands',	'MHL',	584,	'n'),
('MK',	'MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF',	'Macedonia, the Former Yugoslav Republic of',	'MKD',	807,	'n'),
('ML',	'MALI',	'Mali',	'MLI',	466,	'n'),
('MM',	'MYANMAR',	'Myanmar',	'MMR',	104,	'n'),
('MN',	'MONGOLIA',	'Mongolia',	'MNG',	496,	'n'),
('MO',	'MACAO',	'Macao',	'MAC',	446,	'n'),
('MP',	'NORTHERN MARIANA ISLANDS',	'Northern Mariana Islands',	'MNP',	580,	'n'),
('MQ',	'MARTINIQUE',	'Martinique',	'MTQ',	474,	'n'),
('MR',	'MAURITANIA',	'Mauritania',	'MRT',	478,	'n'),
('MS',	'MONTSERRAT',	'Montserrat',	'MSR',	500,	'n'),
('MT',	'MALTA',	'Malta',	'MLT',	470,	'y'),
('MU',	'MAURITIUS',	'Mauritius',	'MUS',	480,	'n'),
('MV',	'MALDIVES',	'Maldives',	'MDV',	462,	'n'),
('MW',	'MALAWI',	'Malawi',	'MWI',	454,	'n'),
('MX',	'MEXICO',	'Mexico',	'MEX',	484,	'n'),
('MY',	'MALAYSIA',	'Malaysia',	'MYS',	458,	'n'),
('MZ',	'MOZAMBIQUE',	'Mozambique',	'MOZ',	508,	'n'),
('NA',	'NAMIBIA',	'Namibia',	'NAM',	516,	'n'),
('NC',	'NEW CALEDONIA',	'New Caledonia',	'NCL',	540,	'n'),
('NE',	'NIGER',	'Niger',	'NER',	562,	'n'),
('NF',	'NORFOLK ISLAND',	'Norfolk Island',	'NFK',	574,	'n'),
('NG',	'NIGERIA',	'Nigeria',	'NGA',	566,	'n'),
('NI',	'NICARAGUA',	'Nicaragua',	'NIC',	558,	'n'),
('NL',	'NETHERLANDS',	'Netherlands',	'NLD',	528,	'y'),
('NO',	'NORWAY',	'Norway',	'NOR',	578,	'n'),
('NP',	'NEPAL',	'Nepal',	'NPL',	524,	'n'),
('NR',	'NAURU',	'Nauru',	'NRU',	520,	'n'),
('NU',	'NIUE',	'Niue',	'NIU',	570,	'n'),
('NZ',	'NEW ZEALAND',	'New Zealand',	'NZL',	554,	'n'),
('OM',	'OMAN',	'Oman',	'OMN',	512,	'n'),
('PA',	'PANAMA',	'Panama',	'PAN',	591,	'n'),
('PE',	'PERU',	'Peru',	'PER',	604,	'n'),
('PF',	'FRENCH POLYNESIA',	'French Polynesia',	'PYF',	258,	'n'),
('PG',	'PAPUA NEW GUINEA',	'Papua New Guinea',	'PNG',	598,	'n'),
('PH',	'PHILIPPINES',	'Philippines',	'PHL',	608,	'n'),
('PK',	'PAKISTAN',	'Pakistan',	'PAK',	586,	'n'),
('PL',	'POLAND',	'Poland',	'POL',	616,	'y'),
('PM',	'SAINT PIERRE AND MIQUELON',	'Saint Pierre and Miquelon',	'SPM',	666,	'n'),
('PN',	'PITCAIRN',	'Pitcairn',	'PCN',	612,	'n'),
('PR',	'PUERTO RICO',	'Puerto Rico',	'PRI',	630,	'n'),
('PS',	'PALESTINIAN TERRITORY, OCCUPIED',	'Palestinian Territory, Occupied',	NULL,	NULL,	'n'),
('PT',	'PORTUGAL',	'Portugal',	'PRT',	620,	'y'),
('PW',	'PALAU',	'Palau',	'PLW',	585,	'n'),
('PY',	'PARAGUAY',	'Paraguay',	'PRY',	600,	'n'),
('QA',	'QATAR',	'Qatar',	'QAT',	634,	'n'),
('RE',	'REUNION',	'Reunion',	'REU',	638,	'n'),
('RO',	'ROMANIA',	'Romania',	'ROM',	642,	'y'),
('RS',	'SERBIA',	'Serbia',	'SRB',	381,	'n'),
('RU',	'RUSSIAN FEDERATION',	'Russian Federation',	'RUS',	643,	'n'),
('RW',	'RWANDA',	'Rwanda',	'RWA',	646,	'n'),
('SA',	'SAUDI ARABIA',	'Saudi Arabia',	'SAU',	682,	'n'),
('SB',	'SOLOMON ISLANDS',	'Solomon Islands',	'SLB',	90,	'n'),
('SC',	'SEYCHELLES',	'Seychelles',	'SYC',	690,	'n'),
('SD',	'SUDAN',	'Sudan',	'SDN',	736,	'n'),
('SE',	'SWEDEN',	'Sweden',	'SWE',	752,	'y'),
('SG',	'SINGAPORE',	'Singapore',	'SGP',	702,	'n'),
('SH',	'SAINT HELENA',	'Saint Helena',	'SHN',	654,	'n'),
('SI',	'SLOVENIA',	'Slovenia',	'SVN',	705,	'y'),
('SJ',	'SVALBARD AND JAN MAYEN',	'Svalbard and Jan Mayen',	'SJM',	744,	'n'),
('SK',	'SLOVAKIA',	'Slovakia',	'SVK',	703,	'y'),
('SL',	'SIERRA LEONE',	'Sierra Leone',	'SLE',	694,	'n'),
('SM',	'SAN MARINO',	'San Marino',	'SMR',	674,	'n'),
('SN',	'SENEGAL',	'Senegal',	'SEN',	686,	'n'),
('SO',	'SOMALIA',	'Somalia',	'SOM',	706,	'n'),
('SR',	'SURINAME',	'Suriname',	'SUR',	740,	'n'),
('ST',	'SAO TOME AND PRINCIPE',	'Sao Tome and Principe',	'STP',	678,	'n'),
('SV',	'EL SALVADOR',	'El Salvador',	'SLV',	222,	'n'),
('SY',	'SYRIAN ARAB REPUBLIC',	'Syrian Arab Republic',	'SYR',	760,	'n'),
('SZ',	'SWAZILAND',	'Swaziland',	'SWZ',	748,	'n'),
('TC',	'TURKS AND CAICOS ISLANDS',	'Turks and Caicos Islands',	'TCA',	796,	'n'),
('TD',	'CHAD',	'Chad',	'TCD',	148,	'n'),
('TF',	'FRENCH SOUTHERN TERRITORIES',	'French Southern Territories',	NULL,	NULL,	'n'),
('TG',	'TOGO',	'Togo',	'TGO',	768,	'n'),
('TH',	'THAILAND',	'Thailand',	'THA',	764,	'n'),
('TJ',	'TAJIKISTAN',	'Tajikistan',	'TJK',	762,	'n'),
('TK',	'TOKELAU',	'Tokelau',	'TKL',	772,	'n'),
('TL',	'TIMOR-LESTE',	'Timor-Leste',	NULL,	NULL,	'n'),
('TM',	'TURKMENISTAN',	'Turkmenistan',	'TKM',	795,	'n'),
('TN',	'TUNISIA',	'Tunisia',	'TUN',	788,	'n'),
('TO',	'TONGA',	'Tonga',	'TON',	776,	'n'),
('TR',	'TURKEY',	'Turkey',	'TUR',	792,	'n'),
('TT',	'TRINIDAD AND TOBAGO',	'Trinidad and Tobago',	'TTO',	780,	'n'),
('TV',	'TUVALU',	'Tuvalu',	'TUV',	798,	'n'),
('TW',	'TAIWAN, PROVINCE OF CHINA',	'Taiwan, Province of China',	'TWN',	158,	'n'),
('TZ',	'TANZANIA, UNITED REPUBLIC OF',	'Tanzania, United Republic of',	'TZA',	834,	'n'),
('UA',	'UKRAINE',	'Ukraine',	'UKR',	804,	'n'),
('UG',	'UGANDA',	'Uganda',	'UGA',	800,	'n'),
('UM',	'UNITED STATES MINOR OUTLYING ISLANDS',	'United States Minor Outlying Islands',	NULL,	NULL,	'n'),
('US',	'UNITED STATES',	'United States',	'USA',	840,	'n'),
('UY',	'URUGUAY',	'Uruguay',	'URY',	858,	'n'),
('UZ',	'UZBEKISTAN',	'Uzbekistan',	'UZB',	860,	'n'),
('VA',	'HOLY SEE (VATICAN CITY STATE)',	'Holy See (Vatican City State)',	'VAT',	336,	'n'),
('VC',	'SAINT VINCENT AND THE GRENADINES',	'Saint Vincent and the Grenadines',	'VCT',	670,	'n'),
('VE',	'VENEZUELA',	'Venezuela',	'VEN',	862,	'n'),
('VG',	'VIRGIN ISLANDS, BRITISH',	'Virgin Islands, British',	'VGB',	92,	'n'),
('VI',	'VIRGIN ISLANDS, U.S.',	'Virgin Islands, U.s.',	'VIR',	850,	'n'),
('VN',	'VIET NAM',	'Viet Nam',	'VNM',	704,	'n'),
('VU',	'VANUATU',	'Vanuatu',	'VUT',	548,	'n'),
('WF',	'WALLIS AND FUTUNA',	'Wallis and Futuna',	'WLF',	876,	'n'),
('WS',	'SAMOA',	'Samoa',	'WSM',	882,	'n'),
('YE',	'YEMEN',	'Yemen',	'YEM',	887,	'n'),
('YT',	'MAYOTTE',	'Mayotte',	NULL,	NULL,	'n'),
('ZA',	'SOUTH AFRICA',	'South Africa',	'ZAF',	710,	'n'),
('ZM',	'ZAMBIA',	'Zambia',	'ZMB',	894,	'n'),
('ZW',	'ZIMBABWE',	'Zimbabwe',	'ZWE',	716,	'n');

DROP TABLE IF EXISTS `cron`;
CREATE TABLE `cron` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT '0',
  `type` enum('url','chrooted','full') NOT NULL DEFAULT 'url',
  `command` text,
  `run_min` varchar(100) DEFAULT NULL,
  `run_hour` varchar(100) DEFAULT NULL,
  `run_mday` varchar(100) DEFAULT NULL,
  `run_month` varchar(100) DEFAULT NULL,
  `run_wday` varchar(100) DEFAULT NULL,
  `log` enum('n','y') NOT NULL DEFAULT 'n',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `directive_snippets`;
CREATE TABLE `directive_snippets` (
  `directive_snippets_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `snippet` mediumtext,
  `customer_viewable` enum('n','y') NOT NULL DEFAULT 'n',
  `required_php_snippets` varchar(255) NOT NULL DEFAULT '',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `master_directive_snippets_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`directive_snippets_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `directive_snippets` (`directive_snippets_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `name`, `type`, `snippet`, `customer_viewable`, `required_php_snippets`, `active`, `master_directive_snippets_id`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	'ForceSSL',	'apache',	'RewriteEngine On\r\nRewriteCond %{HTTPS} off\r\nRewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L,NE]\r\n',	'y',	'',	'y',	0),
(2,	1,	1,	'riud',	'riud',	'',	'ForceWWW',	'apache',	'RewriteEngine on\r\nRewriteCond %{HTTP_HOST} !^www\\. [NC]\r\nRewriteRule ^ http://www.%{SERVER_NAME}%{REQUEST_URI} [R=301,L,NE]\r\n',	'y',	'',	'y',	0),
(3,	1,	1,	'riud',	'riud',	'',	'ForceHttps:Host',	'nginx',	'# global https + host handler\r\nset $schost  \"$scheme://$host\";\r\nif ($schost != https://example.com) { return 301 https://example.com$request_uri; }\r\n',	'n',	'',	'y',	0),
(4,	1,	1,	'riud',	'riud',	'',	'InterpretPHP',	'nginx',	'location / { try_files $uri $uri/ /index.php; }',	'n',	'',	'y',	0);

DROP TABLE IF EXISTS `dns_rr`;
CREATE TABLE `dns_rr` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL DEFAULT '1',
  `zone` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `type` enum('A','AAAA','ALIAS','CNAME','CAA','DS','HINFO','LOC','MX','NAPTR','NS','PTR','RP','SRV','TXT','TLSA','DNSKEY') DEFAULT NULL,
  `data` text NOT NULL,
  `aux` int(11) unsigned NOT NULL DEFAULT '0',
  `ttl` int(11) unsigned NOT NULL DEFAULT '3600',
  `active` enum('N','Y') NOT NULL DEFAULT 'Y',
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `serial` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rr` (`zone`,`type`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `dns_slave`;
CREATE TABLE `dns_slave` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL DEFAULT '1',
  `origin` varchar(255) NOT NULL DEFAULT '',
  `ns` varchar(255) NOT NULL DEFAULT '',
  `active` enum('N','Y') NOT NULL DEFAULT 'N',
  `xfer` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slave` (`origin`,`server_id`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `dns_soa`;
CREATE TABLE `dns_soa` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL DEFAULT '1',
  `origin` varchar(255) NOT NULL DEFAULT '',
  `ns` varchar(255) NOT NULL DEFAULT '',
  `mbox` varchar(255) NOT NULL DEFAULT '',
  `serial` int(11) unsigned NOT NULL DEFAULT '1',
  `refresh` int(11) unsigned NOT NULL DEFAULT '28800',
  `retry` int(11) unsigned NOT NULL DEFAULT '7200',
  `expire` int(11) unsigned NOT NULL DEFAULT '604800',
  `minimum` int(11) unsigned NOT NULL DEFAULT '3600',
  `ttl` int(11) unsigned NOT NULL DEFAULT '3600',
  `active` enum('N','Y') NOT NULL DEFAULT 'N',
  `xfer` text,
  `also_notify` text,
  `update_acl` varchar(255) DEFAULT NULL,
  `dnssec_initialized` enum('Y','N') NOT NULL DEFAULT 'N',
  `dnssec_wanted` enum('Y','N') NOT NULL DEFAULT 'N',
  `dnssec_last_signed` bigint(20) NOT NULL DEFAULT '0',
  `dnssec_info` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `origin` (`origin`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `dns_ssl_ca`;
CREATE TABLE `dns_ssl_ca` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `active` enum('N','Y') NOT NULL DEFAULT 'N',
  `ca_name` varchar(255) NOT NULL DEFAULT '',
  `ca_issue` varchar(255) NOT NULL DEFAULT '',
  `ca_wildcard` enum('Y','N') NOT NULL DEFAULT 'N',
  `ca_iodef` text NOT NULL,
  `ca_critical` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ca_issue` (`ca_issue`),
  UNIQUE KEY `ca_issue_2` (`ca_issue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `dns_ssl_ca` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `active`, `ca_name`, `ca_issue`, `ca_wildcard`, `ca_iodef`, `ca_critical`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	'Y',	'AC Camerfirma',	'camerfirma.com',	'Y',	'',	0),
(2,	1,	1,	'riud',	'riud',	'',	'Y',	'ACCV',	'accv.es',	'Y',	'',	0),
(3,	1,	1,	'riud',	'riud',	'',	'Y',	'Actalis',	'actalis.it',	'Y',	'',	0),
(4,	1,	1,	'riud',	'riud',	'',	'Y',	'Amazon',	'amazon.com',	'Y',	'',	0),
(5,	1,	1,	'riud',	'riud',	'',	'Y',	'Asseco',	'certum.pl',	'Y',	'',	0),
(6,	1,	1,	'riud',	'riud',	'',	'Y',	'Buypass',	'buypass.com',	'Y',	'',	0),
(7,	1,	1,	'riud',	'riud',	'',	'Y',	'CA Disig',	'disig.sk',	'Y',	'',	0),
(8,	1,	1,	'riud',	'riud',	'',	'Y',	'CATCert',	'aoc.cat',	'Y',	'',	0),
(9,	1,	1,	'riud',	'riud',	'',	'Y',	'Certinomis',	'www.certinomis.com',	'Y',	'',	0),
(10,	1,	1,	'riud',	'riud',	'',	'Y',	'Certizen',	'hongkongpost.gov.hk',	'Y',	'',	0),
(11,	1,	1,	'riud',	'riud',	'',	'Y',	'certSIGN',	'certsign.ro',	'Y',	'',	0),
(12,	1,	1,	'riud',	'riud',	'',	'Y',	'CFCA',	'cfca.com.cn',	'Y',	'',	0),
(13,	1,	1,	'riud',	'riud',	'',	'Y',	'Chunghwa Telecom',	'cht.com.tw',	'Y',	'',	0),
(14,	1,	1,	'riud',	'riud',	'',	'Y',	'Comodo',	'comodoca.com',	'Y',	'',	0),
(15,	1,	1,	'riud',	'riud',	'',	'Y',	'D-TRUST',	'd-trust.net',	'Y',	'',	0),
(16,	1,	1,	'riud',	'riud',	'',	'Y',	'DigiCert',	'digicert.com',	'Y',	'',	0),
(17,	1,	1,	'riud',	'riud',	'',	'Y',	'DocuSign',	'docusign.fr',	'Y',	'',	0),
(18,	1,	1,	'riud',	'riud',	'',	'Y',	'e-tugra',	'e-tugra.com',	'Y',	'',	0),
(19,	1,	1,	'riud',	'riud',	'',	'Y',	'EDICOM',	'edicomgroup.com',	'Y',	'',	0),
(20,	1,	1,	'riud',	'riud',	'',	'Y',	'Entrust',	'entrust.net',	'Y',	'',	0),
(21,	1,	1,	'riud',	'riud',	'',	'Y',	'Firmaprofesional',	'firmaprofesional.com',	'Y',	'',	0),
(22,	1,	1,	'riud',	'riud',	'',	'Y',	'FNMT',	'fnmt.es',	'Y',	'',	0),
(23,	1,	1,	'riud',	'riud',	'',	'Y',	'GlobalSign',	'globalsign.com',	'Y',	'',	0),
(24,	1,	1,	'riud',	'riud',	'',	'Y',	'GoDaddy',	'godaddy.com',	'Y',	'',	0),
(25,	1,	1,	'riud',	'riud',	'',	'Y',	'Google Trust Services',	'pki.goog',	'Y',	'',	0),
(26,	1,	1,	'riud',	'riud',	'',	'Y',	'GRCA',	'gca.nat.gov.tw',	'Y',	'',	0),
(27,	1,	1,	'riud',	'riud',	'',	'Y',	'HARICA',	'harica.gr',	'Y',	'',	0),
(28,	1,	1,	'riud',	'riud',	'',	'Y',	'IdenTrust',	'identrust.com',	'Y',	'',	0),
(29,	1,	1,	'riud',	'riud',	'',	'Y',	'Izenpe',	'izenpe.com',	'Y',	'',	0),
(30,	1,	1,	'riud',	'riud',	'',	'Y',	'Kamu SM',	'kamusm.gov.tr',	'Y',	'',	0),
(31,	1,	1,	'riud',	'riud',	'',	'Y',	'Let\'s Encrypt',	'letsencrypt.org',	'Y',	'',	0),
(32,	1,	1,	'riud',	'riud',	'',	'Y',	'Microsec e-Szigno',	'e-szigno.hu',	'Y',	'',	0),
(33,	1,	1,	'riud',	'riud',	'',	'Y',	'NetLock',	'netlock.hu',	'Y',	'',	0),
(34,	1,	1,	'riud',	'riud',	'',	'Y',	'PKIoverheid',	'www.pkioverheid.nl',	'Y',	'',	0),
(35,	1,	1,	'riud',	'riud',	'',	'Y',	'PROCERT',	'procert.net.ve',	'Y',	'',	0),
(36,	1,	1,	'riud',	'riud',	'',	'Y',	'QuoVadis',	'quovadisglobal.com',	'Y',	'',	0),
(37,	1,	1,	'riud',	'riud',	'',	'Y',	'SECOM',	'secomtrust.net',	'Y',	'',	0),
(38,	1,	1,	'riud',	'riud',	'',	'Y',	'Sertifitseerimiskeskuse',	'sk.ee',	'Y',	'',	0),
(39,	1,	1,	'riud',	'riud',	'',	'Y',	'StartCom',	'startcomca.com',	'Y',	'',	0),
(40,	1,	1,	'riud',	'riud',	'',	'Y',	'SwissSign',	'swisssign.com',	'Y',	'',	0),
(41,	1,	1,	'riud',	'riud',	'',	'Y',	'Symantec / Thawte / GeoTrust',	'symantec.com',	'Y',	'',	0),
(42,	1,	1,	'riud',	'riud',	'',	'Y',	'T-Systems',	'telesec.de',	'Y',	'',	0),
(43,	1,	1,	'riud',	'riud',	'',	'Y',	'Telia',	'telia.com',	'Y',	'',	0),
(44,	1,	1,	'riud',	'riud',	'',	'Y',	'Trustwave',	'trustwave.com',	'Y',	'',	0),
(45,	1,	1,	'riud',	'riud',	'',	'Y',	'Web.com',	'web.com',	'Y',	'',	0),
(46,	1,	1,	'riud',	'riud',	'',	'Y',	'WISeKey',	'wisekey.com',	'Y',	'',	0),
(47,	1,	1,	'riud',	'riud',	'',	'Y',	'WoSign',	'wosign.com',	'Y',	'',	0);

DROP TABLE IF EXISTS `dns_template`;
CREATE TABLE `dns_template` (
  `template_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `name` varchar(64) DEFAULT NULL,
  `fields` varchar(255) DEFAULT NULL,
  `template` text,
  `visible` enum('N','Y') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `dns_template` (`template_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `name`, `fields`, `template`, `visible`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	'Default',	'DOMAIN,IP,NS1,NS2,EMAIL,DKIM,DNSSEC',	'[ZONE]\norigin={DOMAIN}.\nns={NS1}.\nmbox={EMAIL}.\nrefresh=7200\nretry=540\nexpire=604800\nminimum=3600\nttl=3600\n\n[DNS_RECORDS]\nA|{DOMAIN}.|{IP}|0|3600\nA|www|{IP}|0|3600\nA|mail|{IP}|0|3600\nNS|{DOMAIN}.|{NS1}.|0|3600\nNS|{DOMAIN}.|{NS2}.|0|3600\nMX|{DOMAIN}.|mail.{DOMAIN}.|10|3600\nTXT|{DOMAIN}.|v=spf1 mx a ~all|0|3600',	'Y');

DROP TABLE IF EXISTS `domain`;
CREATE TABLE `domain` (
  `domain_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `domain` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`domain_id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `firewall`;
CREATE TABLE `firewall` (
  `firewall_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `tcp_port` text,
  `udp_port` text,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`firewall_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `ftp_traffic`;
CREATE TABLE `ftp_traffic` (
  `hostname` varchar(255) NOT NULL,
  `traffic_date` date NOT NULL,
  `in_bytes` bigint(32) unsigned NOT NULL,
  `out_bytes` bigint(32) unsigned NOT NULL,
  UNIQUE KEY `hostname` (`hostname`,`traffic_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `ftp_user`;
CREATE TABLE `ftp_user` (
  `ftp_user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT '0',
  `username` varchar(64) DEFAULT NULL,
  `username_prefix` varchar(50) NOT NULL DEFAULT '',
  `password` varchar(200) DEFAULT NULL,
  `quota_size` bigint(20) NOT NULL DEFAULT '-1',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `uid` varchar(64) DEFAULT NULL,
  `gid` varchar(64) DEFAULT NULL,
  `dir` varchar(255) DEFAULT NULL,
  `quota_files` bigint(20) NOT NULL DEFAULT '-1',
  `ul_ratio` int(11) NOT NULL DEFAULT '-1',
  `dl_ratio` int(11) NOT NULL DEFAULT '-1',
  `ul_bandwidth` int(11) NOT NULL DEFAULT '-1',
  `dl_bandwidth` int(11) NOT NULL DEFAULT '-1',
  `expires` datetime DEFAULT NULL,
  `user_type` set('user','system') NOT NULL DEFAULT 'user',
  `user_config` text,
  PRIMARY KEY (`ftp_user_id`),
  KEY `active` (`active`),
  KEY `server_id` (`server_id`),
  KEY `username` (`username`),
  KEY `quota_files` (`quota_files`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `help_faq`;
CREATE TABLE `help_faq` (
  `hf_id` int(11) NOT NULL AUTO_INCREMENT,
  `hf_section` int(11) DEFAULT NULL,
  `hf_order` int(11) DEFAULT '0',
  `hf_question` text,
  `hf_answer` text,
  `sys_userid` int(11) DEFAULT NULL,
  `sys_groupid` int(11) DEFAULT NULL,
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`hf_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `help_faq` (`hf_id`, `hf_section`, `hf_order`, `hf_question`, `hf_answer`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`) VALUES
(1,	1,	0,	'I would like to know ...',	'Yes, of course.',	1,	1,	'riud',	'riud',	'r');

DROP TABLE IF EXISTS `help_faq_sections`;
CREATE TABLE `help_faq_sections` (
  `hfs_id` int(11) NOT NULL AUTO_INCREMENT,
  `hfs_name` varchar(255) DEFAULT NULL,
  `hfs_order` int(11) DEFAULT '0',
  `sys_userid` int(11) DEFAULT NULL,
  `sys_groupid` int(11) DEFAULT NULL,
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`hfs_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `help_faq_sections` (`hfs_id`, `hfs_name`, `hfs_order`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`) VALUES
(1,	'General',	0,	NULL,	NULL,	NULL,	NULL,	NULL);

DROP TABLE IF EXISTS `iptables`;
CREATE TABLE `iptables` (
  `iptables_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(10) unsigned NOT NULL DEFAULT '0',
  `table` varchar(10) DEFAULT NULL COMMENT 'INPUT OUTPUT FORWARD',
  `source_ip` varchar(16) DEFAULT NULL,
  `destination_ip` varchar(16) DEFAULT NULL,
  `protocol` varchar(10) DEFAULT 'TCP' COMMENT 'TCP UDP GRE',
  `singleport` varchar(10) DEFAULT NULL,
  `multiport` varchar(40) DEFAULT NULL,
  `state` varchar(20) DEFAULT NULL COMMENT 'NEW ESTABLISHED RECNET etc',
  `target` varchar(10) DEFAULT NULL COMMENT 'ACCEPT DROP REJECT LOG',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`iptables_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_access`;
CREATE TABLE `mail_access` (
  `access_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL DEFAULT '0',
  `source` varchar(255) NOT NULL DEFAULT '',
  `access` varchar(255) NOT NULL DEFAULT '',
  `type` set('recipient','sender','client') NOT NULL DEFAULT 'recipient',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`access_id`),
  KEY `server_id` (`server_id`,`source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_backup`;
CREATE TABLE `mail_backup` (
  `backup_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(10) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(10) unsigned NOT NULL DEFAULT '0',
  `mailuser_id` int(10) unsigned NOT NULL DEFAULT '0',
  `backup_mode` varchar(64) NOT NULL DEFAULT '',
  `tstamp` int(10) unsigned NOT NULL DEFAULT '0',
  `filename` varchar(255) NOT NULL DEFAULT '',
  `filesize` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`backup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_content_filter`;
CREATE TABLE `mail_content_filter` (
  `content_filter_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `type` varchar(255) DEFAULT NULL,
  `pattern` varchar(255) DEFAULT NULL,
  `data` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`content_filter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_domain`;
CREATE TABLE `mail_domain` (
  `domain_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `domain` varchar(255) NOT NULL DEFAULT '',
  `dkim` enum('n','y') NOT NULL DEFAULT 'n',
  `dkim_selector` varchar(63) NOT NULL DEFAULT 'default',
  `dkim_private` mediumtext,
  `dkim_public` mediumtext,
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`domain_id`),
  KEY `server_id` (`server_id`,`domain`),
  KEY `domain_active` (`domain`,`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_forwarding`;
CREATE TABLE `mail_forwarding` (
  `forwarding_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `source` varchar(255) NOT NULL DEFAULT '',
  `destination` text,
  `type` enum('alias','aliasdomain','forward','catchall') NOT NULL DEFAULT 'alias',
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  `allow_send_as` enum('n','y') NOT NULL DEFAULT 'n',
  `greylisting` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`forwarding_id`),
  KEY `server_id` (`server_id`,`source`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_get`;
CREATE TABLE `mail_get` (
  `mailget_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `type` varchar(255) DEFAULT NULL,
  `source_server` varchar(255) DEFAULT NULL,
  `source_username` varchar(255) DEFAULT NULL,
  `source_password` varchar(64) DEFAULT NULL,
  `source_delete` varchar(255) NOT NULL DEFAULT 'y',
  `source_read_all` varchar(255) NOT NULL DEFAULT 'y',
  `destination` varchar(255) DEFAULT NULL,
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`mailget_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_mailinglist`;
CREATE TABLE `mail_mailinglist` (
  `mailinglist_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `domain` varchar(255) NOT NULL DEFAULT '',
  `listname` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`mailinglist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_relay_recipient`;
CREATE TABLE `mail_relay_recipient` (
  `relay_recipient_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `source` varchar(255) DEFAULT NULL,
  `access` varchar(255) NOT NULL DEFAULT 'OK',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`relay_recipient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_traffic`;
CREATE TABLE `mail_traffic` (
  `traffic_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `mailuser_id` int(11) unsigned NOT NULL DEFAULT '0',
  `month` char(7) NOT NULL DEFAULT '',
  `traffic` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`traffic_id`),
  KEY `mailuser_id` (`mailuser_id`,`month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_transport`;
CREATE TABLE `mail_transport` (
  `transport_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `domain` varchar(255) NOT NULL DEFAULT '',
  `transport` varchar(255) NOT NULL DEFAULT '',
  `sort_order` int(11) unsigned NOT NULL DEFAULT '5',
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`transport_id`),
  KEY `server_id` (`server_id`,`transport`),
  KEY `server_id_2` (`server_id`,`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_user`;
CREATE TABLE `mail_user` (
  `mailuser_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `email` varchar(255) NOT NULL DEFAULT '',
  `login` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `uid` int(11) NOT NULL DEFAULT '5000',
  `gid` int(11) NOT NULL DEFAULT '5000',
  `maildir` varchar(255) NOT NULL DEFAULT '',
  `maildir_format` varchar(255) NOT NULL DEFAULT 'maildir',
  `quota` bigint(20) NOT NULL DEFAULT '-1',
  `cc` varchar(255) NOT NULL DEFAULT '',
  `sender_cc` varchar(255) NOT NULL DEFAULT '',
  `homedir` varchar(255) NOT NULL DEFAULT '',
  `autoresponder` enum('n','y') NOT NULL DEFAULT 'n',
  `autoresponder_start_date` datetime DEFAULT NULL,
  `autoresponder_end_date` datetime DEFAULT NULL,
  `autoresponder_subject` varchar(255) NOT NULL DEFAULT 'Out of office reply',
  `autoresponder_text` mediumtext,
  `move_junk` enum('n','y') NOT NULL DEFAULT 'n',
  `custom_mailfilter` mediumtext,
  `postfix` enum('n','y') NOT NULL DEFAULT 'y',
  `greylisting` enum('n','y') NOT NULL DEFAULT 'n',
  `access` enum('n','y') NOT NULL DEFAULT 'y',
  `disableimap` enum('n','y') NOT NULL DEFAULT 'n',
  `disablepop3` enum('n','y') NOT NULL DEFAULT 'n',
  `disabledeliver` enum('n','y') NOT NULL DEFAULT 'n',
  `disablesmtp` enum('n','y') NOT NULL DEFAULT 'n',
  `disablesieve` enum('n','y') NOT NULL DEFAULT 'n',
  `disablesieve-filter` enum('n','y') NOT NULL DEFAULT 'n',
  `disablelda` enum('n','y') NOT NULL DEFAULT 'n',
  `disablelmtp` enum('n','y') NOT NULL DEFAULT 'n',
  `disabledoveadm` enum('n','y') NOT NULL DEFAULT 'n',
  `last_quota_notification` date DEFAULT NULL,
  `backup_interval` varchar(255) NOT NULL DEFAULT 'none',
  `backup_copies` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`mailuser_id`),
  KEY `server_id` (`server_id`,`email`),
  KEY `email_access` (`email`,`access`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `mail_user_filter`;
CREATE TABLE `mail_user_filter` (
  `filter_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `mailuser_id` int(11) unsigned NOT NULL DEFAULT '0',
  `rulename` varchar(64) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `searchterm` varchar(255) DEFAULT NULL,
  `op` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `target` varchar(255) DEFAULT NULL,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`filter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `monitor_data`;
CREATE TABLE `monitor_data` (
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `type` varchar(255) NOT NULL DEFAULT '',
  `created` int(11) unsigned NOT NULL DEFAULT '0',
  `data` mediumtext,
  `state` enum('no_state','unknown','ok','info','warning','critical','error') NOT NULL DEFAULT 'unknown',
  PRIMARY KEY (`server_id`,`type`,`created`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `openvz_ip`;
CREATE TABLE `openvz_ip` (
  `ip_address_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `ip_address` varchar(39) DEFAULT NULL,
  `vm_id` int(11) NOT NULL DEFAULT '0',
  `reserved` varchar(255) NOT NULL DEFAULT 'n',
  `additional` varchar(255) NOT NULL DEFAULT 'n',
  PRIMARY KEY (`ip_address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `openvz_ostemplate`;
CREATE TABLE `openvz_ostemplate` (
  `ostemplate_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `template_file` varchar(255) NOT NULL DEFAULT '',
  `server_id` int(11) NOT NULL DEFAULT '0',
  `allservers` varchar(255) NOT NULL DEFAULT 'y',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  `description` text,
  PRIMARY KEY (`ostemplate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `openvz_ostemplate` (`ostemplate_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `template_name`, `template_file`, `server_id`, `allservers`, `active`, `description`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	'Debian minimal',	'debian-minimal-x86',	1,	'y',	'y',	'Debian minimal image.');

DROP TABLE IF EXISTS `openvz_template`;
CREATE TABLE `openvz_template` (
  `template_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `diskspace` int(11) NOT NULL DEFAULT '0',
  `traffic` int(11) NOT NULL DEFAULT '-1',
  `bandwidth` int(11) NOT NULL DEFAULT '-1',
  `ram` int(11) NOT NULL DEFAULT '0',
  `ram_burst` int(11) NOT NULL DEFAULT '0',
  `cpu_units` int(11) NOT NULL DEFAULT '1000',
  `cpu_num` int(11) NOT NULL DEFAULT '4',
  `cpu_limit` int(11) NOT NULL DEFAULT '400',
  `io_priority` int(11) NOT NULL DEFAULT '4',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  `description` text,
  `numproc` varchar(255) DEFAULT NULL,
  `numtcpsock` varchar(255) DEFAULT NULL,
  `numothersock` varchar(255) DEFAULT NULL,
  `vmguarpages` varchar(255) DEFAULT NULL,
  `kmemsize` varchar(255) DEFAULT NULL,
  `tcpsndbuf` varchar(255) DEFAULT NULL,
  `tcprcvbuf` varchar(255) DEFAULT NULL,
  `othersockbuf` varchar(255) DEFAULT NULL,
  `dgramrcvbuf` varchar(255) DEFAULT NULL,
  `oomguarpages` varchar(255) DEFAULT NULL,
  `privvmpages` varchar(255) DEFAULT NULL,
  `lockedpages` varchar(255) DEFAULT NULL,
  `shmpages` varchar(255) DEFAULT NULL,
  `physpages` varchar(255) DEFAULT NULL,
  `numfile` varchar(255) DEFAULT NULL,
  `avnumproc` varchar(255) DEFAULT NULL,
  `numflock` varchar(255) DEFAULT NULL,
  `numpty` varchar(255) DEFAULT NULL,
  `numsiginfo` varchar(255) DEFAULT NULL,
  `dcachesize` varchar(255) DEFAULT NULL,
  `numiptent` varchar(255) DEFAULT NULL,
  `swappages` varchar(255) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `nameserver` varchar(255) DEFAULT NULL,
  `create_dns` varchar(1) NOT NULL DEFAULT 'n',
  `capability` varchar(255) DEFAULT NULL,
  `features` varchar(255) DEFAULT NULL,
  `iptables` varchar(255) DEFAULT NULL,
  `custom` text,
  PRIMARY KEY (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `openvz_template` (`template_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `template_name`, `diskspace`, `traffic`, `bandwidth`, `ram`, `ram_burst`, `cpu_units`, `cpu_num`, `cpu_limit`, `io_priority`, `active`, `description`, `numproc`, `numtcpsock`, `numothersock`, `vmguarpages`, `kmemsize`, `tcpsndbuf`, `tcprcvbuf`, `othersockbuf`, `dgramrcvbuf`, `oomguarpages`, `privvmpages`, `lockedpages`, `shmpages`, `physpages`, `numfile`, `avnumproc`, `numflock`, `numpty`, `numsiginfo`, `dcachesize`, `numiptent`, `swappages`, `hostname`, `nameserver`, `create_dns`, `capability`, `features`, `iptables`, `custom`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	'small',	10,	-1,	-1,	256,	512,	1000,	4,	400,	4,	'y',	'',	'999999:999999',	'7999992:7999992',	'7999992:7999992',	'65536:unlimited',	'2147483646:2147483646',	'214748160:396774400',	'214748160:396774400',	'214748160:396774400',	'214748160:396774400',	'65536:65536',	'131072:139264',	'999999:999999',	'65536:65536',	'0:2147483647',	'23999976:23999976',	'180:180',	'999999:999999',	'500000:500000',	'999999:999999',	'2147483646:2147483646',	'999999:999999',	'256000:256000',	'v{VEID}.test.tld',	'8.8.8.8 8.8.4.4',	'n',	'',	'',	'',	'');

DROP TABLE IF EXISTS `openvz_traffic`;
CREATE TABLE `openvz_traffic` (
  `veid` int(11) NOT NULL DEFAULT '0',
  `traffic_date` date DEFAULT NULL,
  `traffic_bytes` bigint(32) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `veid` (`veid`,`traffic_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `openvz_vm`;
CREATE TABLE `openvz_vm` (
  `vm_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `veid` int(10) unsigned NOT NULL DEFAULT '0',
  `ostemplate_id` int(11) NOT NULL DEFAULT '0',
  `template_id` int(11) NOT NULL DEFAULT '0',
  `ip_address` varchar(255) NOT NULL DEFAULT '',
  `hostname` varchar(255) DEFAULT NULL,
  `vm_password` varchar(255) DEFAULT NULL,
  `start_boot` varchar(255) NOT NULL DEFAULT 'y',
  `bootorder` int(11) NOT NULL DEFAULT '1',
  `active` varchar(255) NOT NULL DEFAULT 'y',
  `active_until_date` date DEFAULT NULL,
  `description` text,
  `diskspace` int(11) NOT NULL DEFAULT '0',
  `traffic` int(11) NOT NULL DEFAULT '-1',
  `bandwidth` int(11) NOT NULL DEFAULT '-1',
  `ram` int(11) NOT NULL DEFAULT '0',
  `ram_burst` int(11) NOT NULL DEFAULT '0',
  `cpu_units` int(11) NOT NULL DEFAULT '1000',
  `cpu_num` int(11) NOT NULL DEFAULT '4',
  `cpu_limit` int(11) NOT NULL DEFAULT '400',
  `io_priority` int(11) NOT NULL DEFAULT '4',
  `nameserver` varchar(255) NOT NULL DEFAULT '8.8.8.8 8.8.4.4',
  `create_dns` varchar(1) NOT NULL DEFAULT 'n',
  `capability` text,
  `features` text,
  `iptabless` text,
  `config` mediumtext,
  `custom` text,
  PRIMARY KEY (`vm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `remote_session`;
CREATE TABLE `remote_session` (
  `remote_session` varchar(64) NOT NULL DEFAULT '',
  `remote_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `remote_functions` text,
  `client_login` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `tstamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`remote_session`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `remote_user`;
CREATE TABLE `remote_user` (
  `remote_userid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `remote_username` varchar(64) NOT NULL DEFAULT '',
  `remote_password` varchar(64) NOT NULL DEFAULT '',
  `remote_access` enum('y','n') NOT NULL DEFAULT 'y',
  `remote_ips` text,
  `remote_functions` text,
  PRIMARY KEY (`remote_userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `server`;
CREATE TABLE `server` (
  `server_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_name` varchar(255) NOT NULL DEFAULT '',
  `mail_server` tinyint(1) NOT NULL DEFAULT '0',
  `web_server` tinyint(1) NOT NULL DEFAULT '0',
  `dns_server` tinyint(1) NOT NULL DEFAULT '0',
  `file_server` tinyint(1) NOT NULL DEFAULT '0',
  `db_server` tinyint(1) NOT NULL DEFAULT '0',
  `vserver_server` tinyint(1) NOT NULL DEFAULT '0',
  `proxy_server` tinyint(1) NOT NULL DEFAULT '0',
  `firewall_server` tinyint(1) NOT NULL DEFAULT '0',
  `xmpp_server` tinyint(1) NOT NULL DEFAULT '0',
  `config` text,
  `updated` bigint(20) unsigned NOT NULL DEFAULT '0',
  `mirror_server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `dbversion` int(11) unsigned NOT NULL DEFAULT '1',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `server` (`server_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `server_name`, `mail_server`, `web_server`, `dns_server`, `file_server`, `db_server`, `vserver_server`, `proxy_server`, `firewall_server`, `xmpp_server`, `config`, `updated`, `mirror_server_id`, `dbversion`, `active`) VALUES
(1,	1,	1,	'riud',	'riud',	'r',	'localhost',	1,	1,	0,	1,	1,	0,	0,	1,	0,	'[global]\nwebserver=apache\nmailserver=postfix\ndnsserver=mydns\n\n[server]\nauto_network_configuration=n\nip_address=192.168.0.1\nnetmask=255.255.255.0\nv6_prefix=\ngateway=0.0.0.0\nfirewall=bastille\nhostname=localhost.localdomain\nnameservers=1.1.1.1,1.0.0.1\nloglevel=2\nadmin_notify_events=1\nbackup_dir=/var/backup\nbackup_tmp=/tmp\nbackup_dir_is_mount=n\nbackup_mode=rootgz\nbackup_time=0:45\nbackup_delete=n\nmonit_url=\nmonit_user=\nmonit_password=\nmunin_url=\nmunin_user=\nmunin_password=\nmonitor_system_updates=y\nlog_retention=10\nmigration_mode=n\n\n[mail]\nmodule=postfix_mysql\nmaildir_path=/var/vmail/[domain]/[localpart]\nmaildir_format=maildir\nhomedir_path=/var/vmail\ncontent_filter=amavisd\nrspamd_password=KvrhbZwHE#W8\nrspamd_available=n\ndkim_path=/var/lib/amavis/dkim\ndkim_strength=1024\nrelayhost_password=\npop3_imap_daemon=dovecot\nmail_filter_syntax=sieve\nmailuser_uid=5000\nmailuser_gid=5000\nmailuser_name=vmail\nmailuser_group=vmail\nmailbox_virtual_uidgid_maps=n\nrelayhost=\nrelayhost_user=\nreject_sender_login_mismatch=n\nmailbox_size_limit=0\nmessage_size_limit=50\nmailbox_quota_stats=y\nrealtime_blackhole_list=zen.spamhaus.org\noverquota_notify_admin=y\noverquota_notify_client=y\noverquota_notify_freq=7\noverquota_notify_onok=n\n\n[getmail]\ngetmail_config_dir=/etc/getmail\n\n[web]\nserver_type=apache\nwebsite_basedir=/var/www\nwebsite_path=/var/www/clients/client[client_id]/web[website_id]\nwebsite_symlinks=/var/www/[website_domain]/:/var/www/clients/client[client_id]/[website_domain]/\nwebsite_symlinks_rel=n\nnetwork_filesystem=n\nwebsite_autoalias=\nvhost_rewrite_v6=n\nvhost_conf_dir=/etc/apache2/sites-available\nvhost_conf_enabled_dir=/etc/apache2/sites-enabled\nnginx_enable_pagespeed=n\nnginx_vhost_conf_dir=/etc/nginx/sites-available\nnginx_vhost_conf_enabled_dir=/etc/nginx/sites-enabled\nCA_path=\nCA_pass=\nsecurity_level=20\nset_folder_permissions_on_update=n\nweb_folder_protection=y\nadd_web_users_to_sshusers_group=y\ncheck_apache_config=y\nenable_sni=y\nenable_ip_wildcard=y\nlogging=yes\novertraffic_notify_admin=y\novertraffic_notify_client=y\noverquota_notify_admin=y\noverquota_notify_client=y\noverquota_db_notify_admin=y\noverquota_db_notify_client=y\noverquota_notify_freq=7\noverquota_notify_onok=n\nuser=www-data\ngroup=www-data\nconnect_userid_to_webid=n\nconnect_userid_to_webid_start=10000\nnginx_user=www-data\nnginx_group=www-data\nphp_ini_path_apache=/etc/php/7.3/apache2/php.ini\nphp_ini_path_cgi=/etc/php/7.3/cgi/php.ini\nphp_default_name=PHP7.3 (default)\nphp_fpm_init_script=php7.3-fpm\nphp_fpm_ini_path=/etc/php/7.3/fpm/php.ini\nphp_fpm_pool_dir=/etc/php/7.3/fpm/pool.d\nphp_fpm_start_port=9010\nphp_fpm_socket_dir=/var/lib/php7.3-fpm\nphp_open_basedir=[website_path]/web:[website_path]/private:[website_path]/tmp:/var/www/[website_domain]/web:/var/www/roundcube:/var/www/myadminer:/usr/share/php:/tmp:/dev/random:/dev/urandom\nphp_ini_check_minutes=1\nphp_handler=no\nphp_fpm_incron_reload=n\nnginx_cgi_socket=/var/run/fcgiwrap.socket\nhtaccess_allow_override=All\nenable_spdy=n\napps_vhost_enabled=y\napps_vhost_port=8081\napps_vhost_ip=_default_\napps_vhost_servername=\nawstats_conf_dir=/etc/awstats\nawstats_data_dir=/var/lib/awstats\nawstats_pl=/usr/lib/cgi-bin/awstats.pl\nawstats_buildstaticpages_pl=/usr/share/awstats/tools/awstats_buildstaticpages.pl\nskip_le_check=n\nphp_fpm_reload_mode=reload\n\n[dns]\nbind_user=root\nbind_group=bind\nbind_zonefiles_dir=/etc/bind\nnamed_conf_path=/etc/bind/named.conf\nnamed_conf_local_path=/etc/bind/named.conf.local\ndisable_bind_log=n\n\n[fastcgi]\nfastcgi_starter_path=/var/www/php-fcgi-scripts/[system_user]/\nfastcgi_starter_script=.php-fcgi-starter\nfastcgi_alias=/php/\nfastcgi_phpini_path=/etc/php/7.3/cgi/\nfastcgi_children=8\nfastcgi_max_requests=5000\nfastcgi_bin=/usr/bin/php-cgi\nfastcgi_config_syntax=2\n\n[jailkit]\njailkit_chroot_home=/home/[username]\njailkit_chroot_app_sections=basicshell editors extendedshell netutils ssh sftp scp groups jk_lsh\njailkit_chroot_app_programs=/usr/bin/groups /usr/bin/id /usr/bin/dircolors /usr/bin/lesspipe /usr/bin/basename /usr/bin/dirname /usr/bin/nano /usr/bin/pico /usr/bin/mysql /usr/bin/mysqldump /usr/bin/git /usr/bin/git-receive-pack /usr/bin/git-upload-pack /usr/bin/unzip /usr/bin/zip /bin/tar /bin/rm /usr/bin/patch\njailkit_chroot_cron_programs=/usr/bin/php /usr/bin/perl /usr/share/perl /usr/share/php\n\n[vlogger]\nconfig_dir=/etc\n\n[cron]\ninit_script=cron\ncrontab_dir=/etc/cron.d\nwget=/usr/bin/wget\n\n[rescue]\ntry_rescue=n\ndo_not_try_rescue_httpd=n\ndo_not_try_rescue_mongodb=n\ndo_not_try_rescue_mysql=n\ndo_not_try_rescue_mail=n\n\n[xmpp]\nxmpp_use_ipv6=n\nxmpp_bosh_max_inactivity=30\nxmpp_server_admins=admin@service.com, superuser@service.com\nxmpp_modules_enabled=saslauth, tls, dialback, disco, discoitems, version, uptime, time, ping, admin_adhoc, admin_telnet, bosh, posix, announce, offline, webpresence, mam, stream_management, message_carbons\nxmpp_port_http=5290\nxmpp_port_https=5291\nxmpp_port_pastebin=5292\nxmpp_port_bosh=5280\n\n',	0,	0,	88,	1);

DROP TABLE IF EXISTS `server_ip`;
CREATE TABLE `server_ip` (
  `server_ip_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `client_id` int(11) unsigned NOT NULL DEFAULT '0',
  `ip_type` enum('IPv4','IPv6') NOT NULL DEFAULT 'IPv4',
  `ip_address` varchar(39) DEFAULT NULL,
  `virtualhost` enum('n','y') NOT NULL DEFAULT 'y',
  `virtualhost_port` varchar(255) DEFAULT '80,443',
  PRIMARY KEY (`server_ip_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `server_ip` (`server_ip_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `server_id`, `client_id`, `ip_type`, `ip_address`, `virtualhost`, `virtualhost_port`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	1,	0,	'IPv4',	'192.168.0.1',	'y',	'80,443');

DROP TABLE IF EXISTS `server_ip_map`;
CREATE TABLE `server_ip_map` (
  `server_ip_map_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `source_ip` varchar(15) DEFAULT NULL,
  `destination_ip` varchar(35) DEFAULT '',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`server_ip_map_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `server_php`;
CREATE TABLE `server_php` (
  `server_php_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `client_id` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `php_fastcgi_binary` varchar(255) DEFAULT NULL,
  `php_fastcgi_ini_dir` varchar(255) DEFAULT NULL,
  `php_fpm_init_script` varchar(255) DEFAULT NULL,
  `php_fpm_ini_dir` varchar(255) DEFAULT NULL,
  `php_fpm_pool_dir` varchar(255) DEFAULT NULL,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`server_php_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `server_php` (`server_php_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `server_id`, `client_id`, `name`, `php_fastcgi_binary`, `php_fastcgi_ini_dir`, `php_fpm_init_script`, `php_fpm_ini_dir`, `php_fpm_pool_dir`, `active`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	1,	0,	'PHP5.6',	'php-cgi5.6',	'/etc/php/5.6/cgi/php.ini',	'php5.6-fpm',	'/etc/php/5.6/fpm/php.ini',	'/etc/php/5.6/fpm/pool.d',	'n'),
(2,	1,	1,	'riud',	'riud',	'',	1,	0,	'PHP7.0',	'php-cgi7.0',	'/etc/php/7.0/cgi/php.ini',	'php7.0-fpm',	'/etc/php/7.0/fpm/php.ini',	'/etc/php/7.0/fpm/pool.d',	'n'),
(3,	1,	1,	'riud',	'riud',	'',	1,	0,	'PHP7.1',	'php-cgi7.1',	'/etc/php/7.1/cgi/php.ini',	'php7.1-fpm',	'/etc/php/7.1/fpm/php.ini',	'/etc/php/7.1/fpm/pool.d',	'n'),
(4,	1,	1,	'riud',	'riud',	'',	1,	0,	'PHP7.2',	'php-cgi7.2',	'/etc/php/7.2/cgi/php.ini',	'php7.2-fpm',	'/etc/php/7.2/fpm/php.ini',	'/etc/php/7.2/fpm/pool.d',	'n'),
(5,	1,	1,	'riud',	'riud',	'',	1,	0,	'PHP7.3',	'php-cgi7.3',	'/etc/php/7.3/cgi/php.ini',	'php7.3-fpm',	'/etc/php/7.3/fpm/php.ini',	'/etc/php/7.3/fpm/pool.d',	'n'),
(6,	1,	1,	'riud',	'riud',	'',	1,	0,	'PHP7.4',	'php-cgi7.4',	'/etc/php/7.4/cgi/php.ini',	'php7.4-fpm',	'/etc/php/7.4/fpm/php.ini',	'/etc/php/7.4/fpm/pool.d',	'y');

DROP TABLE IF EXISTS `shell_user`;
CREATE TABLE `shell_user` (
  `shell_user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT '0',
  `username` varchar(64) DEFAULT NULL,
  `username_prefix` varchar(50) NOT NULL DEFAULT '',
  `password` varchar(200) DEFAULT NULL,
  `quota_size` bigint(20) NOT NULL DEFAULT '-1',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `puser` varchar(255) DEFAULT NULL,
  `pgroup` varchar(255) DEFAULT NULL,
  `shell` varchar(255) NOT NULL DEFAULT '/bin/bash',
  `dir` varchar(255) DEFAULT NULL,
  `chroot` varchar(255) NOT NULL DEFAULT '',
  `ssh_rsa` text,
  PRIMARY KEY (`shell_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `software_package`;
CREATE TABLE `software_package` (
  `package_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `software_repo_id` int(11) unsigned NOT NULL DEFAULT '0',
  `package_name` varchar(64) NOT NULL DEFAULT '',
  `package_title` varchar(64) NOT NULL DEFAULT '',
  `package_description` text,
  `package_version` varchar(8) DEFAULT NULL,
  `package_type` enum('ispconfig','app','web') NOT NULL DEFAULT 'app',
  `package_installable` enum('yes','no','key') NOT NULL DEFAULT 'yes',
  `package_requires_db` enum('no','mysql') NOT NULL DEFAULT 'no',
  `package_remote_functions` text,
  `package_key` varchar(255) NOT NULL DEFAULT '',
  `package_config` text,
  PRIMARY KEY (`package_id`),
  UNIQUE KEY `package_name` (`package_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `software_repo`;
CREATE TABLE `software_repo` (
  `software_repo_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `repo_name` varchar(64) DEFAULT NULL,
  `repo_url` varchar(255) DEFAULT NULL,
  `repo_username` varchar(64) DEFAULT NULL,
  `repo_password` varchar(64) DEFAULT NULL,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`software_repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `software_repo` (`software_repo_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `repo_name`, `repo_url`, `repo_username`, `repo_password`, `active`) VALUES
(1,	1,	1,	'riud',	'riud',	'',	'ISPConfig Addons',	'http://repo.ispconfig.org/addons/',	'',	'',	'n');

DROP TABLE IF EXISTS `software_update`;
CREATE TABLE `software_update` (
  `software_update_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `software_repo_id` int(11) unsigned NOT NULL DEFAULT '0',
  `package_name` varchar(64) NOT NULL DEFAULT '',
  `update_url` varchar(255) NOT NULL DEFAULT '',
  `update_md5` varchar(255) NOT NULL DEFAULT '',
  `update_dependencies` varchar(255) NOT NULL DEFAULT '',
  `update_title` varchar(64) NOT NULL DEFAULT '',
  `v1` tinyint(1) NOT NULL DEFAULT '0',
  `v2` tinyint(1) NOT NULL DEFAULT '0',
  `v3` tinyint(1) NOT NULL DEFAULT '0',
  `v4` tinyint(1) NOT NULL DEFAULT '0',
  `type` enum('full','update') NOT NULL DEFAULT 'full',
  PRIMARY KEY (`software_update_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `software_update_inst`;
CREATE TABLE `software_update_inst` (
  `software_update_inst_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `software_update_id` int(11) unsigned NOT NULL DEFAULT '0',
  `package_name` varchar(64) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `status` enum('none','installing','installed','deleting','deleted','failed') NOT NULL DEFAULT 'none',
  PRIMARY KEY (`software_update_inst_id`),
  UNIQUE KEY `software_update_id` (`software_update_id`,`package_name`,`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `spamfilter_policy`;
CREATE TABLE `spamfilter_policy` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `policy_name` varchar(64) DEFAULT NULL,
  `virus_lover` enum('N','Y') DEFAULT 'N',
  `spam_lover` enum('N','Y') DEFAULT 'N',
  `banned_files_lover` enum('N','Y') DEFAULT 'N',
  `bad_header_lover` enum('N','Y') DEFAULT 'N',
  `bypass_virus_checks` enum('N','Y') DEFAULT 'N',
  `bypass_spam_checks` enum('N','Y') DEFAULT 'N',
  `bypass_banned_checks` enum('N','Y') DEFAULT 'N',
  `bypass_header_checks` enum('N','Y') DEFAULT 'N',
  `spam_modifies_subj` enum('N','Y') DEFAULT 'N',
  `virus_quarantine_to` varchar(255) DEFAULT NULL,
  `spam_quarantine_to` varchar(255) DEFAULT NULL,
  `banned_quarantine_to` varchar(255) DEFAULT NULL,
  `bad_header_quarantine_to` varchar(255) DEFAULT NULL,
  `clean_quarantine_to` varchar(255) DEFAULT NULL,
  `other_quarantine_to` varchar(255) DEFAULT NULL,
  `spam_tag_level` decimal(5,2) DEFAULT NULL,
  `spam_tag2_level` decimal(5,2) DEFAULT NULL,
  `spam_kill_level` decimal(5,2) DEFAULT NULL,
  `spam_dsn_cutoff_level` decimal(5,2) DEFAULT NULL,
  `spam_quarantine_cutoff_level` decimal(5,2) DEFAULT NULL,
  `addr_extension_virus` varchar(64) DEFAULT NULL,
  `addr_extension_spam` varchar(64) DEFAULT NULL,
  `addr_extension_banned` varchar(64) DEFAULT NULL,
  `addr_extension_bad_header` varchar(64) DEFAULT NULL,
  `warnvirusrecip` enum('N','Y') DEFAULT 'N',
  `warnbannedrecip` enum('N','Y') DEFAULT 'N',
  `warnbadhrecip` enum('N','Y') DEFAULT 'N',
  `newvirus_admin` varchar(64) DEFAULT NULL,
  `virus_admin` varchar(64) DEFAULT NULL,
  `banned_admin` varchar(64) DEFAULT NULL,
  `bad_header_admin` varchar(64) DEFAULT NULL,
  `spam_admin` varchar(64) DEFAULT NULL,
  `spam_subject_tag` varchar(64) DEFAULT NULL,
  `spam_subject_tag2` varchar(64) DEFAULT NULL,
  `message_size_limit` int(11) unsigned DEFAULT NULL,
  `banned_rulenames` varchar(64) DEFAULT NULL,
  `policyd_quota_in` int(11) NOT NULL DEFAULT '-1',
  `policyd_quota_in_period` int(11) NOT NULL DEFAULT '24',
  `policyd_quota_out` int(11) NOT NULL DEFAULT '-1',
  `policyd_quota_out_period` int(11) NOT NULL DEFAULT '24',
  `policyd_greylist` enum('Y','N') NOT NULL DEFAULT 'N',
  `rspamd_greylisting` enum('n','y') NOT NULL DEFAULT 'n',
  `rspamd_spam_greylisting_level` decimal(5,2) DEFAULT NULL,
  `rspamd_spam_tag_level` decimal(5,2) DEFAULT NULL,
  `rspamd_spam_tag_method` enum('add_header','rewrite_subject') NOT NULL DEFAULT 'rewrite_subject',
  `rspamd_spam_kill_level` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `spamfilter_policy` (`id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `policy_name`, `virus_lover`, `spam_lover`, `banned_files_lover`, `bad_header_lover`, `bypass_virus_checks`, `bypass_spam_checks`, `bypass_banned_checks`, `bypass_header_checks`, `spam_modifies_subj`, `virus_quarantine_to`, `spam_quarantine_to`, `banned_quarantine_to`, `bad_header_quarantine_to`, `clean_quarantine_to`, `other_quarantine_to`, `spam_tag_level`, `spam_tag2_level`, `spam_kill_level`, `spam_dsn_cutoff_level`, `spam_quarantine_cutoff_level`, `addr_extension_virus`, `addr_extension_spam`, `addr_extension_banned`, `addr_extension_bad_header`, `warnvirusrecip`, `warnbannedrecip`, `warnbadhrecip`, `newvirus_admin`, `virus_admin`, `banned_admin`, `bad_header_admin`, `spam_admin`, `spam_subject_tag`, `spam_subject_tag2`, `message_size_limit`, `banned_rulenames`, `policyd_quota_in`, `policyd_quota_in_period`, `policyd_quota_out`, `policyd_quota_out_period`, `policyd_greylist`, `rspamd_greylisting`, `rspamd_spam_greylisting_level`, `rspamd_spam_tag_level`, `rspamd_spam_tag_method`, `rspamd_spam_kill_level`) VALUES
(1,	1,	0,	'riud',	'riud',	'r',	'Non-paying',	'N',	'N',	'N',	'N',	'Y',	'Y',	'Y',	'N',	'Y',	'',	'',	'',	'',	'',	'',	3.00,	7.00,	10.00,	0.00,	0.00,	'',	'',	'',	'',	'N',	'N',	'N',	'',	'',	'',	'',	'',	'',	'',	0,	'',	-1,	24,	-1,	24,	'N',	'n',	6.00,	8.00,	'rewrite_subject',	12.00),
(2,	1,	0,	'riud',	'riud',	'r',	'Uncensored',	'Y',	'Y',	'Y',	'Y',	'N',	'N',	'N',	'N',	'N',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	3.00,	999.00,	999.00,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	-1,	24,	-1,	24,	'N',	'n',	999.00,	999.00,	'rewrite_subject',	999.00),
(3,	1,	0,	'riud',	'riud',	'r',	'Wants all spam',	'N',	'Y',	'N',	'N',	'N',	'N',	'N',	'N',	'Y',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	3.00,	999.00,	999.00,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	-1,	24,	-1,	24,	'N',	'n',	999.00,	999.00,	'rewrite_subject',	999.00),
(4,	1,	0,	'riud',	'riud',	'r',	'Wants viruses',	'Y',	'N',	'Y',	'Y',	'N',	'N',	'N',	'N',	'Y',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	3.00,	6.90,	6.90,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	-1,	24,	-1,	24,	'N',	'y',	4.00,	6.00,	'rewrite_subject',	10.00),
(5,	1,	0,	'riud',	'riud',	'r',	'Normal',	'N',	'N',	'N',	'N',	'N',	'N',	'N',	'N',	'Y',	'',	'',	'',	'',	'',	'',	1.00,	4.50,	50.00,	0.00,	0.00,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	'',	'***SPAM***',	NULL,	NULL,	-1,	24,	-1,	24,	'N',	'y',	4.00,	6.00,	'rewrite_subject',	10.00),
(6,	1,	0,	'riud',	'riud',	'r',	'Trigger happy',	'N',	'N',	'N',	'N',	'N',	'N',	'N',	'N',	'Y',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	3.00,	5.00,	5.00,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	-1,	24,	-1,	24,	'N',	'y',	2.00,	4.00,	'rewrite_subject',	8.00),
(7,	1,	0,	'riud',	'riud',	'r',	'Permissive',	'N',	'N',	'N',	'Y',	'N',	'N',	'N',	'N',	'Y',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	3.00,	10.00,	20.00,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	-1,	24,	-1,	24,	'N',	'n',	7.00,	10.00,	'rewrite_subject',	20.00);

DROP TABLE IF EXISTS `spamfilter_users`;
CREATE TABLE `spamfilter_users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `priority` tinyint(3) unsigned NOT NULL DEFAULT '7',
  `policy_id` int(11) unsigned NOT NULL DEFAULT '1',
  `email` varchar(255) NOT NULL DEFAULT '',
  `fullname` varchar(64) DEFAULT NULL,
  `local` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `spamfilter_wblist`;
CREATE TABLE `spamfilter_wblist` (
  `wblist_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `wb` enum('W','B') NOT NULL DEFAULT 'W',
  `rid` int(11) unsigned NOT NULL DEFAULT '0',
  `email` varchar(255) NOT NULL DEFAULT '',
  `priority` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `active` enum('y','n') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`wblist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `support_message`;
CREATE TABLE `support_message` (
  `support_message_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `recipient_id` int(11) unsigned NOT NULL DEFAULT '0',
  `sender_id` int(11) unsigned NOT NULL DEFAULT '0',
  `subject` varchar(255) DEFAULT NULL,
  `message` text,
  `tstamp` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`support_message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `group` varchar(64) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`group`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `sys_config` (`group`, `name`, `value`) VALUES
('db',	'db_version',	'3.1.15p3'),
('interface',	'session_timeout',	'30');

DROP TABLE IF EXISTS `sys_cron`;
CREATE TABLE `sys_cron` (
  `name` varchar(50) NOT NULL DEFAULT '',
  `last_run` datetime DEFAULT NULL,
  `next_run` datetime DEFAULT NULL,
  `running` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_datalog`;
CREATE TABLE `sys_datalog` (
  `datalog_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `dbtable` varchar(255) NOT NULL DEFAULT '',
  `dbidx` varchar(255) NOT NULL DEFAULT '',
  `action` char(1) NOT NULL DEFAULT '',
  `tstamp` int(11) NOT NULL DEFAULT '0',
  `user` varchar(255) NOT NULL DEFAULT '',
  `data` longtext,
  `status` set('pending','ok','warning','error') NOT NULL DEFAULT 'ok',
  `error` mediumtext,
  `session_id` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`datalog_id`),
  KEY `server_id` (`server_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_dbsync`;
CREATE TABLE `sys_dbsync` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `jobname` varchar(64) NOT NULL DEFAULT '',
  `sync_interval_minutes` int(11) unsigned NOT NULL DEFAULT '0',
  `db_type` varchar(16) NOT NULL DEFAULT '',
  `db_host` varchar(255) NOT NULL DEFAULT '',
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `db_username` varchar(64) NOT NULL DEFAULT '',
  `db_password` varchar(64) NOT NULL DEFAULT '',
  `db_tables` varchar(255) NOT NULL DEFAULT 'admin,forms',
  `empty_datalog` int(11) unsigned NOT NULL DEFAULT '0',
  `sync_datalog_external` int(11) unsigned NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `last_datalog_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `last_datalog_id` (`last_datalog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_filesync`;
CREATE TABLE `sys_filesync` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `jobname` varchar(64) NOT NULL DEFAULT '',
  `sync_interval_minutes` int(11) unsigned NOT NULL DEFAULT '0',
  `ftp_host` varchar(255) NOT NULL DEFAULT '',
  `ftp_path` varchar(255) NOT NULL DEFAULT '',
  `ftp_username` varchar(64) NOT NULL DEFAULT '',
  `ftp_password` varchar(64) NOT NULL DEFAULT '',
  `local_path` varchar(255) NOT NULL DEFAULT '',
  `wput_options` varchar(255) NOT NULL DEFAULT '--timestamping --reupload --dont-continue',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_group`;
CREATE TABLE `sys_group` (
  `groupid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL DEFAULT '',
  `description` text,
  `client_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`groupid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `sys_group` (`groupid`, `name`, `description`, `client_id`) VALUES
(1,	'admin',	'Administrators group',	0),
(2,	'system',	'',	1);

DROP TABLE IF EXISTS `sys_ini`;
CREATE TABLE `sys_ini` (
  `sysini_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `config` longtext,
  `default_logo` text NOT NULL,
  `custom_logo` text NOT NULL,
  PRIMARY KEY (`sysini_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `sys_ini` (`sysini_id`, `config`, `default_logo`, `custom_logo`) VALUES
(1,	'[mail]\nenable_custom_login=n\nmailbox_show_autoresponder_tab=y\nmailbox_show_mail_filter_tab=y\nmailbox_show_custom_rules_tab=y\nmailboxlist_webmail_link=y\nwebmail_url=/webmail\nmailmailinglist_link=n\nmailmailinglist_url=\nadmin_mail=root\nadmin_name=Administrator\nsmtp_enabled=y\nsmtp_host=localhost\nsmtp_port=\nsmtp_user=\nsmtp_pass=\nsmtp_crypt=\ndefault_mailserver=1\n\n[sites]\ndbname_prefix=c[CLIENTID]\ndbuser_prefix=c[CLIENTID]\nftpuser_prefix=[CLIENTNAME]\nshelluser_prefix=[CLIENTNAME]\nwebdavuser_prefix=[CLIENTNAME]\ndblist_phpmyadmin_link=y\nphpmyadmin_url=/phpmyadmin\nwebftp_url=\nvhost_subdomains=n\nvhost_aliasdomains=n\nclient_username_web_check_disabled=n\nbackups_include_into_web_quota=n\nreseller_can_use_options=n\ndefault_webserver=1\ndefault_dbserver=1\nweb_php_options=no,fast-cgi,mod,php-fpm\n\n[domains]\nuse_domain_module=n\nnew_domain_html=Please contact our support to create a new domain for you.\n\n[misc]\ncompany_name=\ncustom_login_text=\ncustom_login_link=\ndashboard_atom_url_admin=https://www.ispconfig.org/atom\ndashboard_atom_url_reseller=https://www.ispconfig.org/atom\ndashboard_atom_url_client=https://www.ispconfig.org/atom\nmonitor_key=\ntab_change_discard=n\ntab_change_warning=n\nuse_loadindicator=y\nuse_combobox=y\nmaintenance_mode=n\nadmin_dashlets_left=\nadmin_dashlets_right=\nreseller_dashlets_left=\nreseller_dashlets_right=\nclient_dashlets_left=\nclient_dashlets_right=\ncustomer_no_template=C[CUSTOMER_NO]\ncustomer_no_start=1\ncustomer_no_counter=0\nsession_timeout=30\nsession_allow_endless=y\nmin_password_length=6\nmin_password_strength=2\n\n[dns]\ndefault_dnsserver=0\ndefault_slave_dnsserver=0\n\n',	'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAABBCAYAAACU5+uOAAAItUlEQVR42u1dCWwVVRStUJZCK6HsFNAgWpaCJkKICZKApKUFhURQpEnZF4EEUJZYEEpBIamgkQpUQBZRW7YCBqQsggsQEAgKLbIGCYsSCNqyQ8D76h18Hd/MvJk/n/bXc5KT+TNz79vPzNv+/2FhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOAe++s0akTsRZxMnE6cGkKcxkwhPofaBPwWRzxxB/EO8UGI8xhxEGoV8EscY8qBKFRcgdoFAhXHC+VUHAbHo5aBQASyrZwL5DoxEjUNeBXI9XIuEMEE1DTgVSA3FA3qIDEtBLnTQiBDUNOAV4EUKhpURojmZQQEAjwKgSwK0bykWQgEU74ABAKBABAIBOIJffoNrkRsS0whDiMO5uNw4gBiSxvfGOJrbDtMOgr2JNa18HmZmETsopnGp4h9xdF0TcQRb8NEPkawTzv2qaWIoybnZYRUBoJD+difGAuBlCy0qsRM4mfERcTFfGygsBUF/xFxE/EQ8RixwIbi/j7il8R3iE8qwuxAXMJxuuFiTvNMYleb/E0gXiI+cOBaISTJrzLxcw2/+8Q5pjjfNNkM0RDILLadpbimw+bsc4DPkxRpuqkZ1orisoBAiguuhkUhPSvZRBA3u6gsK94g9jDFP9aHcAV3EKNNYX8i3RcNJ4M4nTiROJCYykIzbGZKvouk68vYbyS/cUbz+RrJZpzkO5Sv3eajaJhRDvUwg21nKK4VcF5WKPgFH6PZZw/7dJXC6S6lczunfbIQLpeDkZ+lJcoCAikuvChioaLBtfD4JHPiXSFKKexBPoa9Wwr3ael6skMZDGO7K3z+uOSb5OA7mu2KiOGmPH3ADVh8/sohnDS2S1NcG+uiO/kd+8RL146YRWzj359tb0Eg+gIpsHkjFNrQqiF3DZJABDtyuCP5/FuNRlHN8Ofz9nx+XLNR3jR1c4w8TSFGSmnr4FEgU7wKhI51jAeTpv+/ZQGBOAuEu1d/Ku6LV35t9rdigkUjHuMgkHPEecQsxdjjUx4zHbMI+10OdzqfZ2o0iiqSfzgPfMXnzZqN6iTbJ5jytMTU0E97FEhaAAJ5kc/PuJjQOCoIgegJpKbUl5b5vGaBT+A+vOgn5/JYIdFBIOs1wo1kIZl93+P70/h8oUZYFXkmKInPU9h3m2YeT8lvRilPyyWbi3xt4iMWSDc+P4lp3uAIRDxdryjui6dmuujXcr91IDcMmaJv31WISfTrLeJXCUT3yb1a4Ztmalyu61MaZG/XtD9tapRGnpZKNp2lNNZ3KZARAQgk3untBYEEPgbJ92FsIAax34v1AQ2B5Go2BlW60n0QyCC/BWISdJ5LgewWU8k86DdTzMyNh0BKVyAzfB5I93YQyBGeTlW9lQbwIle2Rdgzy7BAxJT6Hb6X6EIgTrznRSCiHli02cwcPor1pbkQiL5AKvOA+ZZPAtkfxFms3j4IZHAwBGJaRPxdjH00BSImJRqKOlEwjtjUo0Dm2pWla4HMzsyqQIxSMKI8C8RkL9YXuhDf5gqcw4NweaZJiGkh8UeLwi+Utkb4KZCrYszkVSDiQRDMN4hkf5DvZ2gKZJyLPJgFkmAjEDEF3EYSWzPeklO8Q8CLQGKJhQquK+eDdLFNZBJxFLEf8XUXFTbcYv2kRhAEIq+vGNO88zTTKVaRzxPrSSvPW11O8yZqCiROSnMsX0sP0ixWops1Hfbx/AaJIz5QcFc5n+ZVNcbxmoWtEsBNB4EU8Tgk32Gv1wneEybeWG1N8RoNbplmOo2neiyxE3/eoun7G9t31hGIqXuzl8/HB0kgxhvhD03/KoEIpIWFQPLK+UJhkWpgKLZP8IKhajNhJg8A7yt8/5K6QoFM8z5mc68Ph3VWM6wTbN+a+AR/vqThV13KYyMXAgmXps9FnK8GSSA17KaXFf7R3gUyd8H/TiBss9fngfQehzfMpkDLgxcS73J4k1y85WrxtTtOjZPuVZA2O55RhLfUId5XpI2UHwZDIHxtp7HtRrVL25SfhWy7z7VAMuYvipszd0FJcfxzHspdrMctGnGcZNPTZ4F0VszqyPSlPHm8JG9f2SDtgF3Nq/rnJZssyXeUdP0CN64c9l/FDfGyZNNNkaeVGmnMM+Vdtd19los8/2e7Ow/E70lxiG7pRmkn8AaeULlcoo4sBDLfKvL0nLUxablfX0hfmfuQ01avI65fUQYEkupRIJHcAMwbDWNNdmLgupV4zeMO3stcIZ1M4aYo4vZt0oO7Locd0ndGTEQofN+QxiZ22+y7W+RpgUb66vOU7232SZXupZqvaYT3Dfu8ZLrejtc47mvkJ9FoVEWKBmW7dyc7ZXD1Nb2TH3JVn5Tqa3r1repzY6/gwWeqhUCGO/XjWSTmjYYVLOzFoP0Z/qJTks033brxrtjmxCbGtK4ivEqKuH2fNuc0tDatIYgna4yGbz2eeTL8WhJbic2aDnmqqpm2KlLeK5vWn0pc0wirGvtUtBkzNdPKDzWe24oGdZX4CzGfWCD4U93GBQdqNSw4Uiny8K9h4buOhlU2scq+Q1G1i233k63hFwBPEfcS04l1FGJoynbH+fgz8ZKFQJLDAMDjk/psCPzw20XxE6mmdLd24d8KNQ14FciUEPl1xHvEhlK6W2j65aOWgUAEUpV4NEREstyDQNqjloFARVKL/xukrAvkGjGC09zGwfYKsQdqF/BTKMnEJcTtxC3EPAU3iic5cRkfjc/ZFvZuuZm4gXjOouG35LQ2Yfutkq/4pfpN/E9TDVCjQGkJqQExho+CjYlRPseRiQE3EIriaMZTw4K3mOJv23J8jme23RsEAMqqQJrb9PnnEbPEVpUAuJD4Mf/PoCqeONQCUJYFElGKf7ojpnqjUQtAWRdJaf1t2w8ofSAUBNKulATSEaUPhIpIRj9icbyFUgdCTSRTeR0i2HwfpQ0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQBnG392D9QU+JXhxAAAAAElFTkSuQmCC',	'');

DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log` (
  `syslog_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `datalog_id` int(11) unsigned NOT NULL DEFAULT '0',
  `loglevel` tinyint(4) NOT NULL DEFAULT '0',
  `tstamp` int(11) unsigned NOT NULL DEFAULT '0',
  `message` text,
  PRIMARY KEY (`syslog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_remoteaction`;
CREATE TABLE `sys_remoteaction` (
  `action_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `tstamp` int(11) NOT NULL DEFAULT '0',
  `action_type` varchar(20) NOT NULL DEFAULT '',
  `action_param` mediumtext,
  `action_state` enum('pending','ok','warning','error') NOT NULL DEFAULT 'pending',
  `response` mediumtext,
  PRIMARY KEY (`action_id`),
  KEY `server_id` (`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_session`;
CREATE TABLE `sys_session` (
  `session_id` varchar(64) NOT NULL DEFAULT '',
  `date_created` datetime DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `permanent` enum('n','y') NOT NULL DEFAULT 'n',
  `session_data` longtext,
  PRIMARY KEY (`session_id`),
  KEY `last_updated` (`last_updated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `sys_theme`;
CREATE TABLE `sys_theme` (
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `var_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tpl_name` varchar(32) NOT NULL DEFAULT '',
  `username` varchar(64) NOT NULL DEFAULT '',
  `logo_url` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`var_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `sys_theme` (`sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `var_id`, `tpl_name`, `username`, `logo_url`) VALUES
(0,	0,	NULL,	NULL,	NULL,	1,	'default',	'global',	'themes/default/images/header_logo.png'),
(0,	0,	NULL,	NULL,	NULL,	2,	'default-v2',	'global',	'themes/default-v2/images/header_logo.png');

DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `userid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '1' COMMENT 'Created by userid',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '1' COMMENT 'Created by groupid',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT 'riud',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT 'riud',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `username` varchar(64) NOT NULL DEFAULT '',
  `passwort` varchar(200) NOT NULL DEFAULT '',
  `modules` varchar(255) NOT NULL DEFAULT '',
  `startmodule` varchar(255) NOT NULL DEFAULT '',
  `app_theme` varchar(32) NOT NULL DEFAULT 'default',
  `typ` varchar(16) NOT NULL DEFAULT 'user',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `language` varchar(2) NOT NULL DEFAULT 'en',
  `groups` text,
  `default_group` int(11) unsigned NOT NULL DEFAULT '0',
  `client_id` int(11) unsigned NOT NULL DEFAULT '0',
  `id_rsa` varchar(2000) NOT NULL DEFAULT '',
  `ssh_rsa` varchar(600) NOT NULL DEFAULT '',
  `lost_password_function` tinyint(1) NOT NULL DEFAULT '1',
  `lost_password_hash` varchar(50) NOT NULL DEFAULT '',
  `lost_password_reqtime` datetime DEFAULT NULL,
  PRIMARY KEY (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `sys_user` (`userid`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `username`, `passwort`, `modules`, `startmodule`, `app_theme`, `typ`, `active`, `language`, `groups`, `default_group`, `client_id`, `id_rsa`, `ssh_rsa`, `lost_password_function`, `lost_password_hash`, `lost_password_reqtime`) VALUES
(1,	1,	0,	'riud',	'riud',	'',	'admin',	'$1$1quxqe5A$qRs/o16Nw9Nn5FkCsJNiD1',	'monitor,client,sites,mail,dashboard,help,admin,tools,dns',	'client',	'default',	'admin',	1,	'en',	'1,2',	1,	0,	'',	'',	1,	'',	NULL),
(2,	1,	1,	'riud',	'riud',	'',	'system',	'$1$qJtlmocM$BY44JyCcsKzQiXpGH2yHF1',	'sites,mail,help,tools',	'sites',	'default',	'user',	1,	'en',	'2',	2,	1,	'',	'',	1,	'',	NULL);

DROP TABLE IF EXISTS `webdav_user`;
CREATE TABLE `webdav_user` (
  `webdav_user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT '0',
  `username` varchar(64) DEFAULT NULL,
  `username_prefix` varchar(50) NOT NULL DEFAULT '',
  `password` varchar(200) DEFAULT NULL,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `dir` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`webdav_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `web_backup`;
CREATE TABLE `web_backup` (
  `backup_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(10) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(10) unsigned NOT NULL DEFAULT '0',
  `backup_type` enum('web','mysql','mongodb') NOT NULL DEFAULT 'web',
  `backup_mode` varchar(64) NOT NULL DEFAULT '',
  `tstamp` int(10) unsigned NOT NULL DEFAULT '0',
  `filename` varchar(255) NOT NULL DEFAULT '',
  `filesize` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`backup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `web_database`;
CREATE TABLE `web_database` (
  `database_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT '0',
  `type` varchar(16) NOT NULL DEFAULT 'y',
  `database_name` varchar(64) DEFAULT NULL,
  `database_name_prefix` varchar(50) NOT NULL DEFAULT '',
  `database_quota` int(11) DEFAULT NULL,
  `quota_exceeded` enum('n','y') NOT NULL DEFAULT 'n',
  `last_quota_notification` date DEFAULT NULL,
  `database_user_id` int(11) unsigned DEFAULT NULL,
  `database_ro_user_id` int(11) unsigned DEFAULT NULL,
  `database_charset` varchar(64) DEFAULT NULL,
  `remote_access` enum('n','y') NOT NULL DEFAULT 'y',
  `remote_ips` text,
  `backup_interval` varchar(255) NOT NULL DEFAULT 'none',
  `backup_copies` int(11) NOT NULL DEFAULT '1',
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`database_id`),
  KEY `database_user_id` (`database_user_id`),
  KEY `database_ro_user_id` (`database_ro_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `web_database_user`;
CREATE TABLE `web_database_user` (
  `database_user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `database_user` varchar(64) DEFAULT NULL,
  `database_user_prefix` varchar(50) NOT NULL DEFAULT '',
  `database_password` varchar(64) DEFAULT NULL,
  `database_password_mongo` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`database_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `web_domain`;
CREATE TABLE `web_domain` (
  `domain_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `ip_address` varchar(39) DEFAULT NULL,
  `ipv6_address` varchar(255) DEFAULT NULL,
  `domain` varchar(255) DEFAULT NULL,
  `type` varchar(32) DEFAULT NULL,
  `parent_domain_id` int(11) unsigned NOT NULL DEFAULT '0',
  `vhost_type` varchar(32) DEFAULT NULL,
  `document_root` varchar(255) DEFAULT NULL,
  `web_folder` varchar(100) DEFAULT NULL,
  `system_user` varchar(255) DEFAULT NULL,
  `system_group` varchar(255) DEFAULT NULL,
  `hd_quota` bigint(20) NOT NULL DEFAULT '0',
  `traffic_quota` bigint(20) NOT NULL DEFAULT '-1',
  `cgi` enum('n','y') NOT NULL DEFAULT 'y',
  `ssi` enum('n','y') NOT NULL DEFAULT 'y',
  `suexec` enum('n','y') NOT NULL DEFAULT 'y',
  `errordocs` tinyint(1) NOT NULL DEFAULT '1',
  `is_subdomainwww` tinyint(1) NOT NULL DEFAULT '1',
  `subdomain` enum('none','www','*') NOT NULL DEFAULT 'none',
  `php` varchar(32) NOT NULL DEFAULT 'y',
  `ruby` enum('n','y') NOT NULL DEFAULT 'n',
  `python` enum('n','y') NOT NULL DEFAULT 'n',
  `perl` enum('n','y') NOT NULL DEFAULT 'n',
  `redirect_type` varchar(255) DEFAULT NULL,
  `redirect_path` varchar(255) DEFAULT NULL,
  `seo_redirect` varchar(255) DEFAULT NULL,
  `rewrite_to_https` enum('y','n') NOT NULL DEFAULT 'n',
  `ssl` enum('n','y') NOT NULL DEFAULT 'n',
  `ssl_letsencrypt` enum('n','y') NOT NULL DEFAULT 'n',
  `ssl_letsencrypt_exclude` enum('n','y') NOT NULL DEFAULT 'n',
  `ssl_state` varchar(255) DEFAULT NULL,
  `ssl_locality` varchar(255) DEFAULT NULL,
  `ssl_organisation` varchar(255) DEFAULT NULL,
  `ssl_organisation_unit` varchar(255) DEFAULT NULL,
  `ssl_country` varchar(255) DEFAULT NULL,
  `ssl_domain` varchar(255) DEFAULT NULL,
  `ssl_request` mediumtext,
  `ssl_cert` mediumtext,
  `ssl_bundle` mediumtext,
  `ssl_key` mediumtext,
  `ssl_action` varchar(16) DEFAULT NULL,
  `stats_password` varchar(255) DEFAULT NULL,
  `stats_type` varchar(255) DEFAULT 'awstats',
  `allow_override` varchar(255) NOT NULL DEFAULT 'All',
  `apache_directives` mediumtext,
  `nginx_directives` mediumtext,
  `php_fpm_use_socket` enum('n','y') NOT NULL DEFAULT 'y',
  `php_fpm_chroot` enum('n','y') NOT NULL DEFAULT 'n',
  `pm` enum('static','dynamic','ondemand') NOT NULL DEFAULT 'dynamic',
  `pm_max_children` int(11) NOT NULL DEFAULT '4',
  `pm_start_servers` int(11) NOT NULL DEFAULT '1',
  `pm_min_spare_servers` int(11) NOT NULL DEFAULT '1',
  `pm_max_spare_servers` int(11) NOT NULL DEFAULT '2',
  `pm_process_idle_timeout` int(11) NOT NULL DEFAULT '10',
  `pm_max_requests` int(11) NOT NULL DEFAULT '0',
  `php_open_basedir` mediumtext,
  `custom_php_ini` mediumtext,
  `backup_interval` varchar(255) NOT NULL DEFAULT 'none',
  `backup_copies` int(11) NOT NULL DEFAULT '1',
  `backup_excludes` mediumtext,
  `active` enum('n','y') NOT NULL DEFAULT 'y',
  `traffic_quota_lock` enum('n','y') NOT NULL DEFAULT 'n',
  `fastcgi_php_version` varchar(255) DEFAULT NULL,
  `proxy_directives` mediumtext,
  `enable_spdy` enum('y','n') DEFAULT 'n',
  `last_quota_notification` date DEFAULT NULL,
  `rewrite_rules` mediumtext,
  `added_date` date DEFAULT NULL,
  `added_by` varchar(255) DEFAULT NULL,
  `directive_snippets_id` int(11) unsigned NOT NULL DEFAULT '0',
  `enable_pagespeed` enum('y','n') NOT NULL DEFAULT 'n',
  `http_port` int(11) unsigned NOT NULL DEFAULT '80',
  `https_port` int(11) unsigned NOT NULL DEFAULT '443',
  `folder_directive_snippets` text,
  `log_retention` int(11) NOT NULL DEFAULT '10',
  PRIMARY KEY (`domain_id`),
  UNIQUE KEY `serverdomain` (`server_id`,`ip_address`,`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `web_domain` (`domain_id`, `sys_userid`, `sys_groupid`, `sys_perm_user`, `sys_perm_group`, `sys_perm_other`, `server_id`, `ip_address`, `ipv6_address`, `domain`, `type`, `parent_domain_id`, `vhost_type`, `document_root`, `web_folder`, `system_user`, `system_group`, `hd_quota`, `traffic_quota`, `cgi`, `ssi`, `suexec`, `errordocs`, `is_subdomainwww`, `subdomain`, `php`, `ruby`, `python`, `perl`, `redirect_type`, `redirect_path`, `seo_redirect`, `rewrite_to_https`, `ssl`, `ssl_letsencrypt`, `ssl_letsencrypt_exclude`, `ssl_state`, `ssl_locality`, `ssl_organisation`, `ssl_organisation_unit`, `ssl_country`, `ssl_domain`, `ssl_request`, `ssl_cert`, `ssl_bundle`, `ssl_key`, `ssl_action`, `stats_password`, `stats_type`, `allow_override`, `apache_directives`, `nginx_directives`, `php_fpm_use_socket`, `php_fpm_chroot`, `pm`, `pm_max_children`, `pm_start_servers`, `pm_min_spare_servers`, `pm_max_spare_servers`, `pm_process_idle_timeout`, `pm_max_requests`, `php_open_basedir`, `custom_php_ini`, `backup_interval`, `backup_copies`, `backup_excludes`, `active`, `traffic_quota_lock`, `fastcgi_php_version`, `proxy_directives`, `enable_spdy`, `last_quota_notification`, `rewrite_rules`, `added_date`, `added_by`, `directive_snippets_id`, `enable_pagespeed`, `http_port`, `https_port`, `folder_directive_snippets`, `log_retention`) VALUES
(1,	1,	2,	'riud',	'ru',	'',	1,	'*',	'',	'all.mail',	'vhost',	0,	'name',	'/var/www/clients/client1/web1',	'',	'web1',	'client1',	-1,	-1,	'n',	'n',	'y',	1,	1,	'none',	'php-fpm',	'n',	'n',	'n',	'',	'',	'',	'n',	'n',	'n',	'n',	'',	'',	'',	'',	'AF',	'all.mail',	'',	'',	'',	'',	'',	NULL,	'awstats',	'All',	'DocumentRoot /var/www/roundcube\r\nServerAlias mail.* *.mail.* imap.* *.imap.* smtp.* *.smtp.*\r\nDirectoryIndex index.php index.html',	'',	'y',	'n',	'dynamic',	4,	1,	1,	2,	10,	0,	'/var/www/clients/client1/web1/web:/var/www/clients/client1/web1/private:/var/www/clients/client1/web1/tmp:/var/www/all.mail/web:/var/www/roundcube:/var/www/myadminer:/usr/share/php:/tmp:/dev/random:/dev/urandom',	';# custom settings\r\nmemory_limit = 128M\r\npost_max_size = 34M\r\nupload_max_filesize = 32M\r\nsuhosin.session.encrypt = Off\r\nsession.save_path = \"/var/www/clients/client1/web1/tmp\"\r\n;# /custom settings',	'none',	1,	'',	'y',	'n',	'',	'',	'n',	NULL,	'',	'2019-05-12',	'admin',	0,	'n',	80,	443,	NULL,	10);

DROP TABLE IF EXISTS `web_folder`;
CREATE TABLE `web_folder` (
  `web_folder_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `parent_domain_id` int(11) NOT NULL DEFAULT '0',
  `path` varchar(255) DEFAULT NULL,
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`web_folder_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `web_folder_user`;
CREATE TABLE `web_folder_user` (
  `web_folder_user_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) NOT NULL DEFAULT '0',
  `sys_groupid` int(11) NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) DEFAULT NULL,
  `sys_perm_group` varchar(5) DEFAULT NULL,
  `sys_perm_other` varchar(5) DEFAULT NULL,
  `server_id` int(11) NOT NULL DEFAULT '0',
  `web_folder_id` int(11) NOT NULL DEFAULT '0',
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `active` varchar(255) NOT NULL DEFAULT 'y',
  PRIMARY KEY (`web_folder_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `web_traffic`;
CREATE TABLE `web_traffic` (
  `hostname` varchar(255) NOT NULL DEFAULT '',
  `traffic_date` date DEFAULT NULL,
  `traffic_bytes` bigint(32) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `hostname` (`hostname`,`traffic_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `xmpp_domain`;
CREATE TABLE `xmpp_domain` (
  `domain_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `domain` varchar(255) NOT NULL DEFAULT '',
  `management_method` enum('normal','maildomain') NOT NULL DEFAULT 'normal',
  `public_registration` enum('n','y') NOT NULL DEFAULT 'n',
  `registration_url` varchar(255) NOT NULL DEFAULT '',
  `registration_message` varchar(255) NOT NULL DEFAULT '',
  `domain_admins` text,
  `use_pubsub` enum('n','y') NOT NULL DEFAULT 'n',
  `use_proxy` enum('n','y') NOT NULL DEFAULT 'n',
  `use_anon_host` enum('n','y') NOT NULL DEFAULT 'n',
  `use_vjud` enum('n','y') NOT NULL DEFAULT 'n',
  `vjud_opt_mode` enum('in','out') NOT NULL DEFAULT 'in',
  `use_muc_host` enum('n','y') NOT NULL DEFAULT 'n',
  `muc_name` varchar(30) NOT NULL DEFAULT '',
  `muc_restrict_room_creation` enum('n','y','m') NOT NULL DEFAULT 'm',
  `muc_admins` text,
  `use_pastebin` enum('n','y') NOT NULL DEFAULT 'n',
  `pastebin_expire_after` int(3) NOT NULL DEFAULT '48',
  `pastebin_trigger` varchar(10) NOT NULL DEFAULT '!paste',
  `use_http_archive` enum('n','y') NOT NULL DEFAULT 'n',
  `http_archive_show_join` enum('n','y') NOT NULL DEFAULT 'n',
  `http_archive_show_status` enum('n','y') NOT NULL DEFAULT 'n',
  `use_status_host` enum('n','y') NOT NULL DEFAULT 'n',
  `ssl_state` varchar(255) DEFAULT NULL,
  `ssl_locality` varchar(255) DEFAULT NULL,
  `ssl_organisation` varchar(255) DEFAULT NULL,
  `ssl_organisation_unit` varchar(255) DEFAULT NULL,
  `ssl_country` varchar(255) DEFAULT NULL,
  `ssl_email` varchar(255) DEFAULT NULL,
  `ssl_request` mediumtext,
  `ssl_cert` mediumtext,
  `ssl_bundle` mediumtext,
  `ssl_key` mediumtext,
  `ssl_action` varchar(16) DEFAULT NULL,
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`domain_id`),
  KEY `server_id` (`server_id`,`domain`),
  KEY `domain_active` (`domain`,`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `xmpp_user`;
CREATE TABLE `xmpp_user` (
  `xmppuser_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sys_userid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_groupid` int(11) unsigned NOT NULL DEFAULT '0',
  `sys_perm_user` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_group` varchar(5) NOT NULL DEFAULT '',
  `sys_perm_other` varchar(5) NOT NULL DEFAULT '',
  `server_id` int(11) unsigned NOT NULL DEFAULT '0',
  `jid` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `active` enum('n','y') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`xmppuser_id`),
  KEY `server_id` (`server_id`,`jid`),
  KEY `jid_active` (`jid`,`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 2020-02-24 18:42:48
