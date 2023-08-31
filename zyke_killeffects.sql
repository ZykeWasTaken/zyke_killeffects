CREATE TABLE IF NOT EXISTS `zyke_killeffects` (
  `identifier` char(50) DEFAULT NULL,
  `unlocked` text DEFAULT NULL,
  `selectedEffect` tinytext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;