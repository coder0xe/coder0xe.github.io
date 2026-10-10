+++
title = 'ISCA26'
date = 2026-09-28T11:59:23+08:00
description = "ISCA26文章阅读"
draft = false
tags = ["ISCA"]
categories = ["论文笔记"]
keywords = ["ISCA26"]

+++

## PhaseWeave: Phase-Aware Execution on Heterogeneous Chiplet Architectures for Datacenters

### Problem

* 数据中心应用执行具有基于ms-scale phase的资源需求异构性，传统的统一架构的服务器不能适配，导致under-utilized/under-provisioned。

### Insight

* 不同毫秒级(tens ~ hundreds)执行阶段有重复性、对不同硬件资源（core frequency、memory bandwidth）具有敏感性

* 周期波动IPC模式 => 不同资源需求的执行阶段快速转换（计算密集 IPC高，memory/network IPC低）

* workload phase资源需求异构性来源：

  1. diverse microservice 

     ![micro](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20260928182623225.png)

  2. Datacenter tax （同操作差别大，不能通过语义判断微架构表现）

     ![tax](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20260928185314108.png)

  3. internal operations of microservice

     ![image-20260928191144573](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20260928191144573.png)

* operation对硬件资源敏感性

  * core frequency ：提高频率所有操作吞吐量都上升（显然）

  * memory bandwidth：deepcopy对内存带宽敏感

    ![image-20260928213736290](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20260928213736290.png)

  * L2 cache capacity：ptrchase对L2 cache capacity最为敏感

    ![image-20260928220825492](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20260928220825492.png)

  * intel Processor generation

    ![image-20260928221959382](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20260928221959382.png)

    * 计算密集型：ranking/gemm
    * memory-bound：ptrchase/deepcopy，可能是更深cache层级带来的latency

### Design

* phase characterization metrics：
  * compute：IPC/executed instruction types/branch miss frequency
  * memory：L1/LLC MPKI
  * network：I/O bandwidth，network syscall frequency

* PhaseWeave system：四种异构chiplet：high-compute，fast-memory，near-network，low-power适配异构phase

  ![server](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261001185840761.png)

* Architecture：对每种chiplet做workload适配

  * high-compute：更多算数/向量操作
    * 增强：higher core frequency 、更大前端发射宽度、更大ROB和LSQ、wide SIMD/vector units
    * 减弱：更小LLC /off-chip memory bandwidth、无网络模块
  * fast-memory：
    * 增强：更多HBM、DRAM interfaces
    * 减弱：core frequency ，无网络模块
  * near-network：
    * 增强：多网卡（NIC）
    * 减弱：更小cache和vector units、适中mem bandwidth
  * Low-power: latency insensitive phases
    * 减弱：core frequency , cache capacity , slower DRAM, omit NICs

* Memory Subsystem

  * chiplets统一物理地址空间
  * 实际DRAM分离，每个chiplet有定制的DRAM
  * NUMA-like page migration

* hardware Phase Predictor：offline trained, online inference，为下一phase预测best-suited chiplet
  * 在一个chiplet上至少运行一个epoch：100us，记录硬件信息、判断下一阶段、是否迁移

  * 信息：

    * hardware：IPC, cache, TLB, branch MPKI
    * Software：各种类syscall频率

  * 预测方法

    ![predict](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261001211521801.png)

    * threshold：制定规则，高IPC-低network：compute
    * clustering：针对特征聚4类
    * ML：
      * offline training：数据：benchmark phase => 实测得到最佳chiplet

  * microarchitecture

    ![predictor](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261001214227799.png)

* thread migration

  ![algorithm](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261002130836793.png)

### Evaluation

* chiplet配置

  ![config](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261002135247833.png)

* tail latency：phaseweave per core area更小，相同area核心数更多，减小排队latency

  ![latency](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261002142234944.png)

* median latency：每个phase执行更高效

  ![latency2](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261002144046322.png)

* throughput

  ![throughput](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261002145847759.png)

