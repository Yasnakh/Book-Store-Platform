
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`product` (
  `pid` INT NOT NULL AUTO_INCREMENT,
  `product_category` VARCHAR(45) NOT NULL,
  `weight` FLOAT NULL,
  PRIMARY KEY (`pid`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`book` (
  `pid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `author` VARCHAR(45) NOT NULL,
  `publisher` VARCHAR(45) NOT NULL,
  `isbn` INT NOT NULL,
  `cover` VARCHAR(45) NOT NULL,
  `size` VARCHAR(45) NOT NULL,
  `page_count` INT NOT NULL,
  `publish_year` DATETIME NOT NULL,
  `print_number` INT NOT NULL,
  `abstract` TEXT(1000) NULL,
  PRIMARY KEY (`pid`),
  UNIQUE INDEX `isbn_UNIQUE` (`isbn` ASC) VISIBLE,
  CONSTRAINT `book_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`product` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`supplier`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`supplier` (
  `sid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `score` FLOAT NOT NULL DEFAULT 0,
  `city` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`sid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`product_supplier`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`product_supplier` (
  `psid` INT NOT NULL AUTO_INCREMENT,
  `pid` INT NOT NULL,
  `sid` INT NOT NULL,
  `count` INT NOT NULL,
  `price` INT NOT NULL,
  INDEX `book_supplier_sid_idx` (`sid` ASC) INVISIBLE,
  PRIMARY KEY (`psid`),
  INDEX `combined_uniqeness` (`pid` ASC, `sid` ASC) INVISIBLE,
  CONSTRAINT `book_supplier_sid`
    FOREIGN KEY (`sid`)
    REFERENCES `mydb`.`supplier` (`sid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `book_supplier_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`product` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`price_history`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`price_history` (
  `pid` INT NOT NULL,
  `date` DATETIME NOT NULL,
  `price` INT NOT NULL,
  INDEX `price_history_pid_idx` (`pid` ASC) VISIBLE,
  CONSTRAINT `price_history_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`product` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`user` (
  `uid` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `phone` VARCHAR(45) NOT NULL,
  `address` TEXT(250) NULL,
  `postal_code` VARCHAR(45) NULL,
  `gender` VARCHAR(45) NOT NULL,
  `city` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  UNIQUE INDEX `phone_UNIQUE` (`phone` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`shopping_cart_bill`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`shopping_cart_bill` (
  `scid` INT NOT NULL AUTO_INCREMENT,
  `uid` INT NOT NULL,
  `product_name` VARCHAR(45) NOT NULL,
  `total_price` INT NOT NULL,
  `discount` INT NOT NULL,
  `date` DATE NOT NULL,
  `is_sold` INT NOT NULL,
  PRIMARY KEY (`scid`),
  INDEX `shopping_cart_cid_idx` (`uid` ASC) VISIBLE,
  CONSTRAINT `shopping_cart_uid`
    FOREIGN KEY (`uid`)
    REFERENCES `mydb`.`user` (`uid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`cart_item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`cart_item` (
  `scid` INT NOT NULL,
  `psid` INT NOT NULL,
  `count` INT NOT NULL,
  `price` INT NOT NULL,
  INDEX `cart_item_scid_idx` (`scid` ASC) VISIBLE,
  INDEX `cart_item_bsid_idx` (`psid` ASC) VISIBLE,
  PRIMARY KEY (`scid`, `psid`),
  CONSTRAINT `cart_item_scid`
    FOREIGN KEY (`scid`)
    REFERENCES `mydb`.`shopping_cart_bill` (`scid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `cart_item_psid`
    FOREIGN KEY (`psid`)
    REFERENCES `mydb`.`product_supplier` (`psid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`children_book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`children_book` (
  `pid` INT NOT NULL,
  `subject` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`pid`),
  CONSTRAINT `children_book_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`book` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`teenage_book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`teenage_book` (
  `pid` INT NOT NULL,
  `subject` VARCHAR(45) NOT NULL,
  INDEX `teenage_book_bid_idx` (`pid` ASC) VISIBLE,
  PRIMARY KEY (`pid`),
  CONSTRAINT `teenage_book_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`book` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`adult_book`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`adult_book` (
  `pid` INT NOT NULL,
  `subject` VARCHAR(45) NOT NULL,
  INDEX `adult_book_bid_idx` (`pid` ASC) VISIBLE,
  PRIMARY KEY (`pid`),
  CONSTRAINT `adult_book_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`book` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`comment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`comment` (
  `cid` INT NOT NULL AUTO_INCREMENT,
  `uid` INT NOT NULL,
  `pid` INT NOT NULL,
  `text` TEXT(1000) NOT NULL,
  `date` DATETIME NOT NULL,
  `score` INT NOT NULL,
  PRIMARY KEY (`cid`),
  INDEX `comment_uid_idx` (`uid` ASC) VISIBLE,
  INDEX `comment_pid_idx` (`pid` ASC) VISIBLE,
  CONSTRAINT `comment_uid`
    FOREIGN KEY (`uid`)
    REFERENCES `mydb`.`user` (`uid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `comment_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`product` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`stationery`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`stationery` (
  `pid` INT NOT NULL,
  `brand` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `color` VARCHAR(45) NOT NULL,
  `size` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`pid`),
  CONSTRAINT `stationery_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`product` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`notebook`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`notebook` (
  `pid` INT NOT NULL,
  `page_count` INT NOT NULL,
  `brand` VARCHAR(45) NOT NULL,
  `color` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`pid`),
  CONSTRAINT `notebook_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`product` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`bag`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`bag` (
  `pid` INT NOT NULL,
  `material` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `size` INT NOT NULL,
  `brand` VARCHAR(45) NOT NULL,
  `color` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`pid`),
  CONSTRAINT `bag_pid`
    FOREIGN KEY (`pid`)
    REFERENCES `mydb`.`product` (`pid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`supplier_scoring`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`supplier_scoring` (
  `sid` INT NOT NULL,
  `uid` INT NOT NULL,
  `score` FLOAT NOT NULL DEFAULT 0,
  PRIMARY KEY (`sid`, `uid`),
  INDEX `supplier_scoring_uid_idx` (`uid` ASC) VISIBLE,
  CONSTRAINT `supplier_scoring_sid`
    FOREIGN KEY (`sid`)
    REFERENCES `mydb`.`supplier` (`sid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `supplier_scoring_uid`
    FOREIGN KEY (`uid`)
    REFERENCES `mydb`.`user` (`uid`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`accounts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,
  `email` varchar(100) NOT NULL,
  `type` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


INSERT INTO
  `product`(`product_category`, `weight`)
VALUES
  ('stationary',500),
  ('stationary',1000),
  ('children_book',2470),
  ('adult_book',100),
  ('adult_book',500),
  ('adult_book',700),
  ('bag',600),
  ('teenage_book',500),
  ('teenage_book',320),
  ('stationary',190),
  ('teenage_book',280),
  ('bag',500),
  ('teenage_book',280),
  ('bag',500),
  ('children_book',500),
  ('children_book',1000),
  ('children_book',2470),
  ('adult_book',100),
  ('adult_book',500),
  ('adult_book',700),
  ('stationary',600),
  ('stationary',500),
  ('note_book',320),
  ('book',190),
  ('note_book',300);

  INSERT INTO
  `book`(
    `pid`,
    `name`,
    `author`,
    `publisher`,
    `isbn`,
    `cover`,
    `size`,
    `page_count`,
    `publish_year`,
    `print_number`,
    `abstract`
  )
VALUES
  (
    1,
    'bookName1',
    'author1',
    'publisher1',
    1111,
    'cover1',
    'size1',
    200,
    '2012-11-27 0:0:0',
    3,
    NULL
  ),
  (
    2,
    'bookName2',
    'author2',
    'publisher2',
    2222,
    'cover2',
    'size2',
    250,
    '2020-10-16 0:0:0',
    3,
    'abstract of book 2'
  ),
  (
    3,
    'bookName3',
    'author3',
    'publisher3',
    3333,
    'cover3',
    'size3',
    100,
    '2012-11-27 0:0:0',
    10,
    NULL
  ),
  (
    4,
    'bookName4',
    'author4',
    'publisher4',
    4444,
    'cover4',
    'size4',
    74,
    '2015-1-2 0:0:0',
    22,
    NULL
  ),
  (
    5,
    'bookName5',
    'author5',
    'publisher5',
    5555,
    'cover5',
    'size5',
    200,
    '2022-4-6 0:0:0',
    11,
    'abstract of book 5'
  );


INSERT INTO
  `children_book` (`pid`, `subject`)
VALUES
  (1, 'story'),
  (2, 'story');

INSERT INTO
  `adult_book` (`pid`, `subject`)
VALUES
  (3, 'health'),
(4, 'philosophy');

INSERT INTO
  `teenage_book` (`pid`, `subject`)
VALUES
  (5, 'comics');

INSERT INTO
  `stationery` (`pid`, `brand`, `type`, `color`, `size`)
VALUES
  (6, 'canco', 'pen', 'blue', '0.7'),
  (7, 'kian', 'pencil', 'yellow', '0.5');

INSERT INTO
  `bag` (
    `pid`,
    `material`,
    `type`,
    `size`,
    `brand`,
    `color`
  )
VALUES
  (8, 'cloth', 'shoulderbag', 3, 'chanel', 'green'),
  (9, 'leather', 'backpack', 2, 'cat', 'black');

INSERT INTO
  `notebook` (`pid`, `page_count`, `brand`, `color`, `type`)
VALUES
  (10, 100, 'arsh', 'pink', 'spiral'),
  (11, 85, 'arsh', 'orange', 'plain');

INSERT INTO
  `price_history` (`pid`, `date`, `price`)
VALUES
  (12, '2022-08-06 10:53:35', 4600),
  (13, '2020-02-28 08:24:55', 7900);

INSERT INTO
  `supplier`(`name`, `score`, `city`)
VALUES
  ('Farid', 2.5, 'mashhad'),
  ('Rozhan', 4.5, 'mashhad'),
  ('Yasna', 5, 'mashhad'),
  ('Sina', 4, 'mashhad'),
  ('Tahmineh', 4, 'mashhad');

INSERT INTO
  `product_supplier`(`pid`, `sid`, `count`, `price`)
VALUES
  (1, 1, 900, 1234),
  (1, 2, 100, 13253),
  (3, 1, 200, 5654),
  (1, 3, 340, 2543),
  (3, 4, 600, 74324),
  (1, 5, 800, 2562),
  (6, 3, 400, 4363),
  (6, 4, 600, 67432),
  (7, 3, 500, 2432),
  (7, 4, 550, 2573),
  (7, 5, 300, 7645),
  (8, 1, 200, 14524),
  (8, 5, 100, 2563),
  (8, 2, 600, 2562),
  (8, 3, 700, 2568);

INSERT INTO
  `user`(
    `first_name`,
    `last_name`,
    `email`,
    `phone`,
    `address`,
    `postal_code`,
    `gender`,
    `city`
  )
VALUES
  (
    'Farid',
    'Faridi',
    'faridfar@yahoo.com',
    '234895834',
    null,
    null,
    'F',
    'mashhad'
  ),
  (
    'Rozhan',
    'Boroumand',
    'rozhan1381@yahoo.com',
    '984723947',
    null,
    null,
    'F',
    'mashhad'
  ),
  (
    'Yasna',
    'Kholafaei',
    'yasnakholafai@yahoo.com',
    '37493994',
    null,
    null,
    'F',
    'mashhad'
  ),
  (
    'Sina',
    'Mokhtari',
    'sinamokhtari@yahoo.com',
    '64326349234',
    null,
    null,
    'M',
    'mashhad'
  ),
  (
    'Tahmineh',
    'Tavakoli',
    'tahminehtavakoli@yahoo.com',
    '474375739',
    null,
    null,
    'F',
    'mashhad'
  );

INSERT INTO
  `supplier_scoring`(`sid`, `uid`, `score`)
VALUES
  (1, 1, 2.5),
  (2, 2, 3.5),
  (3, 3, 4),
  (4, 4, 5),
  (5, 5, 2);

INSERT INTO
  `comment`(`uid`, `pid`, `text`, `date`, `score`)
VALUES
  (1, 1, 'skdfjkfjcn', '2022-08-06 10:53:35',5),
  (2, 2, 'hfhgskhjdf', '2022-08-06 10:53:35',3),
  (3, 3, 'kdjhskjgf', '2022-08-06 10:53:35',2),
  (4, 4, 'nfkjsbvkjs', '2022-08-06 10:53:35',3),
  (5, 5, 'fnsgkfbvkj', '2022-08-06 10:53:35',1);

INSERT INTO
  `shopping_cart_bill`(`scid`, `uid`, `product_name`, `total_price`, `discount`, `date`, `is_sold`)
VALUES
  (1, 1, 'comicBook', 1000, 155, '2022-12-21', 0),
  (2, 1, 'spiralNotebook', 2000, 360, '2022-12-17', 1),
  (3, 3, 'comicBook', 3000, 100, '2022-12-26', 0),
  (4, 4, 'cancoPen', 4000, 200, '2023-01-06', 1),
  (5, 5, 'cancoPen', 5000, 800, '2023-01-10', 0),
  (6, 2, 'comicBook', 4500, 900, '2023-01-12', 0),
  (7, 2, 'plainNotebook', 1500, 0, '2022-12-07', 1),
  (8, 3, 'backpack', 3500, 10, '2022-12-10', 0),
  (9, 4, 'backpack', 6000, 0, '2022-12-05', 1),
  (10, 1, 'backpack', 5500, 1000, '2022-10-06', 0),
  (11, 3, 'backpack', 2500, 200, '2022-08-06', 1),
  (12, 2, 'healthBook', 1500, 180, '2023-01-09', 1),
  (13, 3, 'healthBook', 3500, 250, '2023-01-10', 0),
  (14, 3, 'healthBook', 6000, 30, '2023-01-11', 1),
  (15, 1, 'healthBook', 5500, 0, '2023-01-13', 0),
  (16, 2, 'storyBook', 2500, 100, '2023-01-09', 1),
  (17, 3, 'storyBook', 6000, 20, '2023-01-10', 1),
  (18, 5, 'storyBook', 5500, 500, '2022-12-19', 0),
  (19, 1, 'storyBook', 2500, 650, '2022-12-22', 1),
  (20, 1, 'plainNotebook', 8000, 100, '2022-12-22', 0),
  (21, 1, 'plainNotebook', 5500, 500, '2023-01-13', 0),
  (22, 5, 'spiralNotebook', 2500, 10, '2023-01-14', 1),
  (23, 4, 'kianPen', 6000, 0, '2023-01-11', 1),
  (24, 2, 'kianPen', 5500, 200, '2022-01-12', 0),
  (25, 3, 'healthBook', 5500, 0, '2023-01-13', 0),
  (26, 5, 'storyBook', 2500, 100, '2023-01-09', 1),
  (27, 4, 'storyBook', 6000, 20, '2023-01-05', 1),
  (28, 1, 'storyBook', 5500, 500, '2022-12-28', 0),
  (29, 3, 'storyBook', 2500, 650, '2023-01-02', 1),
  (30, 3, 'plainNotebook', 8000, 100, '2022-12-29', 0),
  (31, 5, 'plainNotebook', 5500, 500, '2023-01-13', 0),
  (32, 1, 'spiralNotebook', 2500, 10, '2023-01-14', 1),
  (33, 4, 'kianPen', 6000, 0, '2023-01-15', 1),
  (34, 3, 'kianPen', 5500, 200, '2022-12-30', 0),
  (35, 5, 'kianPen', 2500, 1000, '2023-01-12', 1);

INSERT INTO
  `cart_item`(`scid`, `psid`, `count`, `price`)
VALUES
  (1, 1, 2, 1000),
  (2, 2, 3, 2000),
  (3, 3, 4, 3000),
  (4, 4, 5, 4000),
  (5, 5, 2, 5000);
  
INSERT INTO 
  `accounts` (`id`, `username`, `password`, `email`, `type`)
VALUES
  (1, 'yasna', 'yasna', 'yasna@yahoo.com', 'Admin'),
  (2, 'rozhan', 'rozhan', 'rozhan@yahoo.com', 'Admin'),
  (3, 'sina', 'sina', 'sina@yahoo.com', 'Admin'),
  (4, 'tahmineh', 'tahmineh', 'tahmineh@yahoo.com', 'Admin');
