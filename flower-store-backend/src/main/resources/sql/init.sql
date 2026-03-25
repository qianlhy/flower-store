-- MySQL dump 10.13  Distrib 8.0.17, for Win64 (x86_64)
--
-- Host: localhost    Database: flower_store
-- ------------------------------------------------------
-- Server version	8.0.17

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `t_address`
--

DROP TABLE IF EXISTS `t_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_address` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `name` varchar(50) NOT NULL COMMENT '收货人姓名',
  `phone` varchar(20) NOT NULL COMMENT '收货人手机号',
  `province` varchar(50) NOT NULL COMMENT '省',
  `city` varchar(50) NOT NULL COMMENT '市',
  `district` varchar(50) NOT NULL COMMENT '区',
  `address` varchar(255) NOT NULL COMMENT '详细地址',
  `is_default` tinyint(1) DEFAULT '0' COMMENT '是否默认地址：0-否，1-是',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收货地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_address`
--

LOCK TABLES `t_address` WRITE;
/*!40000 ALTER TABLE `t_address` DISABLE KEYS */;
INSERT INTO `t_address` VALUES (1,1,'张三','15888888888','北京市','北京市','朝阳区','XX小区10号楼1单元101',1,'2025-12-22 17:33:07','2025-12-22 17:33:07',0);
/*!40000 ALTER TABLE `t_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_admin`
--

DROP TABLE IF EXISTS `t_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_admin` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `role` tinyint(1) DEFAULT '2' COMMENT '角色：1-超级管理员，2-普通管理员',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：0-禁用，1-正常',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='管理员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_admin`
--

