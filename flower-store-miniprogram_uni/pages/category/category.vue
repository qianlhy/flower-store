<template>
    <view>
        <!-- pages/category/category.wxml -->
        <view class="category-container">
            <!-- 左侧分类列表 -->
            <view class="category-sidebar">
                <scroll-view :scroll-y="true" class="sidebar-scroll">
                    <view
                        :class="'category-item ' + (currentCategory.id === item.id ? 'active' : '')"
                        @tap="switchCategory"
                        :data-id="item.id"
                        v-for="(item, index) in categories"
                        :key="index"
                    >
                        <view class="category-item-inner">{{ item.name }}</view>
                    </view>
                </scroll-view>
            </view>

            <!-- 右侧商品列表 -->
            <view class="category-content">
                <view class="category-title" v-if="currentCategory">
                    <text>{{ currentCategory.name }}</text>
                </view>

                <scroll-view :scroll-y="true" class="product-scroll">
                    <view class="no-data" v-if="products.length === 0">
                        <image src="/static/images/icons/empty.png" mode="aspectFit"></image>
                        <text>暂无商品</text>
                    </view>

                    <view class="product-list">
                        <view class="product-item" @tap="onTapProduct" :data-id="item.id" v-for="(item, index) in products" :key="index">
                            <image class="product-image" :src="item.image" mode="aspectFill"></image>

                            <view class="product-info">
                                <text class="product-name text-ellipsis">{{ item.name }}</text>
                                <text class="product-desc text-ellipsis">{{ item.description }}</text>
                                <view class="product-price-box">
                                    <text class="price">¥{{ item.price }}</text>
                                    <text class="price-original">¥{{ item.originalPrice }}</text>
                                </view>
                                <view class="product-sales">已售{{ item.sales }}件</view>
                            </view>

                            <view class="add-cart-btn" @tap.stop.prevent="onAddToCart" :data-id="item.id">+</view>
                        </view>
                    </view>
                </scroll-view>
            </view>
        </view>

        <!-- 加载状态 -->
        <view class="loading-container" v-if="isLoading">
            <view class="loading">
                <image src="/static/images/icons/loading.png" mode="aspectFit" class="loading-icon"></image>
                <text>加载中...</text>
            </view>
        </view>
    </view>
</template>

<script>
// pages/category/category.js
const app = getApp();
const eventBus = require('../../utils/eventBus');
const categoryApi = require('../../api/category');
const productApi = require('../../api/product');
export default {
    data() {
        return {
            categories: [],
            products: [],
            currentCategory: null,
            isLoading: true
        };
    }
    /**
     * 生命周期函数--监听页面加载
     */,
    onLoad(options) {
        // 获取分类数据
        this.getCategories();

        // 监听分类切换事件
        eventBus.on('switchCategory', this.handleSwitchCategory);
    },
    /**
     * 生命周期函数--监听页面初次渲染完成
     */
    onReady() {},
    /**
     * 生命周期函数--监听页面显示
     */
    onShow() {
        // 如果从首页传来了分类ID，则切换到该分类
        if (app.globalData.tempCategoryId) {
            // 根据ID找到对应的分类
            const categoryId = app.globalData.tempCategoryId;
            const category = this.categories.find((item) => item.id === categoryId);
            if (category) {
                this.setData({
                    currentCategory: category
                });
                this.getCategoryProducts(categoryId);
            }

            // 使用后清空，避免重复切换
            app.globalData.tempCategoryId = null;
        }
        // 如果已经有当前分类，则刷新商品列表
        else if (this.currentCategory) {
            this.getCategoryProducts(this.currentCategory.id);
        }
    },
    /**
     * 生命周期函数--监听页面隐藏
     */
    onHide() {},
    /**
     * 生命周期函数--监听页面卸载
     */
    onUnload() {
        // 页面卸载时移除事件监听
        eventBus.off('switchCategory', this.handleSwitchCategory);
    },
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
        // 获取分类数据
        getCategories: function () {
            this.setData({
                isLoading: true
            });
            categoryApi
                .getCategoryList()
                .then((categories) => {
                    if (categories && categories.length > 0) {
                        this.setData({
                            categories,
                            currentCategory: categories[0],
                            isLoading: false
                        });

                        // 获取第一个分类的商品
                        this.getCategoryProducts(categories[0].id);
                    } else {
                        this.setData({
                            isLoading: false
                        });
                    }
                })
                .catch((err) => {
                    console.error('获取分类失败', err);
                    this.setData({
                        isLoading: false
                    });
                });
        },

        // 获取分类商品
        getCategoryProducts: function (categoryId) {
            productApi
                .getProductsByCategory(categoryId)
                .then((data) => {
                    // 处理每个商品的images字段
                    const products = data.map((product) => {
                        if (product.images && typeof product.images === 'string') {
                            product.images = product.images.split(',').filter((img) => img.trim());
                        }
                        if (!Array.isArray(product.images) || product.images.length === 0) {
                            product.images = [product.image];
                        }
                        return product;
                    });
                    this.setData({
                        products
                    });
                })
                .catch((err) => {
                    console.error('获取商品失败', err);
                });
        },

        // 切换分类
        switchCategory: function (e) {
            const categoryId = e.currentTarget.dataset.id;
            const category = this.categories.find((item) => item.id === categoryId);
            if (category) {
                this.setData({
                    currentCategory: category
                });
                this.getCategoryProducts(categoryId);
            }
        },

        // 点击商品
        onTapProduct: function (e) {
            const { id } = e.currentTarget.dataset;
            uni.navigateTo({
                url: `/pages/product/detail?id=${id}`
            });
        },

        // 添加到购物车
        onAddToCart: function (e) {
            // 阻止冒泡，防止触发商品点击事件
            e.stopPropagation();
            const { id } = e.currentTarget.dataset;
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
            const cartApi = require('../../api/cart');
            cartApi
                .addToCart(id, 1)
                .then(() => {
                    uni.showToast({
                        title: '已加入购物车',
                        icon: 'success'
                    });
                })
                .catch((err) => {
                    console.error('添加购物车失败', err);
                });
        },

        // 处理分类切换事件
        handleSwitchCategory: function (data) {
            if (data && data.categoryId) {
                const categoryId = data.categoryId;
                const category = this.categories.find((item) => item.id === categoryId);
                if (category) {
                    this.setData({
                        currentCategory: category
                    });
                    this.getCategoryProducts(categoryId);
                }
            }
        }
    }
};
</script>
<style>
/* pages/category/category.wxss */
.category-container {
    display: flex;
    height: 100vh;
    overflow: hidden;
    background-color: #f7f7f7;
}

