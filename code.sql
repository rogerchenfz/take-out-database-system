-- 1. 创建外卖数据库
CREATE DATABASE waimai;
USE waimai;

-- 2. 创建表

-- (1) 创建客户表
CREATE TABLE customers(
	id INT PRIMARY KEY AUTO_INCREMENT,	/* 客户编号 */
	name VARCHAR(40) NOT NULL,					/* 客户姓名 */
	consumption DOUBLE(16,2) NOT NULL DEFAULT 0,	/* 累计消费金额 */
	phone VARCHAR(11) NOT NULL,					/* 客户电话 */
	address VARCHAR(45) NOT NULL				/* 客户地址 */
);

-- (2) 创建商家表
CREATE TABLE stores(
	id INT PRIMARY KEY AUTO_INCREMENT,	/* 商家编号 */
	name VARCHAR(40) NOT NULL,					/* 商家名称 */
	turnover DOUBLE(16,2) NOT NULL DEFAULT 0,		/* 营业额 */
	phone VARCHAR(11) NOT NULL,					/* 商家电话 */
	address VARCHAR(45) NOT NULL				/* 商家地址 */
);

-- (3) 创建商品表
CREATE TABLE goods(
	id INT PRIMARY KEY AUTO_INCREMENT,	/* 商品编号 */
	name VARCHAR(40) NOT NULL,					/* 商品名称 */
	store_id INT NOT NULL,							/* 商家编号 */
	price DOUBLE(16,2) NOT NULL,				/* 商品价格 */
	limit_num INT, 											/* 限购数量 */
	FOREIGN KEY (store_id) REFERENCES stores(id)
);

-- (4) 创建订单表
CREATE TABLE orders(
	id INT PRIMARY KEY AUTO_INCREMENT,	/* 订单编号 */
	order_time DATETIME NOT NULL,				/* 订购时间 */
	customer_id INT NOT NULL,						/* 客户编号 */
	goods_id INT NOT NULL,							/* 商品编号 */
	number INT NOT NULL,								/* 商品数量 */
	total_cost DOUBLE(16,2) NOT NULL,		/* 消费总额 */
	state INT NOT NULL DEFAULT 0,				/* 订单状态 */
	FOREIGN KEY (customer_id) REFERENCES customers(id),
	FOREIGN KEY (goods_id) REFERENCES goods(id)
);

-- 3. 创建触发器

/* 创建触发器前修改SQL语句结束符为# */
DELIMITER #

​-- (1) 限购设置及订单总额计算
/* 创建之后，在客户订购的商品数量超过限购数量时，自动将订购的数量改为限购数量，然后计算出订单总额。*/
CREATE TRIGGER limit_buy
	BEFORE INSERT
	ON orders
  FOR EACH ROW
  BEGIN
		DECLARE p DOUBLE(16,2);		/*商品单价*/
    DECLARE lim INT;					/*限购数量*/
    SET p=(SELECT price FROM goods WHERE goods.id=NEW.goods_id);
    SET lim=(SELECT limit_num FROM goods WHERE goods.id=NEW.goods_id);
    IF (lim IS NOT NULL AND NEW.number>lim) THEN
			SET NEW.number=lim;
    END IF;
    SET NEW.total_cost=NEW.number*p;	/* 订单总额计算 */
  END #

-- (2) 更新客户累计消费金额
/* 在客户提交订单之后，自动将消费金额累加到客户总的消费金额里。*/
CREATE TRIGGER calculate_consumption
  AFTER INSERT
  ON orders
  FOR EACH ROW
  BEGIN
    UPDATE customers
			SET consumption=consumption+NEW.total_cost
    WHERE customers.id=NEW.customer_id;
  END #

-- (3) 更新商家总营业额以及退款
/* 商家接单后，自动将订单金额累加到商家的营业额里；客户取消订单，自动将客户总消费减去本次订单金额。*/
CREATE TRIGGER calculate_turnover
  BEFORE UPDATE
  ON orders
  FOR EACH ROW
  BEGIN
    IF (NEW.state=1 AND OLD.state=0) THEN
      UPDATE stores
        SET turnover=turnover+OLD.total_cost
      WHERE id=(SELECT store_id FROM goods WHERE goods.id=NEW.goods_id);
    ELSEIF (NEW.state=3 AND OLD.state=0) THEN
      UPDATE customers
      SET consumption=consumption-OLD.total_cost
      WHERE id=OLD.customer_id;
    ELSEIF (NEW.state<OLD.state) THEN
      SET NEW.state=OLD.state;
    END IF;
  END #
	
