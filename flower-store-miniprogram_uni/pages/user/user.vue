<template>
    <!-- pages/user/user.wxml -->
    <view class="user-container">
        <!-- 用户信息头部 -->
        <view class="user-header">
            <view class="header-bg"></view>
            <view class="user-info">
                <view class="avatar-box" v-if="isLogin">
                    <image class="user-avatar" :src="userInfo.avatarUrl || '/images/icons/default-avatar.png'"></image>
                </view>
                <view class="avatar-box" v-else @tap="goToLogin">
                    <image class="user-avatar" src="/static/images/icons/default-avatar.png"></image>
                </view>

                <view class="user-name" v-if="isLogin">
                    <text>{{ userInfo.nickName || '微信用户' }}</text>
                </view>
                <view class="login-btn" v-else @tap="goToLogin">
                    <text>点击登录</text>
                </view>
            </view>
        </view>

        <!-- 未登录状态下的登录提示 -->
        <view class="login-prompt" v-if="!isLogin">
            <view class="login-prompt-text">登录后查看您的订单和个人信息</view>
            <button class="primary-login-btn" @tap="goToLogin">立即登录/注册</button>
        </view>

        <!-- 订单信息 -->
        <view class="order-section" v-if="isLogin">
            <view class="section-header" @tap="viewAllOrders">
                <text class="section-title">我的订单</text>
                <view class="section-more">
                    <text>全部订单</text>
                    <text class="arrow">></text>
                </view>
            </view>
            <view class="order-types">
                <view class="order-type" @tap="viewOrdersByStatus" data-status="待发货">
                    <view class="order-icon-wrap">
                        <image class="order-icon" src="/static/images/icons/unshipped.png"></image>
                        <view class="order-badge" v-if="orderStats.unshipped > 0">{{ orderStats.unshipped }}</view>
                    </view>
                    <text>待发货</text>
                </view>
                <view class="order-type" @tap="viewOrdersByStatus" data-status="待收货">
                    <view class="order-icon-wrap">
                        <image class="order-icon" src="/static/images/icons/shipped.png"></image>
                        <view class="order-badge" v-if="orderStats.shipped > 0">{{ orderStats.shipped }}</view>
                    </view>
                    <text>待收货</text>
                </view>
                <view class="order-type" @tap="viewOrdersByStatus" data-status="已完成">
                    <view class="order-icon-wrap">
                        <image class="order-icon" src="/static/images/icons/completed.png"></image>
                        <view class="order-badge" v-if="orderStats.completed > 0">{{ orderStats.completed }}</view>
                    </view>
                    <text>已完成</text>
                </view>
            </view>
        </view>

        <!-- 常用功能 -->
        <view class="features">
            <view class="feature-item" @tap="navigateTo" data-url="/pages/address/list">
                <image class="feature-icon" src="/static/images/icons/address.png"></image>
                <text>收货地址</text>
                <text class="arrow">></text>
            </view>

            <view class="feature-item" @tap="navigateTo" data-url="/pages/collection/collection">
                <image class="feature-icon" src="/static/images/icons/favorite.png"></image>
                <text>我的收藏</text>
                <text class="arrow">></text>
            </view>

            <view class="feature-item" @tap="contactService">
                <image class="feature-icon" src="/static/images/icons/service.png"></image>
                <text>联系客服</text>
                <text class="arrow">></text>
            </view>

            <view class="feature-item" @tap="navigateTo" data-url="/pages/settings/settings">
                <image class="feature-icon" src="/static/images/icons/settings.png"></image>
                <text>设置</text>
                <text class="arrow">></text>
            </view>

            <view class="feature-item" v-if="isLogin" @tap="logout">
                <image class="feature-icon" src="/static/images/icons/logout.png"></image>
                <text>退出登录</text>
                <text class="arrow">></text>
            </view>
        </view>

        <!-- 版本信息 -->
        <view class="version-info">
            <text>鲜花铺子 v1.0.0</text>
        </view>

        <!-- 客服联系弹窗 -->
        <view class="contact-modal-mask" v-if="showContactModal" @tap="closeContactModal"></view>
        <view :class="'contact-modal ' + (showContactModal ? 'show' : '')">
            <view class="contact-modal-header">
                <text>联系客服</text>
                <view class="contact-modal-close" @tap="closeContactModal">×</view>
            </view>
            <view class="contact-modal-body">
                <!-- 微信二维码区域 -->
                <view class="qr-section">
                    <image class="qr-image" src="/static/images/wechat-qr.png" mode="aspectFit" show-menu-by-longpress></image>
                    <text class="qr-tip">长按识别二维码添加微信客服</text>
                </view>
                
                <!-- 分隔线 -->
                <view class="divider"></view>
                
                <!-- 电话区域 -->
                <view class="phone-section">
                    <text class="phone-label">或拨打客服电话</text>
                    <view class="phone-number" @tap="makePhoneCall">
                        <text class="phone-icon">📞</text>
                        <text class="phone-text">89801888818</text>
                    </view>
                    <text class="phone-time">服务时间：9:00 - 21:00</text>
                </view>
            </view>
        </view>
    </view>
