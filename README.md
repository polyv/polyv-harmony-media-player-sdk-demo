polyv-harmony-media-player-sdk-demo
===

[![build passing](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![GitHub release](https://img.shields.io/badge/release-2.1.0-blue.svg)](https://github.com/polyv/polyv-harmony-media-player-sdk-demo/releases/tag/2.1.0)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [1 简介](#1-%E7%AE%80%E4%BB%8B)
- [2 下载安装](#2-%E4%B8%8B%E8%BD%BD%E5%AE%89%E8%A3%85)
- [3 文档](#3-%E6%96%87%E6%A1%A3)
  - [3.1 集成文档](#31-%E9%9B%86%E6%88%90%E6%96%87%E6%A1%A3)
  - [3.2 接口文档](#32-%E6%8E%A5%E5%8F%A3%E6%96%87%E6%A1%A3)
  - [3.3 版本更新记录](#33-%E7%89%88%E6%9C%AC%E6%9B%B4%E6%96%B0%E8%AE%B0%E5%BD%95)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### 1 简介
此项目是保利威鸿蒙播放器 SDK Demo。

此项目只支持基础的播放功能和高级交互功能（具体见[播放器支持的功能特性](https://github.com/polyv/polyv-harmony-media-player-sdk-demo/blob/master/docs/public/支持的功能特性.md)）

播放器项目的文件目录结构如下：

```
|-- demo
|   |-- ability
|   |-- mock (demo模拟数据)
|   |-- pages
|   |   |-- PLVMediaPlayerEntrancePage (入口页)
|   |   `-- PLVMediaPlayerFeedVideoPage (短视频场景页面)
|   |   `-- PLVMediaPlayerSingleVideoPage (长视频场景页面)
|   `-- startup (SDK初始化)
|-- scene_feed_video (短视频场景模块)
|-- scene_single_video (长视频场景模块)
`-- common
    |-- modules (业务逻辑)
    |-- ui (各场景通用的ui组件)
    `-- utils (工具类库)
```

### 2 下载安装

```shell
ohpm install @polyvharmony/media-player-sdk
```

### 3 文档
#### 3.1 集成文档
[集成文档](https://github.com/polyv/polyv-harmony-media-player-sdk-demo/tree/master/docs/public)
#### 3.2 接口文档
[v2.1.0 接口文档](https://repo.polyv.net/harmony/documents/media_player_sdk/2.1.0/index.html)
#### 3.3 版本更新记录
[全版本更新记录](https://github.com/polyv/polyv-harmony-media-player-sdk-demo/blob/master/CHANGELOG.md)
