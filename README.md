# 外卖订单信息管理系统

项目代码见 [code.sql](https://github.com/rogerchenfz/take-out-database-system/blob/main/code.sql)

报告目录见 [Report.md](https://github.com/rogerchenfz/take-out-database-system/blob/main/Report.md)，内容包括设计目的、需求分析（用户需求分析、系统功能分析、数据字典）、概念结构设计（实体属性图、实体联系图、管理系统的E-R图）、逻辑结构设计（基本思想、关系模式）、数据库实施（创建数据库、创建表、创建触发器、数据插入与更新、创建索引、创建视图、创建存储过程、创建管理员）

## 需求分析

### 数据字典

客户基本信息、商家基本信息、商品基本信息

## 数据库实施

### 创建表

客户表、商家表、商品表、订单表

### 创建触发器

设置限购以及计算订单总额、更新客户累计消费金额、更新商家总营业额以及设置退款

### 数据插入与更新

客户信息、商家信息、商品信息、客户提交订单、商家接单、客户确认收货

### 创建索引

按客户累计消费金额降序索引、按照商家营业额降序索引、按商品价格升序索引、按订单的下单时间降序索引

### 创建视图

订单详情视图、商家与商品视图、商家营业额视图、商品销售视图、客户消费视图

### 创建存储过程

客户订单检索、商家每月销售额查询、客户每月消费金额查询



## 数据综合分析

### 2021年各商家营业状况

#### 1. 商家总营业额降序排行

#### 2. 查询总营业额大于105的商家

#### 3. 查询每个商家每月的销售额

#### 4. 查询“枝稻小食堂”每月的销售额

#### 5. 查询每个商家每日的销售额

### 2021年各商品销售状况

#### 1. 商品销量降序排行

#### 2. 商品销售额降序排行

#### 3. 商品销量降序、价格升序排行

#### 4. 查询“尊宝披萨”的商品销量前3的商品及销量

#### 5. 查询“阿姐烤冷面”销量最高的商品

### 2021年各客户消费情况

#### 1. 客户2021年最近一次消费记录降序排列

#### 2. 客户2021年消费频率（天数）降序排列

#### 3. 客户2021年消费金额降序排列

#### 4. 找出没有购买过“回家吃饭”的客户

#### 5. 查询客户编号为7的客户的每月消费金额

### 综合查询

#### 1. 商品销售量前10的商家上榜次数

#### 2. 查询每个商家超过它平均销售量的商品及其销售情况

#### 3. 查询客户编号为9的客户的所有订单

#### 4. 计算“阿姐烤冷面”5月的客户复购率

#### 5. 计算“阿姐烤冷面”5月新客户占比