/* 创建完触发器后将SQL语句结束符修改回; */
DELIMITER ;

-- 查看触发器
SHOW TRIGGERS;

-- 4. 数据插入与更新

-- 数据插入

-- (1) 客户信息
INSERT INTO customers(name, phone, address)
VALUES ('张三','18512312300','芙蓉十');
INSERT INTO customers(name, phone, address)
VALUES ('李四','18612312301','芙蓉五');
INSERT INTO customers(name, phone, address)
VALUES ('王五','18712312302','南强二');
INSERT INTO customers(name, phone, address)
VALUES ('小花','18712412303','学生公寓');
INSERT INTO customers(name, phone, address)
VALUES ('小草','18572352304','集美二');
INSERT INTO customers(name, phone, address)
VALUES ('小树','18632314305','嘉庚二');
INSERT INTO customers(name, phone, address)
VALUES ('天天','18712312406','群贤二');
INSERT INTO customers(name, phone, address)
VALUES ('小兔子','18519312307','嘉庚五');
INSERT INTO customers(name, phone, address)
VALUES ('小昭','18112332808','芙蓉二');
INSERT INTO customers(name, phone, address)
VALUES ('小书包','18112812309','凌云四');
INSERT INTO customers(name, phone, address)
VALUES ('小飞','18152862310','笃行六');
INSERT INTO customers(name, phone, address)
VALUES ('小蝉','18352388511','石井二');

-- (2) 商家信息
INSERT INTO stores(name, phone, address)
VALUES ('回家吃饭','400123100','思明南路333号');
INSERT INTO stores(name, phone, address)
VALUES ('枝稻小食堂','400123101','富万邦1楼12号');
INSERT INTO stores(name, phone, address)
VALUES ('尊宝披萨','400123102','顶澳仔18号之14店');
INSERT INTO stores(name, phone, address)
VALUES ('茶百道','400123103','厦禾路296-135-1号');
INSERT INTO stores(name, phone, address)
VALUES ('阿姐烤冷面','400123104','曾厝垵后厝87号');

-- (3) 商品信息
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('重庆鸡公煲',1,13.9,1);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('麻辣香锅',1,12.5,5);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('土豆烧牛腩',1,14.9,NULL);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('韭菜猪肉馅',2,14.9,3);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('香菇猪肉馅',2,14.9,3);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('玉米猪肉馅',2,15.9,3);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('黑椒脆排饭',3,9.9,NULL);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('孜然脆排饭',3,9.5,NULL);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('叉烧脆排饭',3,11.8,2);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('腐竹黄焖鸡',4,10.8,3);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('黄焖鸡小份微辣',4,13,5);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('黄焖鸡小份中辣',4,14,5);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('鲜肉蒸饺',5,4,6);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('香拌混沌',5,5,3);
INSERT INTO goods(name, store_id, price, limit_num)
VALUES ('蛋炒南昌米粉',5,7,NULL);

-- (4) 客户提交订单
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-4-8 12:14:35',2,3,2);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-4-8 11:45:12',4,5,5);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-4-9 18:14:35',5,13,7);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-4-9 19:44:35',9,12,1);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-4-10 11:55:34',7,14,6);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-3 12:04:42',1,7,9);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-5 13:11:56',3,4,1);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-11 18:09:27',9,8,1);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-12 13:11:56',11,8,4);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-15 19:28:49',5,14,3);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-16 13:08:40',7,1,2);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-17 17:30:29',9,4,5);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-19 12:00:26',12,9,2);
INSERT orders(order_time, customer_id, goods_id, number)
VALUES ('2021-5-21 17:34:56',4,14,4);

-- 数据更新

