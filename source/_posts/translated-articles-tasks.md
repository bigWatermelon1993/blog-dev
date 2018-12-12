---
title: 宏任务、微任务、队列和时间轴[译]
date: 2018-12-12 15:21:39
tags:
  - js
categories:
  - js
---

{% blockquote Jake https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/ Tasks, microtasks, queues and schedules %}
原文链接
{% endblockquote %}
当我告诉我的同事 Matt Gaunt 我正在思考写一篇有关于宏任务和浏览器中事件循环执行的文章时,他对我说：“我可以诚实的告诉你，我不打算读它。”好吧，无论如何我现在已经写完了，那何不坐这里好好读一下呢。
事实上，如果你更喜欢视频的形式，Philip Roberts 在 JSConf 上做了一次有关于事件循环非常棒的演讲(没有涉及到微任务)，但是对于其他部分而言是一个非常好的介绍。下面让我们开始吧。

  <!-- MORE -->

先看一点代码：

```
console.log('script start');

setTimeout(function() {
  console.log('setTimeout');
}, 0);

Promise.resolve().then(function() {
  console.log('promise1');
}).then(function() {
  console.log('promise2');
});

console.log('script end');
```

正确的打印顺序是 script start, script end, promise1, promise2, setTimeout，但是这个结果在不同浏览器下会有偏差。
Edge, Firefox 40,移动端的 Safari 和桌面端的 Safari（版本 8.0.8），会在打印 promise1, promise2 之前打印 setTimeout。非常奇怪的是在 Firefox 39 and Safari 8.0.7 中又会打印出正确的顺序。

### 为什么会这样

要想理解为什么会这样我们需要理解事件循环是怎么处理任务和微任务的。如果你是第一次碰到这个问题那么这可能花费你不少的脑细胞，深呼吸，开始吧！
每个 Web worker 都拥有能够独立执行的 event loop，而同一个源上的所有窗口借助同步通信可以共享一个 event loop。 event loop 持续不断的运行来处理排列的任务。

{% centerquote %}太难翻了，立个 lage,我后面一定会把它翻译完。{% endcenterquote %}
