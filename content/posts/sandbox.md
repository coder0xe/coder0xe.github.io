+++
title = 'Sandbox'
date = 2026-10-27T16:24:13+08:00
description = ""
draft = true
tags = []
categories = []
keywords = []
+++

## DeepSeek Elastic Compute (DSec): A Sandbox Infrastructure for Effective Agentic Training at Scale

> 主要场景是RL，做的工作和e2b一样：节点级调度+节点内sandbox管理（lifecycle、session）

### Sandbox Backends

![backends](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261027171715606.png)

* 更强的隔离性，更大的开销
* container：software engineering / repo-level，但是共享kernel，不够安全
* microVM用的firecracker

### Deployment Scale

* one scale unit：160 CPU nodes：30k cores、250TB DRAM，配比约等于1:8
  * 测试环境：per micro VM node：AMD EPYC 9655，2 sockets x 96 cores x 2 SMT, 1.5TB DRAM，也是差不多1:8，container环境差不多1:5.3，VM确实是消耗更多内存
* 一天内服务3M个沙箱，最高并发达到380K，每秒创建超过5000个沙箱（这个感觉是RL训练场景，阿里的serving场景创建只有300+），超卖比10:1

### Lifecycle Management

* 由于GPU任务被强占的任务，RL framework会显式暂停sandbox，保存内存和执行状态为快照，再结束firecracker进程，**收回运行态的内存**
* sandbox收到请求后恢复

### RL benchmark

* SWE-bench、Terminal-bench

## WeEnv: The Environment for Agentic Reinforcement Learning at WeChat

> 主要场景是RL，和DSec一致的分层环境设计，用到哪层就读取哪层，on-demand fetching，其他的点还有弹性资源配置（CPU+Mem），初始资源配置：2c8g

### Setups

* 384CPU，2TB DRAM

### RL benchmark

* SWE-Smith-Python

## KIMI K3: OPEN FRONTIER INTELLIGENCE

> 也是RL场景，新的microVM：AgentENV

### Lifecycle Management

* pause：释放内存和CPU









