---
title: 过Node的API-events篇
date: 2018-12-11 16:11:58
tags:
  - node
  - js
categories:
  - node
---

### events 概述

events 模块是 node 中一个非常重要的模块,几乎所有的模块都依赖了这个模块。比如 http 的实例可以触发 request 事件，就是因为 http 实例本身也是 events 的一个实例。

```
const http = require('http');
const event = require('events');
const serve = http
  .createServer(function(request, response) {
    response.writeHead(200, { 'Content-Type': 'text/plain' });
    response.end('Hello World\n');
  })
  .listen(7777);
console.log(serve instanceof event); // true
```

   <!-- MORE -->

所以说 events 是一个非常重要的模块，但是 events 这个模块不是很复杂，简单的来说是一个发布订阅模式的实现。

### API 使用

```
module.exports = EventEmitter;
```

抛出的 API 非常简单,是一个构造函数,通过生成实例来使用。

#### 添加事件

1. 使用 on 添加
   emitter.on(eventName, listener)
   eventName <string\> | <symbol\> 事件名称。
   listener <Function\> 回调函数。
   返回: <EventEmitter\>

   ```
   const Event = require('events');
   const myEmitter = new Event();
   myEmitter.on('test1', function() {
        console.log('测试 1');
   });
   myEmitter.on('test1', function() {
        console.log('测试 2');
   });
   ```

   注：
   实例可以添加多个同名的监听器
   on 方法返回的是当前实例，所以可以采用链式调用的写法来注册多个监听器

   ```
   const Event = require('events');
   const myEmitter = new Event();
   myEmitter
        .on('test1', function() {
            console.log('测试 1');
        })
        .on('test1', function() {
            console.log('测试 2');
        });
   ```

2. 使用 addListener 添加
   这个方法是 on 的别名,用法和 on 一致

3. 使用 prependListener 添加
   使用 on 添加的新事件会被添加到监听器数组的末尾，使用这个方法添加的事件则会被添加到开头被优先触发。

4. 使用 once 添加
   使用方法和 on 一致，但添加事件被触发时，监听器会被先移除，然后调用，所以该方法事件只会触发一次

5. 使用 prependOnceListener 添加
   使用 once 添加的新事件会被添加到监听器数组的末尾，使用这个方法添加的事件则会被添加到开头被优先触发，同样只会触发一次。

#### 触发事件

    emitter.emit(eventName[, ...args])
    eventName <string\> | <symbol\>
    ...args <any\>
    返回: <boolean\>
    使用该方法来触发监听器，会按照监听器注册的顺序来同步的调用，args 为需要传入到监听器函数中的参数
    返回值为 blooean,表明是否存在对应监听器

#### 移除事件

1. 移除单个事件
   emitter.removeListener(eventName, listener)
   eventName <string\> | <symbol\> 事件名称。
   listener <Function\> 监听器
   返回: <EventEmitter\>
   ```
   const Event = require('events');
   const myEmitter = new Event();
   function test() {
        console.log('test');
   }
   myEmitter.on('test1', test);
   myEmitter.removeListener('test1', test);
   ```
   注:
   1. 添加监听器时如果使用的是匿名函数，那么无法单独删除这个监听器
   2. 同名监听器只会删除第一个，需要多次调用才可以全部删除
   3. 如果被删除的监听器处于调用队列中时，那么调用结束后才会被删除
2. 移除全部事件
   emitter.removeAllListeners([eventName])
   eventName <string> | <symbol>
   返回: <EventEmitter>
   传入参数时为移除对应的全部监听器，不传时移除全部监听器。

#### 其他内置的事件、方法、属性

1. newListener 事件
   eventName <string\> | <symbol\> 事件的名称。
   listener <Function\> 事件的句柄函数
   新的监听器被添加到其内部监听器数组之前，会触发自身的 'newListener' 事件
   注意：如果在 newListener 中添加同名的监听器那么该监听器会被插入到正被添加的监听器前面。

   ```
   const myEmitter = new MyEmitter();
   // 只处理一次，避免无限循环。
   myEmitter.once('newListener', (event, listener) => {
        if (event === 'event') {
            // 在前面插入一个新的监听器。
            myEmitter.on('event', () => {
            console.log('B');
            });
        }
   });
   myEmitter.on('event', () => {
        console.log('A');
   });
   myEmitter.emit('event');
   // 打印:
   // B
   // A
   ```

2. removeListener 事件
   和 newListener 相反，监听器被移除时触发，传入参数一致。
   注： 当做方法使用时则为移除事件的 api

