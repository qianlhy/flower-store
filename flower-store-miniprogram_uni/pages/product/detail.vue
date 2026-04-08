<template>
    <view>
        <!-- pages/product/detail.wxml -->
        <view class="container" v-if="!isLoading">
            <!-- 商品轮播图 -->
            <swiper class="product-swiper" :indicator-dots="true" :autoplay="false" interval="3000" duration="500" :circular="true" @change="onSwiperChange">
                <swiper-item v-for="(item, index) in product.images" :key="index">
                    <image :src="item" mode="aspectFill" class="product-image"></image>
                </swiper-item>
            </swiper>

            <!-- 页码指示器 -->
            <view class="page-indicator">
                <text>{{ current + 1 }}/{{ product.images.length }}</text>
            </view>

            <!-- 商品信息 -->
            <view class="product-info card">
                <view class="product-price-box">
                    <text class="price">¥{{ product.price }}</text>
                    <text class="price-original">¥{{ product.originalPrice }}</text>
                </view>
                <view class="product-title">{{ product.name }}</view>
                <view class="product-desc">{{ product.description }}</view>
                <view class="product-stats">
                    <text class="stat-item">销量 {{ product.sales }}</text>
                    <text class="stat-item">库存 {{ product.inventory }}</text>
                    <text class="stat-item">评分 {{ product.rating }}</text>
                </view>
            </view>

            <!-- 购买数量 -->
            <view class="card">
                <view class="flex-between">
                    <text class="section-title">购买数量</text>
                    <view class="counter">
                        <view :class="'counter-btn ' + (count <= 1 ? 'disabled' : '')" @tap="decreaseCount">-</view>
                        <view class="counter-num">{{ count }}</view>
                        <view :class="'counter-btn ' + (count >= product.inventory ? 'disabled' : '')" @tap="increaseCount">+</view>
                    </view>
                </view>
            </view>

            <!-- 商品详情 -->
            <view class="card">
                <view class="card-header">
                    <text class="section-title">商品详情</text>
                </view>
                <view class="card-body">
                    <view class="product-detail">{{ product.detail }}</view>
                </view>
            </view>

            <!-- 更多推荐 -->
            <view class="card">
                <view class="card-header">
                    <text class="section-title">猜你喜欢</text>
                </view>
                <view class="related-products grid grid-2">
                    <!-- 这里可以添加相关商品推荐 -->
                </view>
            </view>
        </view>

        <!-- 加载状态 -->
        <view class="loading-container" v-if="isLoading">
            <view class="loading">
                <image src="/static/images/icons/loading.png" mode="aspectFit" class="loading-icon"></image>
                <text>加载中...</text>
            </view>
        </view>

        <!-- 底部操作栏 -->
        <view class="footer">
            <view class="footer-left">
                <view class="footer-icon-btn" @tap="showMoreActions">
                    <image src="/static/images/icons/more.png" class="footer-icon"></image>
                    <text>更多</text>
                </view>
                <view class="footer-icon-btn" @tap="contactService">
                    <image src="/static/images/icons/service.png" class="footer-icon"></image>
                    <text>客服</text>
                </view>
                <navigator url="/pages/cart/cart" open-type="switchTab" class="footer-icon-btn">
                    <image src="/static/images/icons/cart.png" class="footer-icon"></image>
                    <text>购物车</text>
                    <view class="cart-badge" v-if="app.globalData.cart.length > 0">{{ app.globalData.cart.length }}</view>
                </navigator>
            </view>
            <view class="footer-right">
                <view class="add-cart-btn" @tap="addToCart">加入购物车</view>
                <view class="buy-now-btn" @tap="buyNow">立即购买</view>
            </view>
        </view>

        <!-- 添加购物车成功提示 -->
        <view class="toast-container" v-if="isAddedToCart">
            <view class="toast-content">
                <icon type="success" size="24"></icon>
                <text>已加入购物车</text>
            </view>
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

        <!-- 更多操作菜单 -->
        <view class="action-sheet-mask" v-if="showActionSheet" @tap="closeActionSheet"></view>
        <view :class="'action-sheet ' + (showActionSheet ? 'show' : '')">
            <view class="action-sheet-header">
                <text>更多操作</text>
                <view class="action-sheet-close" @tap="closeActionSheet">×</view>
            </view>
            <view class="action-sheet-body">
                <view class="action-item" @tap="collectProduct">
                    <image src="/static/images/icons/collect.png" class="action-icon"></image>
                    <text>收藏商品</text>
                </view>
                <view class="action-item" @tap="shareProduct">
                    <image src="/static/images/icons/share.png" class="action-icon"></image>
                    <text>分享商品</text>
                </view>
                <button class="action-item share-btn" open-type="share">
                    <image src="/static/images/icons/share.png" class="action-icon"></image>
                    <text>分享给朋友</text>
                </button>
            </view>
        </view>
    </view>
