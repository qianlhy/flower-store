<template>
    <!-- pages/order/order.wxml -->
    <view class="order-container">
        <!-- 收货地址 -->
        <view class="address-section">
            <view class="address-empty" v-if="!hasAddress" @tap="addAddress">
                <view class="add-address">
                    <image src="/static/images/icons/add-address.png" class="add-icon"></image>
                    <text>添加收货地址</text>
                </view>
                <view class="arrow">></view>
            </view>

            <view class="address-info" v-else @tap="selectAddress">
                <view class="address-detail">
                    <view class="name-phone">
                        <text class="name">{{ selectedAddress.name }}</text>
                        <text class="phone">{{ selectedAddress.phone }}</text>
                    </view>
                    <view class="address">
                        <text class="default-tag" v-if="selectedAddress.isDefault">默认</text>
                        <text class="address-text">{{ selectedAddress.province }}{{ selectedAddress.city }}{{ selectedAddress.district }}{{ selectedAddress.address }}</text>
                    </view>
                </view>
                <view class="arrow">></view>
            </view>
        </view>

        <!-- 商品列表 -->
        <view class="goods-section">
            <view class="section-title">商品清单</view>
            <view class="goods-list">
                <view class="goods-item" v-for="(item, index) in orderItems" :key="index">
                    <image class="goods-image" :src="item.image" mode="aspectFill"></image>

                    <view class="goods-info">
                        <text class="goods-name text-ellipsis">{{ item.name }}</text>
                        <view class="goods-price-box">
                            <text class="price">¥{{ item.price }}</text>
                            <text class="count">x{{ item.count }}</text>
                        </view>
                    </view>
                </view>
            </view>
        </view>

        <!-- 订单备注 -->
        <view class="remark-section">
            <view class="section-title">订单备注</view>
            <textarea class="remark-input" placeholder="请输入订单备注（选填）" maxlength="100" :value="remark" @input="inputRemark"></textarea>
        </view>

        <!-- 订单金额 -->
        <view class="amount-section">
            <view class="amount-item">
                <text class="amount-label">商品金额</text>
                <text class="amount-value">¥{{ totalPrice }}</text>
            </view>
            <view class="amount-item">
                <text class="amount-label">运费</text>
                <text class="amount-value">¥{{ freight }}</text>
            </view>
            <view class="divider"></view>
            <view class="amount-item total">
                <text class="amount-label">实付款</text>
                <text class="amount-value price">¥{{ actualPayment }}</text>
            </view>
        </view>

        <!-- 底部提交栏 -->
        <view class="footer">
            <view class="total-info">
                <text class="total-label">合计：</text>
                <text class="total-price">¥{{ actualPayment }}</text>
            </view>
            <button :class="'submit-btn ' + (isLoading ? 'loading' : '')" @tap="submitOrder" :disabled="isLoading">
                {{ isLoading ? '提交中...' : '提交订单' }}
            </button>
        </view>
    </view>
</template>

<script>
// pages/order/order.js
const app = getApp();
const orderApi = require('../../api/order');
const addressApi = require('../../api/address');
export default {
    data() {
        return {
            orderItems: [],
            totalPrice: 0,
            totalCount: 0,
            freight: 0,
            actualPayment: 0,
            selectedAddress: null,
            hasAddress: false,
            remark: '',
            isLoading: false
        };
    }
    /**
     * 生命周期函数--监听页面加载
     */,
    onLoad(options) {
        // 获取结算商品
        this.getCheckoutItems();

        // 获取默认地址
        this.getDefaultAddress();
    },
    /**
     * 生命周期函数--监听页面显示
     */
    onShow() {
        // 更新默认地址
        if (!this.selectedAddress) {
            this.getDefaultAddress();
        }
    },
    methods: {
        // 获取结算商品
        getCheckoutItems: function () {
            const checkoutItems = uni.getStorageSync('checkoutItems') || [];
            if (checkoutItems.length === 0) {
                uni.showToast({
                    title: '请选择商品',
                    icon: 'none'
                });
                setTimeout(() => {
                    uni.navigateBack();
                }, 1500);
                return;
            }

            // 计算总价和总数量
            let totalPrice = 0;
            let totalCount = 0;
            checkoutItems.forEach((item) => {
                totalPrice += item.price * item.count;
                totalCount += item.count;
            });

            // 计算运费（这里简单处理，实际应该根据配送地址和商品重量等因素计算）
            const freight = totalPrice >= 99 ? 0 : 8;

            // 计算实际支付金额
            const actualPayment = totalPrice + freight;
            this.setData({
                orderItems: checkoutItems,
                totalPrice,
                totalCount,
                freight,
                actualPayment
            });
        },

        // 获取默认地址
        getDefaultAddress: function () {
            addressApi
                .getDefaultAddress()
                .then((address) => {
                    if (address) {
                        this.setData({
                            selectedAddress: address,
                            hasAddress: true
                        });
                    } else {
                        // 没有默认地址，获取地址列表的第一个
                        addressApi.getAddressList().then((list) => {
                            if (list && list.length > 0) {
                                this.setData({
                                    selectedAddress: list[0],
                                    hasAddress: true
                                });
                            } else {
                                this.setData({
                                    hasAddress: false
                                });
                            }
                        });
                    }
                })
                .catch((err) => {
                    console.error('获取地址失败', err);
                });
        },

        // 选择收货地址
        selectAddress: function () {
            uni.navigateTo({
                url: '/pages/address/list'
            });
        },

        // 添加收货地址
        addAddress: function () {
            uni.navigateTo({
                url: '/pages/address/edit'
            });
        },

        // 输入备注
        inputRemark: function (e) {
            this.setData({
                remark: e.detail.value
            });
        },

        // 提交订单
        submitOrder: function () {
            const { selectedAddress, orderItems, remark } = this;

            // 校验收货地址
            if (!selectedAddress) {
                uni.showToast({
                    title: '请选择收货地址',
                    icon: 'none'
                });
                return;
            }

            // 显示加载状态
            this.setData({
                isLoading: true
            });

            // 构建订单数据
            const orderData = {
                receiverName: selectedAddress.name,
                receiverPhone: selectedAddress.phone,
                province: selectedAddress.province,
                city: selectedAddress.city,
                district: selectedAddress.district,
                address: selectedAddress.address,
                remark: remark,
                items: orderItems.map((item) => ({
                    productId: item.productId,
                    productName: item.name,
                    productImage: item.image,
                    price: item.price,
                    count: item.count
                }))
            };

            // 创建订单
            orderApi
                .createOrder(orderData)
                .then((order) => {
                    // 清除结算商品缓存
                    uni.removeStorageSync('checkoutItems');

                    // 隐藏加载状态
                    this.setData({
                        isLoading: false
                    });
                    uni.showToast({
                        title: '下单成功',
                        icon: 'success'
                    });

                    // 跳转到订单列表
                    setTimeout(() => {
                        uni.redirectTo({
                            url: '/pages/order/list'
                        });
                    }, 1500);
                })
                .catch((err) => {
                    console.error('创建订单失败', err);
                    this.setData({
                        isLoading: false
                    });
                });
        }
    }
};
</script>
<style>
/* pages/order/order.wxss */
.order-container {
    min-height: 100vh;
    background-color: #f7f7f7;
    padding-bottom: 120rpx;
}