-- (5) 商家接单
UPDATE orders SET state=1 WHERE id=1;
UPDATE orders SET state=1 WHERE id=2;
UPDATE orders SET state=1 WHERE id=3;
UPDATE orders SET state=1 WHERE id=4;
UPDATE orders SET state=1 WHERE id=5;
UPDATE orders SET state=1 WHERE id=6;
UPDATE orders SET state=1 WHERE id=7;
UPDATE orders SET state=1 WHERE id=8;
UPDATE orders SET state=1 WHERE id=9;
UPDATE orders SET state=1 WHERE id=10;
UPDATE orders SET state=1 WHERE id=11;
UPDATE orders SET state=1 WHERE id=12;
UPDATE orders SET state=1 WHERE id=13;
UPDATE orders SET state=1 WHERE id=14;

-- (6) 客户确认收货
UPDATE orders SET state=2 WHERE id=1;
UPDATE orders SET state=2 WHERE id=2;
UPDATE orders SET state=2 WHERE id=3;
UPDATE orders SET state=2 WHERE id=4;
UPDATE orders SET state=2 WHERE id=5;
UPDATE orders SET state=2 WHERE id=6;
UPDATE orders SET state=2 WHERE id=7;
UPDATE orders SET state=2 WHERE id=8;
UPDATE orders SET state=2 WHERE id=9;
UPDATE orders SET state=2 WHERE id=10;
UPDATE orders SET state=2 WHERE id=11;
UPDATE orders SET state=2 WHERE id=12;
UPDATE orders SET state=2 WHERE id=13;
UPDATE orders SET state=2 WHERE id=14;

-- 5. 创建索引

-- (1) 按客户累计消费金额降序索引
CREATE INDEX CUSTOMER_CONSUMPTION_DESC ON customers(consumption DESC);

-- (2) 按照商家营业额降序索引
CREATE INDEX STORE_TURNOVER_DESC ON stores(turnover DESC);

-- (3) 按商品价格升序索引
CREATE INDEX GOODS_PRICE_ASC ON goods(price);

-- (4) 按订单的下单时间降序索引
CREATE INDEX ORDER_TIME_DESC ON orders(order_time DESC);

-- 6. 创建视图

-- (1) 订单详情视图
CREATE VIEW order_details AS
SELECT orders.id AS 订单编号, stores.name AS 商家名称, goods.name AS 商品名称, 
number AS 数量, total_cost AS 总额, state AS 订单状态, 
customers.name AS 客户姓名, customers.phone AS 电话, customers.address AS 地址, order_time AS 时间
FROM ((stores INNER JOIN goods ON stores.id = goods.store_id)
INNER JOIN orders ON goods.id = orders.goods_id)
INNER JOIN customers ON orders.customer_id=customers.id;

SELECT * FROM order_details;

-- (2) 商家与商品视图
/* 显示商家编号、商家名、电话、地区及其售卖的商品名称、价格、月销量 */
CREATE VIEW stores_goods_details AS
SELECT DISTINCT stores.id AS 商家编号, stores.name AS 商家名称, 
goods.name AS 商品名称, goods.price AS 商品价格
FROM ((stores INNER JOIN goods ON stores.id = goods.store_id)
INNER JOIN orders ON goods.id = orders.goods_id);


-- (3) 商家营业额视图
CREATE VIEW STORE_COST AS
SELECT stores.id AS 商家编号, stores.name AS 商家名称, SUM(total_cost) AS 2021年营业额
FROM (orders INNER JOIN goods ON orders.goods_id = goods.id)
INNER JOIN stores ON store_id = stores.id
WHERE state IN (1,2) AND DATE(order_time) BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY stores.id;

-- (4) 商品销售视图
CREATE VIEW GOODS_SALES AS
SELECT goods.id AS 商品编号, goods.name AS 商品名称, stores.name AS 商家名称, 
SUM(number) AS 2021年销售量, SUM(total_cost) AS 2021年销售额
FROM (orders INNER JOIN goods ON orders.goods_id = goods.id) 
INNER JOIN stores ON store_id = stores.id
WHERE state IN (1,2) AND DATE(order_time) BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY goods.id;