* Comparison to big.LITTLE architectures

  ![biglittle](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261002165324325.png)

  * bigL：ARM-style big.LITTLE config：乱序高性能核、顺序低能耗核
  * bigL-OoO：顺序低能效核转成乱序，其他微架构结构不变
  * bigL-Opt：用phaseweave的compute和low-power核

### Appendix

* microservice：把一个大型应用拆分成许多微服务分别部署
*  datacenter tax：serializaion, encryption, compression ，链接各个微服务
* `cpu-freq-utils`调整CPU频率，`intel CAT`调整内存带宽和cache容量，`intel pqos`调整memory bandwidth/L2 cache capacity（**注：pqos只能调整L2/LLC cache，不能调整L1 cache**）
* LSQ：load/store queue
* SIMD：单指令多数据流
* on/off-chip memory (bandwidth)：
  * On-chip：L1/L2/LLC cache，SRAM
  * off-chip：memory，DRAM

* big.LITTLE architecture：高性能计算核心+节能核心



## Power Sloshing in Compound Servers for Large-Scale AI Inference Workloads

### Problem

* 面向AI-driven application，数据中心部署CPU+GPU服务器，性能提升的同时带来更高的功耗需求。服务器能耗需求有波动，对服务器应用固定的、统一的能耗限制是低效的，underprovisioning => performance degrade/overprovisioning => wasted power

### Insight

* 针对AI model调整CPU和GPU的功率限制可以节省31%能耗

* 不同model的最优CPU/GPU频率不同

* 过去五年，GPU server功耗快速上升：8.5% => 40.9%

  ![share](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003165334224.png)

* Service and Model Heterogeneity

  * CPU/GPU Power功耗拆分，GPU上没有低复杂度任务。（RS：recommendation system0）LLM占用功率较小，RS占用更大。

    ![break](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003172100041.png)

  * 大部分服务的功率利用率低：60%的服务不到80%功率，回收功率是可行的

    ![util](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003174212445.png)

* Variations in Power Usage Across Server Components

  * 静态配置：1kw/GPU，300w/CPU是低效的，CPU/GPU heavy workload

  * server内部GPUs根据运行负载不同功耗有差异

    ![gpu](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003181850938.png)

* Opportunity for Server-level Power Harvesting

  * 由于负载不同，不同server上CPU和GPU功耗具有多样性（整机达到peak时CPU和GPU的功率）

    ![cg](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003183111303.png)

  * power harvesting ：GPU中可以被动态回收的功率，

    * 左图：可回收功率多，右图：同server上GPU间功耗差异很大

    ![cdfs](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003192951792.png)

* 不同模型间需求差异：A更CPU-intensive，C更GPU-bound，需要针对模型的power harvest

  * A：单任务推荐模型，标准推荐模型架构
  * B：多任务广告排序模型，更复杂模型
  * C：多任务内容排序模型，更GPU-bound

  ![models](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003201401346.png)

  * Load Testing：QPS-util、QPS-power呈线性关系，P99排队时延上升有拐点，GPU util可以表征GPU power

    ![loadtest](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003203837617.png)

  * 对单服务器不同组件功率测量：随qps提升其余部分提升，GPU由于降频原因下降

    * 推测：baseline server power control可能使用DVFS，但是只调节GPU freq

    ![component](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261003213904887.png)

* 对CPU和GPU的调频实验，SLO：P99 latency，调频后最低功率/baseline(CPU/GPU最高频率)

  * SLO越宽容，降频空间大，节能更显著
  * QPS越低越节能

  ![cgf](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261004172405324.png)

  * 模拟1h qps load实验，理论节能30%

    ![hour](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261004180256987.png)

  * 可能的节能方向：更低qps下server可以进一步降低frequency，带来低于线性的节能效果（e.g. 一半的load只需不到一半的power），可以考虑负载均衡。

### Design

* Server-level power budgeting：$P_C + \sum_i P_{G_i} \le P_M$

  * GPU没有直接限制功率接口，通过调节频率限制功率
  * CPU直接设置功率限制