/* 左侧分类样式 */
.category-sidebar {
    width: 180rpx;
    min-width: 180rpx;
    flex-shrink: 0;
    height: 100%;
    background-color: #f7f7f7;
    border-right: 1rpx solid #eee;
}

.sidebar-scroll {
    height: 100%;
}

.category-item {
    padding: 30rpx 10rpx;
    text-align: center;
    font-size: 28rpx;
    color: #666;
    position: relative;
}

.category-item-inner {
    display: inline-block;
    padding: 0 10rpx;
    line-height: 1.4;
}

.category-item.active {
    background-color: #fff;
    color: var(--primary-color);
    font-weight: bold;
}

.category-item.active::before {
    content: '';
    position: absolute;
    left: 0;
    top: 30rpx;
    bottom: 30rpx;
    width: 6rpx;
    background-color: var(--primary-color);
    border-radius: 3rpx;
}

/* 右侧商品列表样式 */
.category-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    background-color: #fff;
}

.category-title {
    padding: 20rpx 30rpx;
    font-size: 32rpx;
    font-weight: bold;
    border-bottom: 1rpx solid #f5f5f5;
}

.product-scroll {
    flex: 1;
    height: 0;
}

.product-list {
    padding: 0 20rpx;
}

.product-item {
    display: flex;
    padding: 20rpx 0;
    position: relative;
    border-bottom: 1rpx solid #f5f5f5;
}

.product-image {
    width: 180rpx;
    height: 180rpx;
    border-radius: 12rpx;
    margin-right: 20rpx;
}

.product-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.product-name {
    font-size: 28rpx;
    font-weight: bold;
    line-height: 1.4;
    margin-bottom: 10rpx;
}

.product-desc {
    font-size: 24rpx;
    color: #999;
    line-height: 1.4;
    margin-bottom: 10rpx;
}

.product-price-box {
    display: flex;
    align-items: baseline;
    margin-bottom: 10rpx;
}

.price {
    color: var(--price-color);
    font-weight: bold;
    font-size: 32rpx;
}

.price-original {
    color: #999;
    text-decoration: line-through;
    font-size: 24rpx;
    margin-left: 10rpx;
}

.product-sales {
    font-size: 22rpx;
    color: #999;
}

.add-cart-btn {
    position: absolute;
    right: 0;
    bottom: 20rpx;
    width: 60rpx;
    height: 60rpx;
    border-radius: 50%;
    background-color: var(--primary-color);
    color: #fff;
    font-size: 40rpx;
    display: flex;
    align-items: center;
    justify-content: center;
}

/* 空数据状态 */
.no-data {
    padding-top: 100rpx;
    display: flex;
    flex-direction: column;
    align-items: center;
    color: #999;
    font-size: 28rpx;
}

.no-data image {
    width: 200rpx;
    height: 200rpx;
    margin-bottom: 20rpx;
}

/* 加载状态 */
.loading-container {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: rgba(255, 255, 255, 0.8);
    z-index: 999;
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

.loading text {
    font-size: 28rpx;
    color: #666;
}
</style>