-- (5) 客户消费视图
CREATE VIEW CUSTOMER_CONSUMPTION AS
SELECT customers.id AS 客户编号, customers.consumption AS 累计消费金额, 
MAX(时间) AS 最近一次消费时间, COUNT(*) AS 消费频率（天数）, MAX(总额) AS 最大消费金额
FROM ((order_details INNER JOIN customers ON 客户姓名 = customers.name)) GROUP BY 
customers.id;


-- 7. 创建存储过程

/* 修改 SQL 语句结束符为# */
DELIMITER #

-- (1) 客户订单检索
/* 输入客户编号，查看订单 */
CREATE PROCEDURE ORDER_SEARCH(IN c_id INT)
	BEGIN
		SELECT * FROM orders WHERE customer_id=c_id;
	END #

-- (2) 商家每月销售额查询
/* 输入商家名称，查询该商家每月的销售额 */
CREATE PROCEDURE STORE_MONTH_SALES_SEARCH(IN s_name VARCHAR(40))
	BEGIN
		SELECT 商家名称, SUM(总额), 月份
		FROM (SELECT 商家名称, MONTH(时间) AS 月份, 总额 FROM order_details) AS SALES1
		GROUP BY 商家名称, 月份 HAVING 商家名称=s_name;
	END #

-- (3) 客户每月消费金额查询
/* 输入客户编号，查询该客户每月的消费金额 */
CREATE PROCEDURE CUSTOMER_MONTH_CONSUMPTION_SEARCH(IN c_id INT)
	BEGIN
		SELECT 客户编号, SUM(total_cost) AS 消费金额, 月份
		FROM (SELECT customer_id AS 客户编号, MONTH(order_time) AS 月份, total_cost FROM orders) AS SALES2
		GROUP BY 客户编号, 月份 HAVING 客户编号=c_id;
	END #

/* 创建完触发器后将 SQL 语句结束符修改回; */
DELIMITER ;

-- 8. 创建管理员

CREATE USER 'admin'@'localhost' IDENTIFIED BY '123456'; /* 平台管理员 */
CREATE USER 'S1'@'localhost' IDENTIFIED BY '123456'; 		/* 商家 */
CREATE USER 'C1'@'localhost' IDENTIFIED BY '123456'; 		/* 用户 */

/* 把对所有表的全部操作权限授予平台管理员 admin */
GRANT ALL PRIVILEGES ON customers, stores, goods, orders TO admin WITH GRANT OPTION;

/* 把对所有视图的全部操作权限授予平台管理员 admin */
GRANT ALL PRIVILEGES ON 
order_details, stores_goods_details, STORE_COST, GOODS_SALES, CUSTOMER_CONSUMPTION
TO admin;


-- 数据综合分析

-- 1. 2021 年各商家营业状况

-- (1) 商家总营业额降序排行
SELECT * FROM STORE_COST ORDER BY 2021年营业额 DESC;

-- (2) 查询总营业额大于105的商家
SELECT * FROM STORE_COST WHERE 2021年营业额>105;

-- (3) 查询每个商家每月的销售额
SELECT 商家名称, SUM(总额), 月份
FROM (SELECT 商家名称, MONTH(时间) AS 月份, 总额 FROM order_details) AS SALES1
GROUP BY 商家名称, 月份;

-- (4) 查询“枝稻小食堂”每月的销售额
/* 调用存储过程 */
CALL STORE_MONTH_SALES_SEARCH('枝稻小食堂'); 

-- (5) 查询每个商家每日的销售额
SELECT 商家名称, SUM(总额), 日期
FROM (SELECT 商家名称, DATE(时间) AS 日期,总额 FROM order_details) AS SALES2
GROUP BY 商家名称, 日期;

-- 2. 2021年各商品销售状况

-- (1) 商品销量降序排行
SELECT * FROM GOODS_SALES ORDER BY 2021年销售量 DESC;

-- (2) 商品销售额降序排行
SELECT * FROM GOODS_SALES ORDER BY 2021年销售额 DESC;