LOCK TABLES `t_admin` WRITE;
/*!40000 ALTER TABLE `t_admin` DISABLE KEYS */;
INSERT INTO `t_admin` VALUES (1,'admin','e10adc3949ba59abbe56e057f20f883e','超级管理员',NULL,NULL,1,1,'2025-12-22 17:14:38','2025-12-22 17:14:38',0);
/*!40000 ALTER TABLE `t_admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_cart`
--

DROP TABLE IF EXISTS `t_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_cart` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `count` int(11) NOT NULL DEFAULT '1' COMMENT '数量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`,`product_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='购物车表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_cart`
--

LOCK TABLES `t_cart` WRITE;
/*!40000 ALTER TABLE `t_cart` DISABLE KEYS */;
INSERT INTO `t_cart` VALUES (1,1,9,1,'2025-12-22 17:32:44','2025-12-22 17:32:44');
/*!40000 ALTER TABLE `t_cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_category`
--

DROP TABLE IF EXISTS `t_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `icon` varchar(255) DEFAULT NULL COMMENT '分类图标',
  `sort` int(11) DEFAULT '0' COMMENT '排序',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_category`
--

LOCK TABLES `t_category` WRITE;
/*!40000 ALTER TABLE `t_category` DISABLE KEYS */;
INSERT INTO `t_category` VALUES (1,'玫瑰花','http://localhost:8080/api/uploads/2025/12/22/1766395225436_ca5gjarax9e.png',1,1,'2025-12-22 17:14:38','2025-12-22 17:20:26',0),(2,'康乃馨','http://localhost:8080/api/uploads/2025/12/22/1766395264072_95qqxe4ssqe.png',2,1,'2025-12-22 17:14:38','2025-12-22 17:21:05',0),(3,'百合花','http://localhost:8080/api/uploads/2025/12/22/1766395275601_obdk3wtujq.png',3,1,'2025-12-22 17:14:38','2025-12-22 17:21:16',0),(4,'向日葵','http://localhost:8080/api/uploads/2025/12/22/1766395282117_1oziismh7qj.png',4,1,'2025-12-22 17:14:38','2025-12-22 17:21:22',0),(5,'郁金香','http://localhost:8080/api/uploads/2025/12/22/1766395289086_84h0fnvtu23.png',5,1,'2025-12-22 17:14:38','2025-12-22 17:21:29',0),(6,'满天星','http://localhost:8080/api/uploads/2025/12/22/1766395293844_tzzt8fxal9.png',6,1,'2025-12-22 17:14:38','2025-12-22 17:21:34',0),(7,'混合花束','http://localhost:8080/api/uploads/2025/12/22/1766395297569_eovdyy9w9gg.png',7,1,'2025-12-22 17:14:38','2025-12-22 17:21:38',0);
/*!40000 ALTER TABLE `t_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_favorite`
--

DROP TABLE IF EXISTS `t_favorite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_favorite` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`,`product_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_favorite`
--

LOCK TABLES `t_favorite` WRITE;
/*!40000 ALTER TABLE `t_favorite` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_favorite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_order`
--

DROP TABLE IF EXISTS `t_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `receiver_name` varchar(50) NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) NOT NULL COMMENT '收货人手机号',
  `province` varchar(50) DEFAULT NULL COMMENT '收货地址-省',
  `city` varchar(50) DEFAULT NULL COMMENT '收货地址-市',
  `district` varchar(50) DEFAULT NULL COMMENT '收货地址-区',
  `address` varchar(255) NOT NULL COMMENT '详细地址',
  `total_price` decimal(10,2) NOT NULL COMMENT '商品总价',
  `freight` decimal(10,2) DEFAULT '0.00' COMMENT '运费',
  `actual_payment` decimal(10,2) NOT NULL COMMENT '实付金额',
  `payment_method` varchar(20) DEFAULT 'online' COMMENT '支付方式：online-在线支付，delivery-货到付款',
  `remark` varchar(500) DEFAULT NULL COMMENT '订单备注',
  `status` tinyint(1) DEFAULT '1' COMMENT '订单状态：1-待付款，2-待发货，3-已发货，4-已完成，5-已取消',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `finish_time` datetime DEFAULT NULL COMMENT '完成时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_order`
--

LOCK TABLES `t_order` WRITE;
/*!40000 ALTER TABLE `t_order` DISABLE KEYS */;
INSERT INTO `t_order` VALUES (1,'ORDER202512221733118289',1,'张三','15888888888','北京市','北京市','朝阳区','XX小区10号楼1单元101',128.00,0.00,128.00,'online','123',4,NULL,NULL,NULL,'2025-12-22 17:33:11','2025-12-22 17:45:03',0);
/*!40000 ALTER TABLE `t_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_order_item`
--

DROP TABLE IF EXISTS `t_order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_order_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `product_name` varchar(100) NOT NULL COMMENT '商品名称',
  `product_image` varchar(255) DEFAULT NULL COMMENT '商品图片',
  `price` decimal(10,2) NOT NULL COMMENT '商品价格',
  `count` int(11) NOT NULL COMMENT '购买数量',
  `subtotal` decimal(10,2) NOT NULL COMMENT '小计',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_order_item`
--

LOCK TABLES `t_order_item` WRITE;
/*!40000 ALTER TABLE `t_order_item` DISABLE KEYS */;
INSERT INTO `t_order_item` VALUES (1,1,9,'满天星花束 - 浪漫星空','https://qcloud.dpfile.com/pc/tSUjWiqr9Oe_gr0diUfHNU_5I1tIKBWZYay4biyqeLA57EIn_lnJvPOWlS4lMt0N.jpg',128.00,1,128.00,'2025-12-22 17:33:11','2025-12-22 17:33:11');
/*!40000 ALTER TABLE `t_order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_product`
--

DROP TABLE IF EXISTS `t_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_product` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '商品名称',
  `category_id` bigint(20) NOT NULL COMMENT '分类ID',
  `price` decimal(10,2) NOT NULL COMMENT '商品价格',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `inventory` int(11) DEFAULT '0' COMMENT '库存',
  `sales` int(11) DEFAULT '0' COMMENT '销量',
  `rating` decimal(2,1) DEFAULT '5.0' COMMENT '评分',
  `image` varchar(4096) DEFAULT NULL COMMENT '主图',
  `images` text COMMENT '轮播图（多张，逗号分隔）',
  `description` varchar(500) DEFAULT NULL COMMENT '商品描述',
  `detail` text COMMENT '商品详情',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：0-下架，1-上架',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_product`
--

LOCK TABLES `t_product` WRITE;
/*!40000 ALTER TABLE `t_product` DISABLE KEYS */;
INSERT INTO `t_product` VALUES (1,'红玫瑰花束 - 真爱永恒',1,199.00,259.00,500,1000,4.9,'https://img1.baidu.com/it/u=2943692879,3953406134&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=601','https://img1.baidu.com/it/u=2943692879,3953406134&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=601','精选红玫瑰，象征热烈爱情，表达真挚情感','精选优质红玫瑰，新鲜采摘，花苞饱满，寓意爱情永恒，适合表白、纪念日送礼',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(2,'粉玫瑰礼盒 - 浪漫满屋',1,299.00,399.00,300,800,4.8,'https://pic.rmb.bdstatic.com/bjh/240625/da34f4e94885ddd3e93d89c883b81c205282.jpeg','https://pic.rmb.bdstatic.com/bjh/240625/da34f4e94885ddd3e93d89c883b81c205282.jpeg','精致粉玫瑰礼盒，温馨浪漫，表达柔情蜜意','精选粉玫瑰，配以精美礼盒包装，花材新鲜，适合送女友、送长辈',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(3,'康乃馨花束 - 感恩有你',2,158.00,198.00,400,1500,4.9,'https://qcloud.dpfile.com/pc/9M5N5-vqPMlF01JmePUIiNB4ZkLzVMfVTRsckaRvLn11IvQuz5oUhaV_Pbnr27MJ.jpg','https://qcloud.dpfile.com/pc/9M5N5-vqPMlF01JmePUIiNB4ZkLzVMfVTRsckaRvLn11IvQuz5oUhaV_Pbnr27MJ.jpg','温馨康乃馨，表达感恩之情，送给最爱的人','新鲜康乃馨，花色鲜艳，寓意感恩与祝福，适合母亲节、教师节送礼',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(4,'白百合花束 - 纯洁之爱',3,238.00,298.00,250,600,4.8,'https://img0.baidu.com/it/u=4145792732,3959820441&fm=253&app=138&f=JPEG?w=500&h=667','https://img0.baidu.com/it/u=4145792732,3959820441&fm=253&app=138&f=JPEG?w=500&h=667','优雅白百合，清新淡雅，象征纯洁美好','精选白百合，花香馥郁，花姿优雅，适合庆典、探望、祝福场合',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(5,'香水百合礼盒 - 高贵典雅',3,358.00,458.00,200,400,4.9,'https://img14.360buyimg.com/pop/jfs/t1/170088/30/25137/100720/619b3b14E8185e6f8/173274fda96bb20c.jpg','https://img14.360buyimg.com/pop/jfs/t1/170088/30/25137/100720/619b3b14E8185e6f8/173274fda96bb20c.jpg','香水百合礼盒装，高贵典雅，送礼有面子','进口香水百合，花香浓郁，花型完美，配精美礼盒，适合商务送礼',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(6,'向日葵花束 - 阳光灿烂',4,168.00,218.00,300,900,4.7,'https://qcloud.dpfile.com/pc/3FaXcXiksvJyc9olWUQLd2WUFxhCoSLCX7gCI8fom5CV4ytLq4kAdOECkl3rKfu6.jpg','https://qcloud.dpfile.com/pc/3FaXcXiksvJyc9olWUQLd2WUFxhCoSLCX7gCI8fom5CV4ytLq4kAdOECkl3rKfu6.jpg','明亮向日葵，充满阳光与希望，传递正能量','精选向日葵，朵朵向阳，象征积极向上，适合祝福、鼓励送礼',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(7,'郁金香花束 - 优雅情怀',5,288.00,368.00,180,500,4.8,'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.alicdn.com%2Fi3%2F2208198261660%2FO1CN01AZKelt1O8K8OvvPyL_%2521%25212208198261660.jpg&refer=http%3A%2F%2Fimg.alicdn.com&app=2002&size=f9999,10000&q=a80&n=0https://qcloud.dpfile.com/pc/6z4vXSog-https://qcloud.dpfile.com/pc/6z4vXSog-FOZoxRU6tqg6u_ru67g3xRRNij_ZGwleKUL3FKVNOQzR4hnOchUxq8O.jpgsec=1751857375&t=2ae32a3806707c90db7e0d5a36152a54','https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.alicdn.com%2Fi3%2F2208198261660%2FO1CN01AZKelt1O8K8OvvPyL_%2521%25212208198261660.jpg&refer=http%3A%2F%2Fimg.alicdn.com&app=2002&size=f9999,10000&q=a80&n=0https://qcloud.dpfile.com/pc/6z4vXSog-https://qcloud.dpfile.com/pc/6z4vXSog-FOZoxRU6tqg6u_ru67g3xRRNij_ZGwleKUL3FKVNOQzR4hnOchUxq8O.jpgsec=1751857375&t=2ae32a3806707c90db7e0d5a36152a54','优雅郁金香，色彩丰富，象征高贵与浪漫','进口郁金香，色彩鲜艳，花型优美，适合各种庆祝场合',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(8,'混色郁金香礼盒',5,388.00,488.00,150,350,4.9,'https://qcloud.dpfile.com/pc/WZGQLwT8Q9JC2dvXaeKzKyGKzmyQNIkMoLmJ_NPqnH1_s19RoDoKq-qnEG-HKmy0.jpg','https://qcloud.dpfile.com/pc/WZGQLwT8Q9JC2dvXaeKzKyGKzmyQNIkMoLmJ_NPqnH1_s19RoDoKq-qnEG-HKmy0.jpg','多色郁金香组合，缤纷多彩，送礼佳选','红、黄、粉、白多色郁金香，配精美礼盒，花材丰富，适合高端送礼',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(9,'满天星花束 - 浪漫星空',6,128.00,168.00,399,1201,4.7,'https://qcloud.dpfile.com/pc/tSUjWiqr9Oe_gr0diUfHNU_5I1tIKBWZYay4biyqeLA57EIn_lnJvPOWlS4lMt0N.jpg','https://qcloud.dpfile.com/pc/tSUjWiqr9Oe_gr0diUfHNU_5I1tIKBWZYay4biyqeLA57EIn_lnJvPOWlS4lMt0N.jpg','梦幻满天星，小巧精致，适合搭配或单送','新鲜满天星，花朵繁密，寓意真挚关怀，可作配花或主花',1,'2025-12-22 17:14:38','2025-12-22 17:33:11',0),(10,'混合鲜花礼盒 - 缤纷绽放',7,328.00,428.00,250,700,4.9,'https://qcloud.dpfile.com/pc/TjSXU7B93NuigXpoqs82sHq_zUq0rSxOmO9Po5s9PXLliLKBKg2H8a8ZtIl-g8t2.jpg','https://qcloud.dpfile.com/pc/TjSXU7B93NuigXpoqs82sHq_zUq0rSxOmO9Po5s9PXLliLKBKg2H8a8ZtIl-g8t2.jpg','多种花材组合，色彩丰富，层次分明','玫瑰、百合、康乃馨等多种花材搭配，专业花艺师设计，精美礼盒装',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(11,'四季花束 - 春意盎然',7,268.00,338.00,220,550,4.8,'https://b0.bdstatic.com/ugc/AbiOWu3K0K6EqUBBzIB6Ygcdbd170db33b19b7c1f4918a90066c58.jpg','https://b0.bdstatic.com/ugc/AbiOWu3K0K6EqUBBzIB6Ygcdbd170db33b19b7c1f4918a90066c58.jpg','时令花材搭配，清新自然，充满生机','根据季节选择新鲜花材，色彩协调，造型优美，适合多种场合',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(12,'永生花礼盒 - 永恒之美',7,588.00,788.00,100,200,5.0,'https://img0.baidu.com/it/u=1127836703,2070477179&fm=253&app=138&f=JPEG?w=800&h=1067','https://img0.baidu.com/it/u=1127836703,2070477179&fm=253&app=138&f=JPEG?w=800&h=1067','进口永生花，保存3-5年不凋零，永恒的爱','采用进口永生花工艺，真花制作，颜色持久，配精致水晶礼盒，高端大气',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(13,'节日花篮 - 喜庆祥和',7,498.00,598.00,150,300,4.8,'https://qcloud.dpfile.com/pc/J4m1URX9pGPWNM37CMMnaGI_5wtzqbYaU568cEBfbJ4OS3gG8rPghTr_k6GvO5x5.jpg','https://qcloud.dpfile.com/pc/J4m1URX9pGPWNM37CMMnaGI_5wtzqbYaU568cEBfbJ4OS3gG8rPghTr_k6GvO5x5.jpg','大型花篮，花材丰富，适合开业庆典','多种鲜花搭配，造型大气，寓意生意兴隆，适合开业、庆典送礼',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0),(14,'99朵玫瑰花束 - 长长久久',1,999.00,1299.00,80,150,5.0,'https://qcloud.dpfile.com/pc/f4c2JIIwCgvbXvCi18mGSP-z5fB_FJfN--IEdoL9fORPDfG_Dp9RFL4aQ-qWBys3.jpg','https://qcloud.dpfile.com/pc/f4c2JIIwCgvbXvCi18mGSP-z5fB_FJfN--IEdoL9fORPDfG_Dp9RFL4aQ-qWBys3.jpg','99朵红玫瑰，寓意长长久久，求婚表白必选','精选99朵红玫瑰，花苞饱满，寓意天长地久，适合求婚、纪念日等重要时刻',1,'2025-12-22 17:14:38','2025-12-22 17:32:33',0);
/*!40000 ALTER TABLE `t_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_user`
--

DROP TABLE IF EXISTS `t_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `openid` varchar(100) DEFAULT NULL COMMENT '微信OpenID',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `password` varchar(100) DEFAULT NULL COMMENT '密码（MD5加密）',
  `gender` tinyint(1) DEFAULT '0' COMMENT '性别：0-未知，1-男，2-女',
  `user_type` tinyint(1) DEFAULT '1' COMMENT '用户类型：1-普通用户，2-管理员',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：0-禁用，1-正常',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_openid` (`openid`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_user`
--

LOCK TABLES `t_user` WRITE;
/*!40000 ALTER TABLE `t_user` DISABLE KEYS */;
INSERT INTO `t_user` VALUES (1,'ol8nk6J5xCFComcE0TLbkkAxhmec','liu','http://localhost:8080/api/uploads/2025/12/22/1766397025827_0rka2b69q14.jpeg',NULL,NULL,NULL,1,1,'2025-12-22 17:31:26','2025-12-22 17:50:27',0);
/*!40000 ALTER TABLE `t_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'flower_store'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-22 17:52:18
