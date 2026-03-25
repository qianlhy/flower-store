<template>
    <view>
        <!-- index.wxml -->
        <view class="index-container">
            <!-- 搜索栏 -->
            <view class="search-bar">
                <view class="search-input-box" @tap="onTapSearch">
                    <icon type="search" size="16" color="#999"></icon>
                    <text class="search-placeholder">搜索玫瑰、百合、康乃馨等</text>
                </view>
            </view>

            <!-- 背景音乐控制 -->
            <view class="music-control" @tap="toggleBackgroundAudio">
                <image :class="'music-icon ' + (backgroundAudioPlaying ? 'playing' : '')" src="/static/images/icons/music.png" />
            </view>

            <!-- 轮播图 -->
            <swiper class="banner" :indicator-dots="true" :autoplay="true" interval="3000" duration="500" :circular="true">
                <swiper-item v-for="(item, index) in banners" :key="index">
                    <image :src="item.image" mode="aspectFill" class="banner-image" @tap="onTapBanner" :data-id="item.id"></image>
                </swiper-item>
            </swiper>

            <!-- 分类导航 -->
            <view class="category-nav">
                <scroll-view :scroll-x="true" class="category-scroll">
                    <view class="category-item" @tap="onTapCategory" :data-id="item.id" v-for="(item, index) in categories" :key="index">
                        <image class="category-icon" :src="item.icon || '/images/category/default.png'"></image>

                        <text class="category-name">{{ item.name }}</text>
                    </view>
                </scroll-view>
            </view>

            <!-- 活动专区 -->
            <view class="section">
                <view class="section-header">
                    <text class="section-title">限时特惠</text>
                    <text class="section-more" @tap="onTapMore" data-type="promotion">查看更多 ></text>
                </view>
                <view class="promotion-box">
                    <view class="promotion-item" @tap="onTapProduct" :data-id="item.id" v-for="(item, index) in promotions" :key="index">
                        <image class="promotion-image" :src="item.image" mode="aspectFill"></image>

                        <view class="promotion-info">
                            <text class="promotion-name text-ellipsis">{{ item.name }}</text>
                            <view class="promotion-price-box">
                                <text class="price">¥{{ item.price }}</text>
                                <text class="price-original">¥{{ item.originalPrice }}</text>
                            </view>
                        </view>
                    </view>
                </view>
            </view>

            <!-- 推荐商品 -->
            <view class="section">
                <view class="section-header">
                    <text class="section-title">热门推荐</text>
                    <text class="section-more" @tap="onTapMore" data-type="recommended">查看更多 ></text>
                </view>
                <view class="product-list">
                    <view class="product-item" @tap="onTapProduct" :data-id="item.id" v-for="(item, index) in recommendProducts" :key="index">
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
            </view>

            <!-- 新品上市 -->
            <view class="section">
                <view class="section-header">
                    <text class="section-title">新品上市</text>
                    <text class="section-more" @tap="onTapMore" data-type="new">查看更多 ></text>
                </view>
                <view class="grid grid-2">
                    <view class="grid-item new-product" @tap="onTapProduct" :data-id="item.id" v-for="(item, index) in newProducts" :key="index">
                        <image class="new-product-image" :src="item.image" mode="aspectFill"></image>

                        <view class="new-product-info">
                            <text class="new-product-name text-ellipsis">{{ item.name }}</text>
                            <view class="new-product-price-box">
                                <text class="price">¥{{ item.price }}</text>
                            </view>
                            <view class="tag tag-primary">新品</view>
                        </view>
                    </view>
                </view>
            </view>
        </view>

        <!-- 添加购物车成功提示 -->
        <view class="toast-container" v-if="showToast">
            <view class="toast-content">
                <icon type="success" size="24"></icon>
                <text>已加入购物车</text>
            </view>
        </view>
    </view>
</template>

