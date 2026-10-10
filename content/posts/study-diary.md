+++
title = '知识杂记'
date = 2026-08-13T12:36:53+08:00
description = "记一下每天学到的零碎的知识"
draft = false
tags = ["cs"]
categories = ["笔记"]
keywords = ["计算机体系结构"]
+++

## PMU

* PMU即为Performance Monitering Unit，是CPU内部专门统计**硬件**运行事件的模块
* 他通过一组硬件性能计数器记录
  * CPU周期数/执行的指令数
  * 缓存命中/未命中
  * 分支预测错误
  * 内存访问与停顿
  * 流水线相关事件
* 这些指标可以用来进行性能计算，linux的perf也采用了PMU

## MPKI

* MPKI即为Misses Per Kilo Instructions
* 常用于衡量缓存或分支预测表现
* L1 MPKI / LLC MPKI / Branch MPKI

## IPC

* IPC: Instructions Per Cycle

## SWE-bench

* github repo issue为任务背景，理解仓库，提交patch
* 全量2000+任务
* verfied版本中有500个任务

## N-Gram

* N元组

* Bigram二元组，Trigram三元组

* 数学上表示为 ：
  $$
  (a_1, a_2, ... a_n)
  $$

## micro/macro

* micro表示微观
* macro表示宏观

## online / offline profiling

* online / offline profiling的区别在于分析metrics的时机：
  * online profiling在程序运行时分析，要求控制profiling overhead，可以参与运行时决策
  * offline profiling在程序运行后分析，可以进行复杂分析，不参与运行时决策

## 读论文方法

> title => abs => intro => method => exp => conclusion
1.Pass1: title + abs + conclusion，先知道在干什么，要不要读
2.Pass2: 从标题读到最后，图/表都懂，了解主要工作
3.Pass3: 知道每一句话在干什么，每一段在干什么

## SLO

* 服务水平目标：Service Level Objective
* SLO = (作用对象，指标，阈值，达标比例)
* 例如：对于所有的LLM请求，满足TTFT<2s，TPOT<150ms的比例不低于90%
* P99尾延迟不超过无负载系统中单独执行时延的5倍

## RSS

* RSS即为Resident Set Size，表示进程在内存中驻留页面的大小
