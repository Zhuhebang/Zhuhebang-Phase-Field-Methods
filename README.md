# Zhuhebang-Phase-Field-Methods
##  **muBreakdown任务**

1. **生成结构：**我们将利用python写一个，专门生成结构的程序。需要从一个文件读入输入参数，然后生成结构文件。

- a.   我加了你们进一个仓库，https://github.com/sijintech/stk/tree/main/python/structure-generator，里面`python/structure-generator`下面是我们正在写的一个python的包，专门用来生成结构文件的。你们可以简单看一下下面的代码，然后约个时间我给你们简单讲一下它的结构。之后具体内容，可以在issue里交流。

- b.   这个生成结构的第一步可以先把`mubreakdown/main.f90`里一开始那一段生成结构的代码移到python里来。成功后再按照我们的需要设置这个项目的结构。

2. **breakdown程序改造：**然后改写`breakdown`程序，补充从输入文件读入信息，删除非必要的代码

- a.   当前`main`里前面一大段，都是在设置材料结构，它现在是写了`structure.dat`，我们需要在这里添加一段从`structure.in`读结构的，读的格式就是前面1中生成的。一开始用于测试的文件可以就是之前生成的`structrue.dat`

- b.   当`structure.in`读入格式没问题了，我们就把前面那些生成结构的代码可以删了，或者挪到任务1中的python库里去。

- c.    现在`nx，ny，nz`这些参数是设置在`globalvars`里的，这是很不好的，我们应该把这个改成从`input.in`里面读入。这就涉及到很多变量从直接声明`（nx，ny，nz）`变成`allocatable`类型。

- d.   参考`muprosdk/apps/muferro`的结构，把`mubreakdown`的结构也调整一下。

3. **高通量任务生成：**用python写个小程序，根据设定参数空间，自动生成高通量任务及计算脚本。

- a.   我想了想，准备后面用go，而不用python来搞这个，现在的话还是直接用我以前写的一个工具吧，我把你们加到https://github.com/billcxx/htp-studio这个仓库里了，它的使用说明在这里https://htp-studio.surge.sh/。高通量这个不着急，先把1，2都做完再做高通量。

 

### **结构生成**

1. 加一个3D的文件夹，里面放`breakdown`的数据生成，也就是你们当前`generate-structure`的内容，但我看里面那两个函数其实是`basic`里面的，你们考虑跟`basic`里面的合并一下，可以替换原本它的函数
2. 在`basic`里面加上你们的`write_structure`，我感觉应该支持两种

- a. 一个是现在这种x, y, z, p, s, m, v
- b. 另外一种应该是x, y, z, phi，最后的phi就是相编号，比如先假设p, s, v, m各自分别对应1,  2, 3, 4号相，那phi的值就是1234

3. 在scripts的generate_structure里面，从读的toml关键字里先判断一下是什么类型的结构。比如加一个target_program的关键字，判断如果等于muBreakdown，就采用当前breakdown这一套设置的值，原本程序已有的可以都放到muPREDICT这种target_program的情况下。

＊＊ hello world **