<script>
import navigationBar from '@/components/navigation-bar/navigation-bar';
// index.js
const app = getApp();
const eventBus = require('../../utils/eventBus');
const categoryApi = require('../../api/category');
const productApi = require('../../api/product');
export default {
    components: {
        navigationBar
    },
    data() {
        return {
            banners: [
                { id: 1, image: 'https://qcloud.dpfile.com/pc/kE0C4i12U3D5UEvxApqaFxglGtBYY_1PUdNCOJDPHoWSOsdagRDO-IEWlGb8IfF2.jpg' },
                { id: 2, image: 'https://qcloud.dpfile.com/pc/9SywjBIGLpuFhj8crhhZuGqFV8xGzjM8gFDrLQOZ7Aj78ALYHNsplNTvZhwiAL68.jpg' },
                { id: 3, image: 'https://qcloud.dpfile.com/pc/nOw9sjQd2IOxQVgxVixxDUQTKXgqU0bi8W6Iqyk-KS8NJ2kCJs82lH4x-pgUg78Y.jpg' }
            ],
            categories: [],
            promotions: [],
            recommendProducts: [],
            newProducts: [],
            showToast: false,
            backgroundAudioPlaying: false
        };
    },
    onLoad: function () {
        // 获取商品分类
        this.getCategories();

        // 获取特惠商品
        this.getPromotions();

        // 获取推荐商品
        this.getRecommendProducts();

        // 获取新品上市
        this.getNewProducts();
        this.backgroundAudioManager = uni.getBackgroundAudioManager();
        this.setupBackgroundAudio();
    },
    onShow: function () {
        // 页面显示时可以刷新数据
    },
    methods: {
        setupBackgroundAudio: function () {
            this.backgroundAudioManager.title = '轻音乐';
            this.backgroundAudioManager.epname = '鲜花店背景音乐';
            this.backgroundAudioManager.singer = '未知';
            this.backgroundAudioManager.coverImgUrl = '/images/music.png';
            // 设置背景音乐，需要使用网络地址
            this.backgroundAudioManager.src = 'https://miniprogram.lovenice.cn/1.mp3';
            this.backgroundAudioManager.onPlay(() => {
                this.setData({
                    backgroundAudioPlaying: true
                });
            });
            this.backgroundAudioManager.onPause(() => {
                this.setData({
                    backgroundAudioPlaying: false
                });
            });
        },

        toggleBackgroundAudio: function () {
            if (this.backgroundAudioPlaying) {
                this.backgroundAudioManager.pause();
            } else {
                this.backgroundAudioManager.play();
            }
        },

        // 获取分类数据
        getCategories: function () {
            categoryApi
                .getCategoryList()
                .then((data) => {
                    this.setData({
                        categories: data
                    });
                })
                .catch((err) => {
                    console.error('获取分类失败', err);
                });
        },

        // 获取特惠商品数据（价格最低的6个商品）
        getPromotions: function () {
            productApi
                .getProductList()
                .then((data) => {
                    const promotions = data
                        .map((product) => {
                            // 处理images字段
                            if (product.images && typeof product.images === 'string') {
                                product.images = product.images.split(',').filter((img) => img.trim());
                            }
                            if (!Array.isArray(product.images) || product.images.length === 0) {
                                product.images = [product.image];
                            }
                            return product;
                        })
                        .slice()
                        .sort((a, b) => a.price - b.price)
                        .slice(0, 6);
                    this.setData({
                        promotions
                    });
                })
                .catch((err) => {
                    console.error('获取特惠商品失败', err);
                });
        },

        // 获取推荐商品数据（销量最高的6个商品）
        getRecommendProducts: function () {
            productApi
                .getHotProducts(6)
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
                        recommendProducts: products
                    });
                })
                .catch((err) => {
                    console.error('获取推荐商品失败', err);
                });
        },

        // 获取新品上市数据
        getNewProducts: function () {
            productApi
                .getNewProducts(4)
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
                        newProducts: products
                    });
                })
                .catch((err) => {
                    console.error('获取新品失败', err);
                });
        },

        // 点击搜索框
        onTapSearch: function () {
            uni.navigateTo({
                url: '/pages/search/search'
            });
        },

        // 点击轮播图
        onTapBanner: function (e) {
            const { id } = e.currentTarget.dataset;
            // 可以根据轮播图ID跳转到不同页面，这里简单处理为跳转到分类页
            uni.switchTab({
                url: '/pages/category/category'
            });
        },

        // 点击分类项
        onTapCategory: function (e) {
            const { id } = e.currentTarget.dataset;

            // 先在全局变量中保存要切换的分类ID
            app.globalData.tempCategoryId = id;
            uni.switchTab({
                url: '/pages/category/category',
                success: function () {
                    // 延迟发送事件，确保页面已经加载
                    setTimeout(() => {
                        eventBus.emit('switchCategory', {
                            categoryId: id
                        });
                    }, 100);
                }
            });
        },

        // 点击商品
        onTapProduct: function (e) {
            const { id } = e.currentTarget.dataset;
            uni.navigateTo({
                url: `/pages/product/detail?id=${id}`
            });
        },

        // 点击查看更多
        onTapMore: function (e) {
            const { type } = e.currentTarget.dataset;
            uni.switchTab({
                url: '/pages/category/category'
            });
        },

        // 添加到购物车
        onAddToCart: function (e) {
            const { id } = e.currentTarget.dataset;

            // 检查登录状态
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
                    // 显示添加成功提示
                    this.setData({
                        showToast: true
                    });
                    setTimeout(() => {
                        this.setData({
                            showToast: false
                        });
                    }, 1500);
                })
                .catch((err) => {
                    console.error('添加购物车失败', err);
                });
        }
    }
};
</script>
<style>
/**index.wxss**/
.index-container {
    padding-bottom: 30rpx;
}

