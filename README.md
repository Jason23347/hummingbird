# Novel-notifice

此项目通过crontab运行，自动爬取相关网站数据、封装并发送邮件通知。

## 目录结构与说明
    .
    ├── config
    │   ├── 1.conf
    │   └── 2.conf
    ├── drivers
    │   └── kuxiaoshuo
    │       ├── example.conf
    │       └── utils
    ├── env
    ├── index.sh
    ├── letters
    │   └── novel
    │       └── utils
    └── README.md

`conf`文件夹中存储特定小说的详细配置，可以从`drivers`文件夹中特定驱动下面拷贝一份再修改。

`drivers`文件夹存储各类网站的爬虫驱动，以及默认的配置文件。

`env`文件包含全局配置，包括各类文件夹路径以及收信人邮箱等。

`index.sh`是脚本入口，自动检测`conf`文件夹下的文件并运行。

`letters`包含各种信件模板。

``

## PIPE API

该项目的原理是先读取驱动文件以及信件模板，再调用名称固定的函数，最终发出邮件。

函数之间虽然是线性调用关系但是通过unix管道（pipe）连接。

```bash
check_list
[ $? -eq 0 ] &&
    fetch_page $name | pack_up | send_mail
```
其中 `check_list` 和 `fetch_page`在爬虫驱动中定义，`pack_up` 在信件模板中定义，`send_mail`目前写死，在`index.sh`中定义。

### check_list
该函数应当通过返回值表明最新章节是否更新。
0 代表更新，1 代表位更新。

### fetch_page
该函数的第一个参数是小说的名字，并且应该抓取网页内容。
输出的数据应如下格式
```
meta info
end with '---', or longer
------
<html>
...
</html>
```
除却网页数据外，还可以在开头加上元数据，通过三个连续的减号 '---' 隔开，或者更长。

### pack_up
应当通过awk等工具预先处理元数据部分。之后对网页部分进行处理。
输出格式为
```
subject
... // content
```
第一行是邮件主题，其余都是邮件内容。

### send_mail
除了读取第一行作为邮件主题（subject），对于`pack_up`输入的数据不应该作任何处理，通过邮件工具发送出去。

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
