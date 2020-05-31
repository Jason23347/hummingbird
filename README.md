# Humming bird

此项目通过crontab运行，自动爬取相关网站数据、封装并发送邮件通知。

## 部署

### env
首先参考已存在的 `env.example` 模板文件创建真正的 `env` file。
```
cp env.example env
vim env
```

### 安装 cron 定时任务
cron 定时任务应如下所示：
```
*/5 * * * * /path/tp/hummingbird/index.sh
```

### 修改日志文件路径
日志文件默认存储在 hummingbird 当前目录，定义在 index.sh 中。

## 目录结构与说明
    .
    ├── config
    │   ├── novel1.conf
    │   └── novel2.conf
    ├── drivers
    │   └── kuxiaoshuo
    │       ├── example.conf
    │       └── utils
    ├── env.example
    ├── index.sh
    ├── letters
    │   └── novel
    │       └── utils
    ├── LICENSE
    ├── log-styles
    │   └── plain
    │       └── utils
    ├── mail
    │   └── mutt
    │       └── utils
    └── README.md

`conf`文件夹中存储特定小说的详细配置，可以从`drivers`文件夹中特定驱动下面拷贝一份再修改。

`drivers`文件夹存储各类网站的爬虫驱动，以及默认的配置文件。

`env`文件包含全局配置，包括各类文件夹路径以及收信人邮箱等。

`index.sh`是脚本入口，自动检测`conf`文件夹下的文件并运行。

`letters`包含各种信件模板。

`log-styles`包含日志相关操作。

`mail`包含发送邮件的相关操作。

## PIPE API

该项目的原理是先读取驱动文件以及信件模板，再调用名称固定的函数，最终发出邮件。

函数之间虽然是线性调用关系但是通过unix管道（pipe）连接。

```bash
check_list
[ $? -eq 0 ] &&
    fetch_page | pack_up | send_mail
```
其中 `check_list` 和 `fetch_page`在爬虫驱动中定义，`pack_up` 在信件模板中定义，`send_mail`目前写死，在`index.sh`中定义。

### check_list
该函数应当通过返回值表明最新章节是否更新。
0 代表更新，1 代表位更新。

### fetch_page
该函数的第一个参数是小说的名字，并且应该抓取网页内容。
输出的数据应如下格式
```
<mail subject>
meta head
end with '---', or longer
---
original website data
```
第一行代表小说的名字。
除却网页数据外，还可以在开头加上元数据，通过三个连续的减号 '---' 隔开，或者更长。
样例数据和处理结果（novel template）。

example:
```
subject
chapter name
---
web data
something here
```

result:
```html
subject
<p style="font-size: 25px;">chapter name</p>
<p style="font-size: 20px;">web data</p>
<p style="font-size: 20px;">something here</p>
```

### pack_up
应当通过awk等工具预先处理元数据部分。之后对网页部分进行处理。
输出格式为
```
subject
... // content
```
第一行是邮件主题，其余都是邮件内容。

### send_mail
`send_mail`应该在`mail`子目录中定义，子目录名即为库名。
`send_mail`应该读取第一行作为邮件主题（subject），之后对于`pack_up`输入的数据不应该作任何处理，通过邮件工具（如sendmail，mutt等）发送。

### pipe 编程注意事项
显而易见地，下一个函数不会等待你的输出结束再开始执行，所以如下形式是错误写法：
```bash
rm -f /tmp/file
a() {
    echo "a func"
    sleep 1
    echo "abc" >/tmp/file
}

b() {
    cat /tmp/file
    read line
}

a | b
```
上文执行时一定会报错
```bash
cat: /tmp/file: No such file or directory
```
因为在a函数sleep的时候b函数已经在执行了。
所以既然已经有管道了，就应当避免通过文件传递信息。
