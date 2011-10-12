INSERT INTO `subscription_numberpatterns` (`id`, `label`, `displayorder`, `description`, `numberingmethod`, `label1`, `basedon1`, `add1`, `every1`, `whenmorethan1`, `setto1`, `numbering1`, `label2`, `basedon2`, `add2`, `every2`, `whenmorethan2`, `setto2`, `numbering2`, `label3`, `basedon3`, `add3`, `every3`, `whenmorethan3`, `setto3`, `numbering3`) VALUES
    (1, 'Number', 1, 'Simple Numbering method', 'No.{X}', 'Number', NULL, 1, 1, 99999, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (2, 'Volume, Number, Issue', 2, 'Volume Number Issue 1', 'Vol.{X}, Number {Y}, Issue {Z}', 'Volume', NULL, 1, 48, 99999, 1, NULL, 'Number', NULL, 1, 4, 12, 1, NULL, 'Issue', NULL, 1, 1, 4, 1, NULL),
    (3, 'Volume, Number', 3, 'Volume Number 1', 'Vol {X}, No {Y}', 'Volume', NULL, 1, 12, 99999, 1, NULL, 'Number', NULL, 1, 1, 12, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
    (4, 'Seasonal', 4, 'Season Year', '{X} {Y}', 'Season', NULL, 1, 1, 3, 0, 'season', 'Year', NULL, 1, 4, 99999, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