/* 通用样式 */
.section-title {
    font-size: 28rpx;
    font-weight: bold;
    color: #333;
    padding: 20rpx 0;
}

.arrow {
    color: #999;
    font-size: 28rpx;
}

.divider {
    height: 1px;
    background-color: #f5f5f5;
    margin: 20rpx 0;
}

/* 收货地址 */
.address-section {
    background-color: #fff;
    margin-bottom: 20rpx;
    padding: 30rpx;
}

.address-empty {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.add-address {
    display: flex;
    align-items: center;
}

.add-icon {
    width: 40rpx;
    height: 40rpx;
    margin-right: 20rpx;
}

.address-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.address-detail {
    flex: 1;
}

.name-phone {
    margin-bottom: 16rpx;
}

.name {
    font-size: 30rpx;
    font-weight: bold;
    margin-right: 20rpx;
}

.phone {
    font-size: 28rpx;
    color: #666;
}

.address {
    display: flex;
    align-items: flex-start;
}

.default-tag {
    font-size: 22rpx;
    color: #fff;
    background-color: var(--primary-color);
    padding: 4rpx 12rpx;
    border-radius: 4rpx;
    margin-right: 10rpx;
    margin-top: 4rpx;
}

.address-text {
    font-size: 28rpx;
    color: #333;
    line-height: 1.4;
    flex: 1;
}

/* 商品清单 */
.goods-section {
    background-color: #fff;
    margin-bottom: 20rpx;
    padding: 0 30rpx;
}

.goods-list {
    padding-bottom: 20rpx;
}

.goods-item {
    display: flex;
    padding: 20rpx 0;
    border-bottom: 1px solid #f5f5f5;
}

.goods-item:last-child {
    border-bottom: none;
}

.goods-image {
    width: 160rpx;
    height: 160rpx;
    border-radius: 8rpx;
    margin-right: 20rpx;
}

.goods-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.goods-name {
    font-size: 28rpx;
    line-height: 1.4;
    margin-bottom: 10rpx;
}

.goods-price-box {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.price {
    color: var(--price-color);
    font-weight: bold;
    font-size: 32rpx;
}

.count {
    font-size: 28rpx;
    color: #666;
}

/* 订单备注 */
.remark-section {
    background-color: #fff;
    margin-bottom: 20rpx;
    padding: 0 30rpx;
}

.remark-input {
    width: 100%;
    height: 160rpx;
    font-size: 28rpx;
    padding: 20rpx 0;
}

/* 订单金额 */
.amount-section {
    background-color: #fff;
    padding: 0 30rpx 30rpx;
}

.amount-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16rpx 0;
}

.amount-label {
    font-size: 28rpx;
    color: #666;
}

.amount-value {
    font-size: 28rpx;
    color: #333;
}

.amount-item.total {
    font-weight: bold;
}

/* 底部提交栏 */
.footer {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: 100rpx;
    background-color: #fff;
    display: flex;
    align-items: center;
    padding: 0 30rpx;
    box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.05);
    z-index: 99;
}

.total-info {
    flex: 1;
}

.total-label {
    font-size: 28rpx;
    color: #333;
}

.total-price {
    font-size: 36rpx;
    color: var(--price-color);
    font-weight: bold;
}

.submit-btn {
    width: 240rpx;
    height: 80rpx;
    background-color: var(--primary-color);
    color: #fff;
    font-size: 30rpx;
    border-radius: 40rpx;
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 0;
}

.submit-btn.loading {
    opacity: 0.8;
}
</style>