</template>

<script>
// pages/user/user.js
const orderApi = require('../../api/order');
const authApi = require('../../api/auth');
export default {
    data() {
        return {
            userInfo: null,
            isLogin: false,
            orderStats: {
                unshipped: 0,
                shipped: 0,
                completed: 0
            },
            showContactModal: false
        };
    }
    /**
     * 生命周期函数--监听页面加载
     */,
    onLoad(options) {},
    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady() {},
    /**
     * 生命周期函数--监听页面显示
     */
    onShow() {
        // 检查登录状态
        this.checkLoginStatus();

        // 获取订单统计
        this.getOrderStats();
    },
    /**
     * 生命周期函数--监听页面隐藏
     */
    onHide() {},
    /**
     * 生命周期函数--监听页面卸载
     */
    onUnload() {},
    /**
     * 页面相关事件处理函数--监听用户下拉动作
     */
    onPullDownRefresh() {},
    /**
     * 页面上拉触底事件的处理函数
     */
    onReachBottom() {},
    /**
     * 用户点击右上角分享
     */
    onShareAppMessage() {},
    methods: {
        // 检查登录状态
        checkLoginStatus: function () {
            const token = uni.getStorageSync('token');
            const userInfo = uni.getStorageSync('userInfo');
            this.setData({
                userInfo,
                isLogin: !!token
            });
        },

        // 获取订单统计数据
        getOrderStats: function () {
            const token = uni.getStorageSync('token');
            if (!token) {
                return;
            }

            // 调用后端统计接口
            orderApi
                .getOrderStatistics()
                .then((data) => {
                    this.setData({
                        orderStats: data
                    });
                })
                .catch((err) => {
                    console.error('获取订单统计失败', err);
                    // 如果失败，使用默认值
                    this.setData({
                        orderStats: {
                            unpaid: 0,
                            unshipped: 0,
                            shipped: 0,
                            completed: 0
                        }
                    });
                });
        },

        // 去登录
        goToLogin: function () {
            uni.navigateTo({
                url: '/pages/login/login'
            });
        },

        // 登出
        logout: function () {
            uni.showModal({
                title: '提示',
                content: '确定要退出登录吗？',
                success: (res) => {
                    if (res.confirm) {
                        // 清除token和用户信息
                        uni.removeStorageSync('token');
                        uni.removeStorageSync('userInfo');
                        this.setData({
                            userInfo: null,
                            isLogin: false
                        });
                        uni.showToast({
                            title: '已退出登录',
                            icon: 'success'
                        });
                    }
                }
            });
        },

        // 查看全部订单
        viewAllOrders: function () {
            if (!this.isLogin) {
                uni.navigateTo({
                    url: '/pages/login/login'
                });
                return;
            }
            uni.navigateTo({
                url: '/pages/order/list'
            });
        },

        // 查看特定状态订单
        viewOrdersByStatus: function (e) {
            if (!this.isLogin) {
                uni.navigateTo({
                    url: '/pages/login/login'
                });
                return;
            }
            const { status } = e.currentTarget.dataset;
            const statusMap = {
                待发货: '待发货',
                待收货: '待收货',
                已完成: '已完成'
            };
            uni.navigateTo({
                url: `/pages/order/list?status=${statusMap[status]}`
            });
        },

        // 导航到页面
        navigateTo: function (e) {
            if (!this.isLogin) {
                uni.navigateTo({
                    url: '/pages/login/login'
                });
                return;
            }
            const url = e.currentTarget.dataset.url;
            uni.navigateTo({
                url: url
            });
        },

        // 联系客服 - 显示弹窗
        contactService: function () {
            this.setData({
                showContactModal: true
            });
        },

        // 关闭客服弹窗
        closeContactModal: function () {
            this.setData({
                showContactModal: false
            });
        },

        // 拨打电话
        makePhoneCall: function () {
            this.closeContactModal();
            setTimeout(() => {
                uni.makePhoneCall({
                    phoneNumber: '89801888818'
                });
            }, 300);
        }
    }
};
</script>
<style>
/* pages/user/user.wxss */
.user-container {
    min-height: 100vh;
    background-color: #f7f7f7;
}

/* 用户信息头部 */
.user-header {
    position: relative;
    padding-top: 60rpx;
    padding-bottom: 30rpx;
    margin-bottom: 20rpx;
}

