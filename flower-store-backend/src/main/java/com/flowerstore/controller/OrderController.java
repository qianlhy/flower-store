package com.flowerstore.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.flowerstore.common.PageResult;
import com.flowerstore.common.Result;
import com.flowerstore.entity.Order;
import com.flowerstore.entity.OrderItem;
import com.flowerstore.service.OrderService;
import com.flowerstore.util.JwtUtils;
import com.flowerstore.websocket.OrderNotificationWebSocket;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 订单控制器
 */
@RestController
@RequestMapping("/order")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private JwtUtils jwtUtils;

    /**
     * 分页查询订单列表（管理端）
     */
    @GetMapping("/page")
    public Result<PageResult<Order>> getPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String orderNo,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long userId) {
        Page<Order> page = orderService.getPage(current, size, orderNo, status, userId);
        PageResult<Order> result = new PageResult<>(
                page.getTotal(), page.getRecords(), page.getCurrent(), page.getSize());
        return Result.success(result);
    }

    /**
     * 根据用户ID查询订单列表（小程序端）
     */
    @GetMapping("/list")
    public Result<List<Map<String, Object>>> getList(
            @RequestHeader("Authorization") String token,
            @RequestParam(required = false) Integer status) {
        try {
            Long userId = jwtUtils.getUserIdFromToken(token);
            List<Map<String, Object>> list = orderService.getListByUserId(userId, status);
            return Result.success(list);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取订单统计（小程序端）
     */
    @GetMapping("/statistics")
    public Result<Map<String, Long>> getStatistics(@RequestHeader("Authorization") String token) {
        try {
            Long userId = jwtUtils.getUserIdFromToken(token);
            Map<String, Long> statistics = orderService.getStatistics(userId);
            return Result.success(statistics);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 根据ID查询订单详情
     */
    @GetMapping("/{id}")
    public Result<Map<String, Object>> getById(@PathVariable Long id) {
        Order order = orderService.getById(id);
        if (order == null) {
            return Result.error("订单不存在");
        }
        List<OrderItem> items = orderService.getOrderItems(id);

        Map<String, Object> result = new HashMap<>();
        // 返回订单基本信息（包含 statusText）
        Map<String, Object> orderMap = new HashMap<>();
        orderMap.put("id", order.getId());
        orderMap.put("orderNo", order.getOrderNo());
        orderMap.put("userId", order.getUserId());
        orderMap.put("receiverName", order.getReceiverName());
        orderMap.put("receiverPhone", order.getReceiverPhone());
        orderMap.put("province", order.getProvince());
        orderMap.put("city", order.getCity());
        orderMap.put("district", order.getDistrict());
        orderMap.put("address", order.getAddress());
        orderMap.put("totalPrice", order.getTotalPrice());
        orderMap.put("freight", order.getFreight());
        orderMap.put("actualPayment", order.getActualPayment());
        orderMap.put("paymentMethod", order.getPaymentMethod());
        orderMap.put("remark", order.getRemark());
        orderMap.put("status", order.getStatus());
        orderMap.put("statusText", getStatusText(order.getStatus()));
        orderMap.put("payTime", order.getPayTime());
        orderMap.put("deliveryTime", order.getDeliveryTime());
        orderMap.put("finishTime", order.getFinishTime());
        orderMap.put("createTime", order.getCreateTime());
        orderMap.put("updateTime", order.getUpdateTime());

        result.put("order", orderMap);
        result.put("items", items);

        return Result.success(result);
    }

    /**
     * 将数字状态转换为中文文本
     */
    private String getStatusText(Integer status) {
        if (status == null) return "";
        switch (status) {
            case 2: return "待发货";
            case 3: return "待收货";
            case 4: return "已完成";
            case 5: return "已取消";
            default: return "待发货";
        }
    }

    /**
     * 创建订单
     */
    @PostMapping
    public Result<Order> create(
            @RequestHeader("Authorization") String token,
            @RequestBody Map<String, Object> params) {
        try {
            Long userId = jwtUtils.getUserIdFromToken(token);
            
            Order order = new Order();
            order.setUserId(userId);
            order.setReceiverName(getStringValue(params, "receiverName"));
            order.setReceiverPhone(getStringValue(params, "receiverPhone"));
            order.setProvince(getStringValue(params, "province"));
            order.setCity(getStringValue(params, "city"));
            order.setDistrict(getStringValue(params, "district"));
            order.setAddress(getStringValue(params, "address"));
            order.setPaymentMethod(getStringValue(params, "paymentMethod", "online"));
            order.setRemark(getStringValue(params, "remark"));
            
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> items = (List<Map<String, Object>>) params.get("items");
            if (items == null || items.isEmpty()) {
                return Result.error("订单商品不能为空");
            }
            
            Order newOrder = orderService.createOrder(order, items);
            
            // 发送新订单通知
            Map<String, Object> notificationData = new HashMap<>();
            notificationData.put("orderId", newOrder.getId());
            notificationData.put("orderNo", newOrder.getOrderNo());
            notificationData.put("actualPayment", newOrder.getActualPayment());
            OrderNotificationWebSocket.sendNewOrderNotification(notificationData);
            
            return Result.success(newOrder);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("创建订单失败: " + e.getMessage());
        }
    }
    
    /**
     * 从Map中获取字符串值，处理null情况
     */
    private String getStringValue(Map<String, Object> params, String key) {
        return getStringValue(params, key, "");
    }
    
    /**
     * 从Map中获取字符串值，带默认值
     */
    private String getStringValue(Map<String, Object> params, String key, String defaultValue) {
        Object value = params.get(key);
        if (value == null) {
            return defaultValue;
        }
        return value.toString();
    }

    /**
     * 更新订单状态
     */
    @PutMapping("/{id}/status")
    public Result<String> updateStatus(
            @PathVariable Long id,
            @RequestParam Integer status) {
        try {
            orderService.updateStatus(id, status);
            return Result.success("更新成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 取消订单
     */
    @PutMapping("/{id}/cancel")
    public Result<String> cancel(@PathVariable Long id) {
        try {
            orderService.cancelOrder(id);
            return Result.success("取消成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取订单统计数据
     */
    @GetMapping("/admin/statistics")
    public Result<Map<String, Object>> getStatistics() {
        Map<String, Object> statistics = orderService.getStatistics();
        return Result.success(statistics);
    }
}