3. error 事件
   当 EventEmitter 实例出错时，会抛出错误，并退出进程，这是我们需要避免的。我们习惯把错误的回调称为 error 所以我们通常会为实例注册 error 事件来处理错误，所以我们甚至可以把事件命名为 hehe。

   ```
    const Event = require('events');
    const myEmitter = new Event();
    myEmitter.on('error', err => {
         console.error(err);
    });
    myEmitter.on('test', () => {
        let a = 1;
        try {
            a.hehe();
        } catch (error) {
            myEmitter.emit('error', error);
        }
    });
    myEmitter.emit('test');
   ```

4. eventNames 方法
   emitter.eventNames()
   返回: <Array\>
   获取注册的监听器名称
   不接受参数，存在多个同名监听器事在结果中只出现一次

5. listenerCount 方法
   emitter.listenerCount(eventName)
   eventName <string\> | <symbol\> 正在监听的事件名。
   返回: <integer\>

   ```
   myEmitter.listenerCount('test1')
   ```

   返回实例对应监听器的数量

6. listeners 方法
   emitter.listeners(eventName)
   eventName <string\> | <symbol\>
   返回: <Function[]\>

   ```
   myEmitter.listeners('test1'); // [ [Function], [Function] ]
   ```

   返回对应监听器的回调函数
   因为存在同名监听器，所以返回值为数组,且为一个副本

7. getMaxListeners 方法
   emitter.getMaxListeners()
   返回: <integer\>

   返回当前实例允许的最大同名监听器的数量，默认为 10
   超过最大数量时并不会报错，只是会给出警告

8. setMaxListeners 方法
   emitter.setMaxListeners(n)
   n <integer\>
   返回: <EventEmitter\>
   为指定的 EventEmitter 实例修改同名监听器的限制
   值设为 Infinity（或 0）表示不限制监听器的数量
9. defaultMaxListeners 属性
   改变所有 EventEmitter 实例最大监听器数量的默认值，默认为 10 个

   ```
   const Event = require('events');
   Event.defaultMaxListeners = 5;
   ```

   注： 该属性归属于类,优先级低于实例的 setMaxListeners

10. rawListeners 方法
    emitter.rawListeners(eventName)
    eventName <string\> | <symbol\> 事件名称。
    返回: <Function[]\>
    返回 eventName 事件的监听器数组的拷贝，包括封装的监听器（例如由 .once() 创建的）
    ```
    const emitter = new EventEmitter();
    emitter.once('log', () => console.log('只记录一次'));
    // 返回一个数组，包含了一个封装了 `listener` 方法的监听器。
    const listeners = emitter.rawListeners('log');
    const logFnWrapper = listeners[0];
    // 打印 “只记录一次”，但不会解绑 `once` 事件。
    // 封装的监听器或得到的是个对象类型
    logFnWrapper.listener();
    // 打印 “只记录一次”，且移除监听器。
    logFnWrapper();
    emitter.on('log', () => console.log('持续地记录'));
    // 返回一个数组，只包含 `.on()` 绑定的监听器。
    const newListeners = emitter.rawListeners('log');
    // 打印两次 “持续地记录”。
    newListeners[0]();
    emitter.emit('log');
    ```

#### 遗留问题

1. 传参数与 `this` 到监听器
   监听器被调用时，this 将指向对应的实例
   ```
   const myEmitter = new MyEmitter();
   myEmitter.on('event', function(a, b) {
        console.log(this === myEmitter);
        // 打印:
        //  true
   });
   myEmitter.emit('event', 'a', 'b');
   ```
   也可以使用 ES6 的箭头函数作为监听器,但 this 关键词不会指向 EventEmitter 实例
   ```
   const myEmitter = new MyEmitter();
   myEmitter.on('event', (a, b) => {
        console.log(this);
        // {} 根据ES6的规定这里的this指向的事moudle.exports
   });
   myEmitter.emit('event', 'a', 'b');
   ```
2. 使用异步
   默认监听器的调用为同步方式，可以使用 setImmediate()或 process.nextTick()切换到异步方式
   ```
   const myEmitter = new MyEmitter();
   myEmitter.on('event', () => {
        setImmediate(() => {
            console.log('异步进行1');
        });
   });
   myEmitter.on('event', (a, b) => {
        console.log('异步进行2');
   });
   myEmitter.emit('event');
   // 打印
   // 异步进行2
   // 异步进行1
   ```