</template>

<script>
// pages/product/detail.js
const app = getApp();
const productApi = require('../../api/product');
const favoriteApi = require('../../api/favorite');
const cartApi = require('../../api/cart');
export default {
    data() {
        return {
            product: null,
            count: 1,
            isLoading: true,
            isAddedToCart: false,
            current: 0,
            showActionSheet: false,
            showContactModal: false,
            isFavorite: false,

            app: {
                globalData: {
                    cart: []
                }
            }
        };
    }
    /**
     * 生命周期函数--监听页面加载
     */,
    onLoad(options) {
        const { id } = options;
        if (id) {
            this.loadProductDetail(parseInt(id));
        } else {
            uni.showToast({
                title: '商品信息不存在',
                icon: 'error'
            });
            setTimeout(() => {
                uni.navigateBack();
            }, 1500);
        }
    },
    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady() {},
    /**
     * 生命周期函数--监听页面显示
     */
    onShow() {},
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
    onShareAppMessage() {
        const { product } = this;
        return {
            title: product.name,
            path: `/pages/product/detail?id=${product.id}`,
            imageUrl: product.image
        };
    },
    methods: {
        // 加载商品详情
        loadProductDetail: function (productId) {
            this.setData({
                isLoading: true
            });
            const token = uni.getStorageSync('token');
            productApi
                .getProductById(productId)
                .then((product) => {
                    // 处理images字段：如果是字符串，转换为数组
                    if (product.images && typeof product.images === 'string') {
                        product.images = product.images.split(',').filter((img) => img.trim());
                    }
                    // 如果images为空或不是数组，使用主图作为默认
                    if (!Array.isArray(product.images) || product.images.length === 0) {
                        product.images = [product.image];
                    }

                    // 设置页面标题
                    uni.setNavigationBarTitle({
                        title: product.name.split('-')[0].trim()
                    });

                    // 如果已登录，检查是否已收藏
                    if (token) {
                        return favoriteApi.checkFavorite(productId).then((isFavorite) => {
                            this.setData({
                                product,
                                isLoading: false,
                                isFavorite: isFavorite.isFavorite
                            });
                        });
                    } else {
                        this.setData({
                            product,
                            isLoading: false,
                            isFavorite: false
                        });
                    }
                })
                .catch((err) => {
                    console.error('加载商品详情失败', err);
                    this.setData({
                        isLoading: false
                    });
                    uni.showToast({
                        title: '加载失败',
                        icon: 'error'
                    });
                    setTimeout(() => {
                        uni.navigateBack();
                    }, 1500);
                });
        },

        // 减少购买数量
        decreaseCount: function () {
            if (this.count > 1) {
                this.setData({
                    count: this.count - 1
                });
            }
        },

        // 增加购买数量
        increaseCount: function () {
            if (this.count < this.product.inventory) {
                this.setData({
                    count: this.count + 1
                });
            } else {
                uni.showToast({
                    title: '库存不足',
                    icon: 'none'
                });
            }
        },

        // 添加到购物车
        addToCart: function () {
            const { product, count } = this;
            const token = uni.getStorageSync('token');
            if (!token) {
                uni.showToast({
                    title: '请先登录',
                    icon: 'none'
                });
                setTimeout(() => {
                    uni.navigateTo({
                        url: '/pages/login/login'
                    });
                }, 1500);
                return;
            }
            cartApi
                .addToCart(product.id, count)
                .then(() => {
                    this.setData({
                        isAddedToCart: true
                    });
                    setTimeout(() => {
                        this.setData({
                            isAddedToCart: false
                        });
                    }, 1500);
                })
                .catch((err) => {
                    console.error('添加购物车失败', err);
                });
        },

        // 立即购买
        buyNow: function () {
            const { product, count } = this;
            const token = uni.getStorageSync('token');
            if (!token) {
                uni.showToast({
                    title: '请先登录',
                    icon: 'none'
                });
                setTimeout(() => {
                    uni.navigateTo({
                        url: '/pages/login/login'
                    });
                }, 1500);
                return;
            }

            // 添加到购物车
            cartApi
                .addToCart(product.id, count)
                .then(() => {
                    // 跳转到购物车页面
                    uni.switchTab({
                        url: '/pages/cart/cart'
                    });
                })
                .catch((err) => {
                    console.error('添加购物车失败', err);
                });
        },

        // 显示更多操作菜单
        showMoreActions: function () {
            this.setData({
                showActionSheet: true
            });
        },

        // 关闭更多操作菜单
        closeActionSheet: function () {
            this.setData({
                showActionSheet: false
            });
        },

        // 收藏商品
        collectProduct: function () {
            const { product, isFavorite } = this;
            const token = uni.getStorageSync('token');

            // 检查是否已登录
            if (!token) {
                uni.showModal({
                    title: '提示',
                    content: '请先登录后再收藏商品',
                    confirmText: '去登录',
                    success: (res) => {
                        if (res.confirm) {
                            uni.navigateTo({
                                url: '/pages/login/login'
                            });
                        }
                    }
                });
                return;
            }
            if (isFavorite) {
                // 如果已收藏，则取消收藏
                favoriteApi
                    .removeFavorite(product.id)
                    .then(() => {
                        this.setData({
                            isFavorite: false
                        });
                        uni.showToast({
                            title: '已取消收藏',
                            icon: 'success'
                        });
                    })
                    .catch((err) => {
                        console.error('取消收藏失败', err);
                    });
            } else {
                // 如果未收藏，则添加收藏
                favoriteApi
                    .addFavorite(product.id)
                    .then(() => {
                        this.setData({
                            isFavorite: true
                        });
                        uni.showToast({
                            title: '收藏成功',
                            icon: 'success'
                        });
                    })
                    .catch((err) => {
                        console.error('收藏失败', err);
                    });
            }
            this.closeActionSheet();
        },

        // 轮播图切换事件
        onSwiperChange: function (e) {
            this.setData({
                current: e.detail.current
            });
        },

        // 联系客服 - 显示弹窗
        contactService: function () {
            this.setData({
                showContactModal: true
            });
            this.closeActionSheet();
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
        },

        shareProduct() {
            console.log('占位：函数 shareProduct 未声明');
        }
    }
};
</script>
<style>
/* pages/product/detail.wxss */
.container {
    padding-bottom: 120rpx;
}