* Proxy-Based Load Monitoring：

  * 有service-level、缺乏per-server的负载监控手段，例如QPS per-server，使用GPU util $u_G$做代理（GPU util与qps几乎线性相关），同时可以忽略具体服务
  * 提高$f_G$ => $u_G$下降，降低$f_G$ => $u_G$上升，在一定负载下，$f_G$与$u_G$乘积可以建模为常量$f_G * u_G \approx Q_w$，$Q_w$：服务的请求数

* 算法：主要通过调节CPU/GPU频率控制功率

  * 为$u_G$设定范围，太低浪费功耗，太高不能为请求突发保留空间，调整CPU/GPU频率，内存等功耗较低（见9a）

    * mapping F() 采用之前观察到的在能耗最优时CPU-GPU的利用率关系来线形映射频率

    ![alg1](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261004221935529.png)

* Per-Model Target Utilization Selection：$[u_{min}, u_{max}]$
  * 对每个model分析历史运行的CPU/GPU util trace，选定百分数作为范围
    * Power-optimized：P90，范围更高
    * SLO-optimized：P75，范围更低

### Evaluation

* 实验环境：NVIDIA Grace Hopper System：H100 GPU + Grace CPU

* 负载模拟：同Fig11，低/中/高负载变化

* metrics：

  1. average power consumption 
  2. fraction of queries violating the SLO(最高频率、最高负载下的P99时延)

* baseline：CPU/GPU最高频率

* server power budgeting

  * performance：满足SLO的最高QPS
  * 越低的功率限制提升越明显

  ![r1](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261006224729147.png)

  * 逐部分拆分：收益主要来自将CPU多余的功率分配给GPU

  ![r2](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261006225914801.png)

* power consumption ：

  * Power-Optimized减少24%能耗，SLO-Optimized减少11%能耗

    ![r3](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261006231613441.png)

* SLO attainment：

  * 观察P99 latency超过SLO的比例

    ![r4](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261006232810394.png)

  * baseline：4%，SLO-Optimized：5%，Power-Optimized：14%

* average latency：baseline < SLO-Optimized < Power-Optimized

  ![r5](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261006234012371.png)
  
* resource util：baseline < SLO-Optimized < Power-Optimized

  ![r6](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261006234401170.png)

* 其他模型：

  * SLO-Optimized：8%，Power-OPtimized：19%

  ![r7](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261006234651314.png)

### Appendix

* TDP：device's configurable software-set power cap
* CDF：累积分布函数，数值不超过横轴值的样本比例
* DVFS：Dynamic Voltage and Frequency Scaling
* fleet：机群/服务器群

### TBD

* 再看看fig11负载模拟

## Understanding Inference Scaling for LLMs: Bottlenecks, Trade-offs, and Performance Principles

### Problem

* 与传统的LLM serving(compute-bound prefill/bandwidth-bound decoding)以快速生成结果为目标不同，reasoning-centric LLM在生成最终结果前通常使用CoT进行推理，
  1. capacity wall：产生大量的中间推理token，导致HBM中高kvcache占用，表现出capacity-bound
  2. parallelsim efficiency gap：TP导致GPU间通信开销，PP有pipeline bubbles
  3. architectural divergence:dense model与sparse MoE model的并行策略不同

### Insight

* Meta's Natural Reasoning dataset token length distribution

  * prompt短，output/reason长

  ![distribution](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261008164704093.png)

* 并发实验：concurrency 1k ~ 10k(samples是采样点 = time)

  * 提高并发会使初始吞吐量提高，但KV cache的容量限制会使请求被抢占和重新调度，限制吞吐。不能盲目提升并发度，应该设置KV-aware并发度上限
  * 注：figurec中不同并发度KVcache的配额不同：预算-模型权重-计算与运行时开销

* ![timeline](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261008203944619.png)

  * TTFT：增加并发TTFT减小，减少的排队时延大于可能增加的执行开销
  * TPOT：增加并发TPOT增加，HBM bandwidth、capacity竞争
  * 低并发（<2k）：E2E主要是queue delay；高并发：E2E主要是执行竞争和抢占

  ![TTFT](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261009095203397.png)