/* 搜索栏样式 */
.search-bar {
    padding: 20rpx 30rpx;
    background-color: #fff;
    position: sticky;
    top: 0;
    z-index: 100;
}

.search-input-box {
    background-color: #f5f5f5;
    border-radius: 36rpx;
    height: 72rpx;
    display: flex;
    align-items: center;
    padding: 0 30rpx;
}

/* 音乐控制 */
.music-control {
    position: fixed;
    top: 360rpx;
    right: 20rpx;
    z-index: 999;
    width: 60rpx;
    height: 60rpx;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.music-icon {
    width: 40rpx;
    height: 40rpx;
}

.music-icon.playing {
    animation: rotate 3s linear infinite;
}

@keyframes rotate {
    from {
        transform: rotate(0deg);
    }
    to {
        transform: rotate(360deg);
    }
}

.search-placeholder {
    color: #999;
    font-size: 28rpx;
    margin-left: 10rpx;
}

/* 轮播图样式 */
.banner {
    width: 100%;
    height: 350rpx;
}

.banner-image {
    width: 100%;
    height: 100%;
}

/* 分类导航样式 */
.category-nav {
    background-color: #fff;
    padding: 20rpx 0;
    margin-bottom: 20rpx;
}

.category-scroll {
    white-space: nowrap;
    padding: 0 20rpx;
}

.category-item {
    display: inline-block;
    width: 140rpx;
    text-align: center;
    margin-right: 20rpx;
}

.category-icon {
    width: 90rpx;
    height: 90rpx;
    border-radius: 50%;
    background-color: #f5f5f5;
}

.category-name {
    font-size: 24rpx;
    color: #333;
    display: block;
    margin-top: 10rpx;
}

/* 区块公共样式 */
.section {
    background-color: #fff;
    margin-bottom: 20rpx;
    padding: 30rpx;
    border-radius: 16rpx;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20rpx;
}

.section-title {
    font-size: 32rpx;
    font-weight: bold;
    color: #333;
    position: relative;
    padding-left: 20rpx;
}

.section-title::before {
    content: '';
    position: absolute;
    left: 0;
    top: 6rpx;
    width: 8rpx;
    height: 32rpx;
    background-color: var(--primary-color);
    border-radius: 4rpx;
}

.section-more {
    font-size: 24rpx;
    color: #999;
}

/* 特惠专区样式 */
.promotion-box {
    display: flex;
    overflow-x: auto;
    margin: 0 -10rpx;
    padding: 10rpx 0;
}

.promotion-box::-webkit-scrollbar {
    display: none;
}

.promotion-item {
    flex-shrink: 0;
    width: 240rpx;
    margin: 0 10rpx;
    border-radius: 12rpx;
    overflow: hidden;
    background-color: #fff;
    box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.06);
}

.promotion-image {
    width: 240rpx;
    height: 240rpx;
}

.promotion-info {
    padding: 16rpx;
}

.promotion-name {
    font-size: 26rpx;
    line-height: 1.4;
    margin-bottom: 10rpx;
    display: block;
}

.promotion-price-box {
    display: flex;
    align-items: baseline;
}

/* 商品列表样式 */
.product-list {
    margin-top: 20rpx;
}

.product-item {
    display: flex;
    padding: 20rpx 0;
    position: relative;
    border-bottom: 1rpx solid #f5f5f5;
}

.product-item:last-child {
    border-bottom: none;
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

/* 新品上市样式 */
.new-product {
    padding: 10rpx;
}

.new-product-image {
    width: 100%;
    height: 320rpx;
    border-radius: 12rpx;
}

.new-product-info {
    padding: 16rpx 10rpx;
}

.new-product-name {
    font-size: 28rpx;
    line-height: 1.4;
    margin-bottom: 10rpx;
    display: block;
}

.new-product-price-box {
    margin-bottom: 10rpx;
}

/* 弹窗提示 */
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
</style>