-- (3) 商品销量降序、价格升序排行
SELECT 商品编号, 商品名称, 商家名称, 2021年销售量, price AS 价格
FROM (GOODS_SALES INNER JOIN goods ON 商品编号=goods.id)
ORDER BY 2021年销售量 DESC, 价格 ASC;

-- (4) 查询“尊宝披萨”的商品销量前3的商品及销量
SELECT 商品编号, 商品名称, 2021年销售量 FROM GOODS_SALES
WHERE 商家名称='尊宝披萨' ORDER BY 2021年销售量 DESC LIMIT 3;

-- (5) 查询“阿姐烤冷面”销量最高的商品
SELECT 商品编号, 商品名称, 2021年销售量
FROM GOODS_SALES 
WHERE 商家名称='阿姐烤冷面' ORDER BY 2021年销售量 DESC LIMIT 1;

-- 3. 2021年各客户消费情况

-- (1) 客户2021年最近一次消费记录降序排列
SELECT * FROM CUSTOMER_CONSUMPTION ORDER BY 最近一次消费时间 DESC;

-- (2) 客户2021年消费频率（天数）降序排列
SELECT * FROM CUSTOMER_CONSUMPTION ORDER BY `消费频率（天数）` DESC;

-- (3) 客户 2021 年消费金额降序排列
SELECT * FROM CUSTOMER_CONSUMPTION ORDER BY 累计消费金额 DESC;

-- (4) 找出没有购买过“回家吃饭”的客户
SELECT id,name
FROM customers x
WHERE NOT EXISTS
(SELECT* FROM customers y INNER JOIN orders ON y.id=orders.customer_id
 WHERE orders.goods_id IN (SELECT id FROM goods WHERE store_id='1') AND x.id=y.id);

-- (5) 查询客户编号为7的客户的每月消费金额
/* 调用存储过程 */
CALL CUSTOMER_MONTH_CONSUMPTION_SEARCH(7); 

-- 4. 综合查询

-- (1) 商品销售量前10的商家上榜次数
SELECT 商家名称, COUNT(商家名称) AS 次数 FROM 
(SELECT * FROM GOODS_SALES ORDER BY 2021年销售量 DESC LIMIT 10) AS 
GOODS_SALES_TOP_10 GROUP BY 商家名称 ORDER BY 次数 DESC;

-- (2) 查询每个商家超过它平均销售量的商品及其销售情况
SELECT * FROM GOODS_SALES x
WHERE 2021年销售量>=(SELECT AVG(2021年销售量) FROM GOODS_SALES y
WHERE y.商家名称=x.商家名称);

-- (3) 查询客户编号为9的客户的所有订单
/* 调用存储过程 */
CALL ORDER_SEARCH(9);

-- (4) 计算“阿姐烤冷面”5月的客户复购率
SELECT R1.n1/R2.n2 复购率
FROM ((SELECT COUNT(*) n1 FROM 
((SELECT DISTINCT 客户姓名 FROM order_details
	WHERE 商家名称='阿姐烤冷面' AND MONTH(时间)=4
	AND 客户姓名 IN (SELECT DISTINCT 客户姓名 FROM order_details
									 WHERE 商家名称='阿姐烤冷面' AND MONTH(时间)=5)) AS RR1)) R1,
	(SELECT COUNT(*) n2 FROM
	(SELECT DISTINCT 客户姓名 FROM order_details
	WHERE 商家名称='阿姐烤冷面' AND MONTH(时间)=4) AS RR2) R2
);

-- (5) 计算“阿姐烤冷面”5月新客户占比
SELECT N1.n1/N2.n2 新客户占比
FROM ((SELECT COUNT(*) n1 FROM 
			((SELECT DISTINCT 客户姓名 FROM order_details
					WHERE 商家名称='阿姐烤冷面' AND MONTH(时间)=5
					AND 客户姓名 NOT IN (SELECT DISTINCT 客户姓名 FROM order_details
					WHERE 商家名称='阿姐烤冷面' AND MONTH(时间)=4)) AS NC1)) N1,
			(SELECT COUNT(*) n2 FROM
			(SELECT DISTINCT 客户姓名 FROM order_details
					WHERE 商家名称='阿姐烤冷面' AND MONTH(时间)=5) AS NC2) N2
);
