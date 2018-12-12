---
title: 过Node的API-URL篇
date: 2018-12-05 19:03:45
tags:
  - node
  - js
categories:
  - js
  - node
---

### 2 套 API

url 模块提供了两套 API:

1. 旧版本的遗留--Node.js 特有 API
2. WHATWG URL Standard 的 API--在各种浏览器中被使用

<!-- MORE -->

官网上有个非常好的图
{% asset_img node-url-params.png API示意图 %}
 红字上方为遗留 API 解析后的参数,下方为 WHATWG URL Standard 解析后的参数,差异并不大,主要集中在 2 处。

1.  原有的 auth 被拆分为--username 和 password
2.  原有的 API 提供 query 使用-- 新版移除
3. 标准 API 使用了 gette 和 setter 来实现效果，所以我们修改某个值后，关联的部分会对应修改,但是遗留 API 不会，所以对于遗留 API,通常是 parse 配合 format 来使用

### API 使用  方式

 下面是 nodejs 抛出的接口，node 的注释还是非常棒的,可以清楚看出来需要解构哪个使用。

```
module.exports = {
// Original API
Url,
parse: urlParse,
resolve: urlResolve,
resolveObject: urlResolveObject,
format: urlFormat,

// WHATWG API
URL,
URLSearchParams,
domainToASCII,
domainToUnicode,

// Utilities
pathToFileURL,
fileURLToPath
};
```

#### 简单使用

建议使用标准 API，遗留的只是为了兼容已存在的应用程序。
new URL(input[, base])
input <string\> 要解析的输入 URL
base <string\> | <URL> 如果“input”是相对 URL，则为要解析的基本 URL

```
const myURL = new URL('https://user:pass@sub.host.com:8080/p/a/t/h?query=string#hash');
```

{% asset_img result.png 标准api使用结果图 %}

#### 处理 query

- 使用遗留 API parse
  在 API 示意图中我们可以看到存在字段 query

  ```
  const { parse } = require('url');
  const myURL = parse(
  'https://user:pass@sub.host.com:8080/p/a/t/h?query=string#hash',
  true,
  );

  ```

  第二个参数为 true 时，query 为 object，false 则为 string。
  不推荐这种使用方式，因为我们只能读取，如果修改后对应的值不会做出相应变更，所以推荐使用以下 2 种标准 API 的方式。

- 使用 searchParams
  标准 api 使用结果图中我们看到输出值有 searchParams，但是这个属性为只读属性，我们并不能操作，需要使用对应的 api。

```
myURL.searchParams.get('query')
// get获取的是第一个，getAll获取到的是全部,类型为Array在实际的应用中，我们基本不会出现同名的字段。
myURL.searchParams.getAll('query')
// append为追加，可以追加同名query
myURL.searchParams.append('abc', 'xyz');
// set为重置，没有时则为添加
myURL.searchParams.set('a', 'b');
myURL.searchParams.delete('abc');
```

注：还有部分方法参见 URLSearchParams 类

除了以上方法以外，我们还可以通过写入 search 属性来整体重置 query 的值

- 使用 URLSearchParams 类
  URLSearchParams 类本质上和 searchParams 一样，使用的 api 也一致。
  通过 new 的形式构造即可,接受 string 和 object 以及 iterable 类型的参数，如果 string 以'?'打头,则'?'将会被忽略。
  ```
  const { URLSearchParams } = require('url');
  const myURL = new URL('https://example.org/?abc=123');
  // 下面的代码等同于 const newSearchParams = new URLSearchParams(myURL.search);
  const newSearchParams = new URLSearchParams(myURL.searchParams);
  newSearchParams.append('a', 'c');
  // newSearchParams.toString() 被隐式调用
  myURL.search = newSearchParams;
  ```
  URLSearchParams 类还拥有 forEach，has，keys，sort，values，entries 等方法。

#### 返回格式化 url

- 对于标准 API:
  URL 对象的 toString()方法和 href 属性都可以返回 URL 的序列化的字符串,但都不可以被定义，可以通过 format 来自定义
  url.format(URL[, options]) auth fragment(#号的锚点部分) search unicode
- 对于遗留 API:
  url.format(urlObject) 传入一个 object 写入各个对应的值来生成，通常和 parse 配合使用。

#### 未总结 API

部分 API 不做介绍了。
resolve(把目标 url 解析成相对于基础 url 的格式) resolveObject domainToASCII domainToUnicode pathToFileURL fileURLToPath

### 总结&TODo

#### 总结

1. url 模块是 nodejs 中一个比较简单的模块，用来出来处理 url，方便我们使用。存在 2 套 API，一套是标准 API，遵循 WHATWG URL Standard，这个标准也被广大浏览器所采用，遗留的 API 则为兼容之前程序而被保留。
2. 根据浏览器的约定，URL 对象的所有属性都是在类的原型上实现为 getter 和 setter，而不是作为对象本身的数据属性。新的 API 实现了这部分的要求，所以也推荐使用标准 API，旧的 API 则通常需要 parse 和 foramt 配合使用。

#### ToDo

```
const { URL } = require('url');
const myUrl = new URL(
  'https://user:pass@sub.host.com:8080/p/a/t/h?query1=string1&query2=string2#hash',
);
// 打印myUrl可以看到port但是下面的语句返回false
myUrl.hasOwnProperty('port') // false
```

暂时还没想到上面的效果可以怎么实现