.header-bg {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 220rpx;
    background: linear-gradient(to right, var(--primary-color), #ff9999);
    z-index: -1;
    border-bottom-left-radius: 30% 20rpx;
    border-bottom-right-radius: 30% 20rpx;
}

.user-info {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.avatar-box {
    width: 150rpx;
    height: 150rpx;
    border-radius: 50%;
    overflow: hidden;
    background-color: #fff;
    margin-bottom: 20rpx;
    box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.1);
}

.user-avatar {
    width: 100%;
    height: 100%;
}

.user-name {
    color: #fff;
    font-size: 32rpx;
    font-weight: bold;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.login-btn {
    color: #fff;
    font-size: 32rpx;
    padding: 10rpx 40rpx;
    border: 1px solid #fff;
    border-radius: 30rpx;
}

/* 未登录状态下的登录提示 */
.login-prompt {
    background-color: #fff;
    border-radius: 16rpx;
    margin: 0 20rpx 20rpx;
    padding: 40rpx 30rpx;
    box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
    display: flex;
    flex-direction: column;
    align-items: center;
}

.login-prompt-text {
    font-size: 28rpx;
    color: #666;
    margin-bottom: 30rpx;
}

.primary-login-btn {
    background-color: var(--primary-color, #ff6b81);
    color: #fff;
    font-size: 30rpx;
    width: 80%;
    padding: 20rpx 0;
    border-radius: 40rpx;
    border: none;
}

/* 订单信息 */
.order-section {
    background-color: #fff;
    border-radius: 16rpx;
    margin: 0 20rpx 20rpx;
    padding: 30rpx;
    box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30rpx;
}

.section-title {
    font-size: 32rpx;
    font-weight: bold;
    color: #333;
}

.section-more {
    font-size: 26rpx;
    color: #999;
    display: flex;
    align-items: center;
}

.arrow {
    margin-left: 6rpx;
}

.order-types {
    display: flex;
    justify-content: space-between;
}

.order-type {
    display: flex;
    flex-direction: column;
    align-items: center;
    font-size: 24rpx;
    color: #666;
}

.order-icon-wrap {
    position: relative;
    margin-bottom: 10rpx;
}

.order-icon {
    width: 64rpx;
    height: 64rpx;
}

.order-badge {
    position: absolute;
    top: -10rpx;
    right: -10rpx;
    min-width: 36rpx;
    height: 36rpx;
    background-color: var(--primary-color);
    color: #fff;
    border-radius: 18rpx;
    font-size: 22rpx;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 0 8rpx;
}

/* 常用功能 */
.features {
    background-color: #fff;
    border-radius: 16rpx;
    margin: 0 20rpx 20rpx;
    padding: 0 30rpx;
    box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.feature-item {
    display: flex;
    align-items: center;
    padding: 30rpx 0;
    border-bottom: 1px solid #f5f5f5;
}

.feature-item:last-child {
    border-bottom: none;
}

.feature-icon {
    width: 48rpx;
    height: 48rpx;
    margin-right: 20rpx;
}

.feature-item text {
    font-size: 28rpx;
    color: #333;
}

.feature-item .arrow {
    margin-left: auto;
    color: #999;
}

/* 版本信息 */
.version-info {
    text-align: center;
    padding: 40rpx 0;
    color: #999;
    font-size: 24rpx;
}

/* 客服联系弹窗 */
.contact-modal-mask {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 1000;
}

.contact-modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%) scale(0.9);
    width: 80%;
    max-width: 600rpx;
    background-color: #fff;
    border-radius: 24rpx;
    opacity: 0;
    transition: all 0.3s;
    z-index: 1001;
}

.contact-modal.show {
    transform: translate(-50%, -50%) scale(1);
    opacity: 1;
}

.contact-modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 30rpx;
    border-bottom: 1px solid #f5f5f5;
}

.contact-modal-header text {
    font-size: 32rpx;
    font-weight: bold;
    color: #333;
}

.contact-modal-close {
    font-size: 40rpx;
    color: #999;
    width: 60rpx;
    height: 60rpx;
    display: flex;
    justify-content: center;
    align-items: center;
}

.contact-modal-body {
    padding: 40rpx;
}

/* 二维码区域 */
.qr-section {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 30rpx;
}

.qr-section .qr-image {
    width: 360rpx;
    height: 360rpx;
    margin-bottom: 20rpx;
}

.qr-section .qr-tip {
    font-size: 26rpx;
    color: #999;
}

/* 分隔线 */
.divider {
    height: 1px;
    background-color: #eee;
    margin: 30rpx 0;
}

/* 电话区域 */
.phone-section {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.phone-label {
    font-size: 26rpx;
    color: #999;
    margin-bottom: 20rpx;
}

.phone-number {
    display: flex;
    align-items: center;
    padding: 20rpx 40rpx;
    background-color: #f0f9ff;
    border-radius: 50rpx;
    margin-bottom: 16rpx;
}

.phone-icon {
    font-size: 36rpx;
    margin-right: 12rpx;
}

.phone-text {
    font-size: 36rpx;
    font-weight: bold;
    color: #1989fa;
}

.phone-time {
    font-size: 24rpx;
    color: #ccc;
}
</style>