/* 商品轮播图 */
.product-swiper {
    width: 100%;
    height: 750rpx;
}

.product-image {
    width: 100%;
    height: 100%;
}

/* 页码指示器 */
.page-indicator {
    position: absolute;
    right: 30rpx;
    top: 680rpx;
    background-color: rgba(0, 0, 0, 0.5);
    color: #fff;
    font-size: 24rpx;
    padding: 8rpx 16rpx;
    border-radius: 20rpx;
    z-index: 10;
}

/* 商品信息 */
.product-info {
    padding: 30rpx;
    margin-top: 20rpx;
}

.product-price-box {
    display: flex;
    align-items: baseline;
    margin-bottom: 20rpx;
}

.price {
    font-size: 40rpx;
    color: var(--price-color);
    font-weight: bold;
}

.price-original {
    color: #999;
    text-decoration: line-through;
    font-size: 28rpx;
    margin-left: 16rpx;
}

.product-title {
    font-size: 32rpx;
    font-weight: bold;
    line-height: 1.4;
    margin-bottom: 16rpx;
}

.product-desc {
    font-size: 28rpx;
    color: #666;
    margin-bottom: 20rpx;
    line-height: 1.4;
}

.product-stats {
    display: flex;
    color: #999;
    font-size: 24rpx;
}