* DP：增大batch size吞吐量和时延同步上升，DP策略并不能缓解kv压力，需要配合TP或KV offload等

  * 线性扩展吞吐量
  * 不共享memory
  * HBM util波动来自prefill/decode交替
  * ![fig6](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261009113710722.png)

* TP：

  * DP把模型权重在每张卡上复制一次，而TP把模型权重拆分到8张卡上，保留更高KV容量，带来更大性能提升

    ![fig8910](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261009142826919.png)

* hybrid strategy

  * 14B:DP=8, 小模型在一张GPU中占用较小，kvcache余量大，引入TP通信开销得不偿失

  * 32B:DP=4+TP=2，较大模型通过TP可以为KVcache留出更多空间

  * 性能权衡：DP策略kvcache不足导致的preemption和re-computation vs TP NVlink communication

    ![fig7](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261009144824597.png)

* dense(Llama405B) vs MoE(Deepseek-R1-671B)：model specific strategy

  * 参数量大不允许DP

  ![fig10](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261009161032704.png)

  * dense：TP更好
    * PP：流水线bubble明显；stage间移动activation tensors开销
    * TP：激活保存在各个GPU，只通过NVLink交换梯度
  * MoE：PP=4+TP=2
    * MLA压缩KVcache，可以容纳更多请求，减少bubble

* scaling model parameters

  * 8B小模型HBM BW Util高，bandwidth-bound原因是小权重矩阵加载很快
  * 671B大模型HBM BW Util较低，受限于synchronization和routing latency
  * figure11c：DeepSeek-R1采用MLA压缩KVcache
  
  ![fig11](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261009164131690.png)
  
* prefill vs decode

  * compute-bound prefill：提升bs(总ISL)吞吐量提升，GPU Util高，HBM BW Util/KV Cache Util低
  
  * bandwidth-bound decode：相同bs下与prefill相比吞吐更低，HBM BW Util/KV Cache Util高![fig12](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261010105035335.png)
  
  * ![fig13](/Users/duqirong/Library/Application Support/typora-user-images/image-20261010113313069.png)
  
  * KV usage
  
    * llama405B
  
      ![fig14](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261010114923225.png)
  
    * ds-8B：KVcache随ISL/OSL线性增长
  
      ![fig15](https://raw.githubusercontent.com/coder0xe/Picture-Bed/main/img/image-20261010115015023.png)
  

### Errors

| #    | 位置                           | 问题                                                         |
| ---- | ------------------------------ | ------------------------------------------------------------ |
| 1    | Figure 3(c) 横轴               | 写成 **Max. Seq. Length**，实际改变的是最大并发序列**数量**。 |
| 2    | Figure 3(c) 的解读             | 正文称 E2E 呈非单调凸形、2K 是甜点，但图中 E2E 随并发减少而持续下降，**最低点在 1K**。2K 可以是折中选择，但图没有展示所称的非单调曲线。 |
| 3    | Figure 5 的正文数值            | 写 BS 从 500 增至 5000，E2E 从 **61s→165s**；图中实际是 **61.28s→407.52s**，163.15s 对应 BS=2000。 |
| 4    | Figure 12(e) 的正文数值        | 写 8B 的 Decode HBM 带宽利用率约 **85%**，图中实际约 **58%**。 |
| 5    | Figure 12(e)、13(a) 的指标解读 | 正文说 **SM occupancy 下降或波动**，图中测的是 **GPU Utilization**；Decode GPU Util 反而很高且稳定。 |

### Evaluation

* 8x NVIDIA H200(141GB HBM3e) + dual Intel Xeon Platinum 8558P processors + 2TB DDR5
* dataset：Meta's Natural Reasoning dataset

### Appendix

* DP(Data Parallelism)：数据分成多份，每个GPU上保存相同的模型，算一份数据

* TP(Tensor Parallelism)：把模型权重拆到多张GPU，共同完成计算，带来通信延迟

* PP(Pipeline Parallelism)：按层划分模型，每张GPU负责一段，请求填充不及时导致bubble

* Pareto frontier：多目标优化的边界，在此边界上改善一个指标会使其他指标退化

  