.stat-item {
    margin-right: 30rpx;
}

/* 数量选择器 */
.section-title {
    font-size: 30rpx;
    font-weight: bold;
}

.counter {
    display: flex;
    align-items: center;
}

.counter-btn {
    width: 60rpx;
    height: 60rpx;
    border: 1px solid #eee;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 28rpx;
}

.counter-btn.disabled {
    color: #ccc;
}

.counter-num {
    width: 80rpx;
    height: 60rpx;
    border-top: 1px solid #eee;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 28rpx;
}

/* 商品详情 */
.product-detail {
    font-size: 28rpx;
    line-height: 1.6;
    color: #333;
    padding: 20rpx 0;
}

/* 底部操作栏 */
.footer {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    height: 100rpx;
    background-color: #fff;
    border-top: 1px solid #eee;
    padding: 0 20rpx;
    z-index: 99;
}

.footer-left {
    display: flex;
    height: 100%;
}

.footer-icon-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-size: 20rpx;
    color: #666;
    position: relative;
    width: 100rpx;
    height: 100%;
}

.footer-icon {
    width: 44rpx;
    height: 44rpx;
    margin-bottom: 6rpx;
}

.cart-badge {
    position: absolute;
    top: 6rpx;
    right: 14rpx;
    background-color: var(--primary-color);
    color: #fff;
    font-size: 18rpx;
    min-width: 30rpx;
    height: 30rpx;
    border-radius: 15rpx;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 0 6rpx;
}

.footer-right {
    display: flex;
    height: 80rpx;
}

.add-cart-btn,
.buy-now-btn {
    height: 80rpx;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 28rpx;
    padding: 0 30rpx;
    margin: 0;
    line-height: 1;
}

.add-cart-btn {
    background-color: #fff;
    color: var(--primary-color);
    border: 1px solid var(--primary-color);
    border-radius: 40rpx 0 0 40rpx;
}

.buy-now-btn {
    background-color: var(--primary-color);
    color: #fff;
    border: 1px solid var(--primary-color);
    border-radius: 0 40rpx 40rpx 0;
}

/* 加载状态 */
.loading-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}

.loading {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.loading-icon {
    width: 80rpx;
    height: 80rpx;
    margin-bottom: 20rpx;
}

/* 添加购物车成功提示 */
.toast-container {
    position: fixed;
    bottom: 160rpx;
    left: 0;
    right: 0;
    display: flex;
    justify-content: center;
    z-index: 999;
    pointer-events: none;
}

.toast-content {
    background-color: rgba(0, 0, 0, 0.7);
    color: #fff;
    border-radius: 8rpx;
    padding: 16rpx 30rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28rpx;
}

.toast-content text {
    margin-left: 10rpx;
}

/* 更多操作菜单 */
.action-sheet-mask {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 1000;
}

.action-sheet {
    position: fixed;
    bottom: -70%;
    left: 0;
    right: 0;
    background-color: #fff;
    border-radius: 24rpx 24rpx 0 0;
    transition: bottom 0.3s;
    z-index: 1001;
}

.action-sheet.show {
    bottom: 0;
}

.action-sheet-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 30rpx;
    border-bottom: 1px solid #f5f5f5;
}

.action-sheet-close {
    font-size: 40rpx;
    color: #999;
    width: 60rpx;
    height: 60rpx;
    display: flex;
    justify-content: center;
    align-items: center;
}

.action-sheet-body {
    padding: 30rpx;
}

.action-item {
    display: flex;
    align-items: center;
    margin-bottom: 40rpx;
    background-color: transparent;
    font-size: 28rpx;
    color: #333;
    padding: 0;
    line-height: 1;
    text-align: left;
}

.action-item:after {
    border: none;
}

.action-icon {
    width: 48rpx;
    height: 48rpx;
    margin-right: 20rpx;
}

.share-btn {
    display: flex;
    align-items: center;
    padding: 0;
    margin: 0;
    border-radius: 0;
    background-color: transparent;
    line-height: 1;
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
