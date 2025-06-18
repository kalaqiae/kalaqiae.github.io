---
title: "Python Note"
date: 2025-05-11T21:40:59+08:00
draft: true
tags: ["Python"]
categories: ["Python"]
---

[官方文档](https://docs.python.org/zh-cn/3.13/tutorial/index.html)

[廖雪峰Python](https://liaoxuefeng.com/books/python/introduction/index.html)

<!--more-->

## 数据类型

### 数值类型

#### int

0比较多时可以用_分隔：1000000000可以写成1000_000_000

#### float

科学计数法写法：1.23e3，等价于1230

#### complex

Python支持复数直接表示法，就是(a+bj)的形式，complex类的实例，可以直接运算，比如：a = 1 + 2j + 3 * 4j，输出a，结果是：(1+14j)，「实数+虚数」。除了a+bj，还可以用complex(a,b)表示，两个都是浮点型，可以调用.real获得实部，.imag 获得虚部，abs()求复数的模(√(a^2 + b^2))

#### bool（是 int 的子类）

True，False 注意区分大小写

### 空类型

None

### 字符串

用单引号'或双引号"括起来

#### 格式化

```python

name = "kalaqiae"
age = 18

# 1.f-strings (Python 3.6+ 推荐)
print(f"Hello, {name}. You are {age} years old.")
print(f"Next year you will be {age + 1} years old.")
# 格式控制
pi = 3.1415926
print(f"Pi is approximately {pi:.2f}")  # 输出: Pi is approximately 3.14

# 2.使用str.format()(Python 2.6+)
print("Hello, {}. You are {} years old.".format(name, age))
print("Hello, {1}. You are {0} years old.".format(age, name))
print("Hello, {name}. You are {age} years old.".format(name="kala", age=25))

pi = 3.1415926
# 格式控制
print("{:.2f}".format(pi))  # 输出: 3.14

# 3.使用 %
print("Hello, %s. You are %d years old." % (name, age))
# 格式控制
print('%2d-%02d' % (3, 1))
print('%.2f' % 3.1415926)

# 4.模板字符串 (string.Template)
from string import Template
t = Template("Hello, $name. You are $age years old.")
print(t.substitute(name="kalaqiae", age=18))

```

#### 常用操作

```python

text = "Hello, Python!"
print(type(text))  # <class 'str'>

print(text.upper())  # "HELLO, PYTHON!"
print(text.split(","))  # ['Hello', ' Python!']
print(text[0])  # 'H'（索引访问）
print(len(text))  # 14（长度）
```

#### 转义字符

```python

# 换行或内容包含引号等情况使用转义字符\
print('I\'m \"OK\"! \n test \\')

# 为了简化转义，可以用r''，使内部的字符串不转义，可以方便换行或输出多个\
print(r'\\\
\\\')

# 为了简化换行，可以用'''...'''，内部回车即换行
print('''line1
line2''')

```

### List (列表)

有序，可变，允许重复元素

* 增
  * append(x)：末尾添加元素
  * insert(i, x)：在索引 i 处插入 x
  * extend(iterable)：合并另一个列表/可迭代对象
* 删
  * remove(x)：删除第一个匹配的 x
  * pop(i)：删除并返回索引 i 处的元素（默认最后一个）
  * clear()：清空列表
* 改
  * list[i] = x：直接修改索引 i 处的值
* 查
  * index(x)：返回 x 的索引（不存在则报错）
  * count(x)：统计 x 出现的次数
  * x in list：判断 x 是否在列表中
* 排序，反转
  * sort()：升序排序（reverse=True 降序）
  * sorted(list)：返回排序后的新列表（原列表不变）
  * reverse()：反转列表（原地修改）
  * list[::-1]：返回反转后的新列表
* 其他
  * len(list)：获取列表长度
  * copy() / list[:]：复制列表（浅拷贝）
  * list1 + list2：拼接两个列表

创建

```python

# 空列表
empty_list = []
empty_list = list()

# 包含元素的列表
numbers = [1, 2, 3, 4, 5]
mixed = [1, "hello", 3.14, True]
nested = [[1, 2], [3, 4], [5, 6]]  # 嵌套列表

# 使用构造器
from_iterable = list("abc")  # ['a', 'b', 'c']
from_range = list(range(5))  # [0, 1, 2, 3, 4]

```

访问

```python

lst = [10, 20, 30, 40, 50]

# 索引访问(从0开始)
print(lst[0])   # 10
print(lst[-1])  # 50 (负索引表示从末尾开始),访问最后一个用lst[-1]或len(lst) - 1

# 切片操作 [start: end:step]
print(lst[1:3])    # [20, 30]
print(lst[::2])    # [10, 30, 50] (步长为2)
print(lst[::-1])   # [50, 40, 30, 20, 10] (反转列表)
```

添加

```python
lst = [1, 2, 3]

lst.append(4)       # [1, 2, 3, 4] (末尾添加单个元素)
lst.extend([5, 6])  # [1, 2, 3, 4, 5, 6] (扩展多个元素)
lst.insert(1, 1.5)  # [1, 1.5, 2, 3, 4, 5, 6] (在索引1处插入)
```

删除

```python

lst = [1, 2, 3, 2, 4]

lst.remove(2)    # [1, 3, 2, 4] (删除第一个匹配值)
popped = lst.pop()    # 4, 列表变为 [1, 3, 2] (删除并返回最后一个元素)
popped = lst.pop(1)   # 3, 列表变为 [1, 2] (删除并返回指定索引元素)
del lst[0]       # [2] (删除索引0的元素)
lst.clear()      # [] (清空列表)
```

修改

```python
lst = [1, 2, 3, 4]

# 修改单个元素
lst[0] = 100  # [100, 2, 3, 4]

# 修改切片
lst[1:3] = [200, 300]  # [100, 200, 300, 4]
lst[1:3] = [500]       # [100, 500, 4] (可以改变长度)
```

查找

```python
lst = [1, 2, 3, 2, 4]

index = lst.index(2)     # 1 (返回第一个匹配值的索引)
count = lst.count(2)     # 2 (统计值出现的次数)
exists = 3 in lst        # True (成员检查)
```

排序和反转

```python

lst = [3, 1, 4, 2]

lst.sort()              # [1, 2, 3, 4] (原地排序)
lst.sort(reverse=True)  # [4, 3, 2, 1] (降序排序)
sorted_lst = sorted(lst)  # 返回新列表，原列表不变

lst.reverse()           # [1, 2, 3, 4] -> [4, 3, 2, 1] (原地反转)
reversed_lst = list(reversed(lst))  # 返回反转后的新列表
```
  
### Tuple (元组)

有序，不可变，允许重复元素，类似不可变的list，一般可作为作为字典的键，性能比list好一点

创建

```python
# 使用圆括号
t1 = (1, 2, 3)

# 也可以不使用圆括号（仅适用于简单情况）
t2 = 1, 2, 3

# 创建单个元素的元组（需要尾随逗号）
single_tuple = (4,)  # 注意逗号
not_a_tuple = (4)    # 这不是元组，只是整数4

# 空元组
empty_tuple = ()
```

访问

```python
my_tuple = ('a', 'b', 'c', 'd', 'e')

# 通过索引访问
print(my_tuple[0])  # 输出: 'a'

# 负索引
print(my_tuple[-1])  # 输出: 'e'

# 切片
print(my_tuple[1:3])  # 输出: ('b', 'c')
```

常用操作

```python
# 连接元组
tuple1 = (1, 2, 3)
tuple2 = (4, 5)
combined = tuple1 + tuple2  # (1, 2, 3, 4, 5)

# 重复元组
repeated = tuple1 * 2  # (1, 2, 3, 1, 2, 3)

# 成员检查
print(2 in tuple1)  # True

# 长度
print(len(tuple1))  # 3

# 计数
print((1, 2, 2, 3).count(2))  # 2

# 查找索引
print((1, 2, 3).index(2))  # 1
```

### Set (集合)

无序，可变，不允许重复元素,不可变集合使用 frozenset

创建

```python
# 使用花括号
s = {1, 2, 3}

# 使用 set() 构造函数
s = set([1, 2, 3, 2])  # 结果为 {1, 2, 3}，自动去重

# 空集合必须用 set()，不能用 {}（这是空字典）
empty_set = set()
```

添加

```python
s.add(4)      # 添加单个元素
s.update([5, 6, 7])  # 添加多个元素
```

删除

```python
s.remove(3)   # 移除元素，不存在则引发 KeyError
s.discard(3)  # 移除元素，不存在也不报错
s.pop()       # 随机移除并返回一个元素
s.clear()     # 清空集合
```

运算

```python
a = {1, 2, 3}
b = {2, 3, 4}

# 并集
a | b  # 或 a.union(b) → {1, 2, 3, 4}

# 交集
a & b  # 或 a.intersection(b) → {2, 3}

# 差集
a - b  # 或 a.difference(b) → {1}

# 对称差集（仅在其中一个集合中的元素）
a ^ b  # 或 a.symmetric_difference(b) → {1, 4}
```

比较

```python
a.issubset(b)     # a 是否是 b 的子集
a.issuperset(b)   # a 是否是 b 的超集
a.isdisjoint(b)   # a 和 b 是否没有交集
```

其他

* len(s)：返回集合元素个数
* x in s：测试元素是否在集合中
* s.copy()：返回集合的浅拷贝

### Dictionary (字典)

无序，可变，键值对存储，键唯一，key必须是不可变对象

创建

```python
# 空字典
empty_dict = {}
empty_dict = dict()

# 直接初始化
person = {'name': 'kala', 'age': 6, 'city': 'fuchou'}

# 使用dict构造函数
person = dict(name='kala', age=25, city='fuchou')

# 从键值对序列创建
pairs = [('name', 'kala'), ('age', 25)]
person = dict(pairs)
```

基本操作

```python
# 访问元素
name = person['name']

# 添加/修改元素
person['job'] = 'Engineer'  # 添加新键
person['age'] = 23         # 修改已有键

# 删除元素
del person['city']         # 删除键
age = person.pop('age')    # 删除并返回值
person.clear()             # 清空字典
```

常用方法

```python
# 获取所有键
keys = person.keys()       # dict_keys(['name', 'age', ...])

# 获取所有值
values = person.values()   # dict_values(['kala', 23, ...])

# 获取所有键值对
items = person.items()     # dict_items([('name', 'kala'), ...])

# 安全获取值
age = person.get('age', 0)  # 如果'age'不存在返回0

# 检查键是否存在
if 'name' in person:
    print("Name exists")

# 更新字典
person.update({'age': 10, 'gender': 'F'})  # 合并字典
```

## 变量，常量

变量赋值时可以绑定不同类型的数据值

```python
a = 123 # a是整数
print(a)
a = 'ABC' # a变为字符串
print(a)
```

常量：使用大写变量名表示，不过只是起一种提示效果，本质上还是变量

### 类型转换

* int()
* str()
* float()
* list()
...

## 条件语句

```python
# 例子1：if-elif-else
score = 85
if score >= 90:
    print("优秀")
elif score >= 80:
    print("良好")
elif score >= 60:
    print("及格")
else:
    print("不及格")

# 例子2：值1 if 条件 else 值2
age = 20
status = "成年" if age >= 18 else "未成年"
print(status)

# 使用字典
def match_value(x):
    return {
        1: "one",
        2: "two",
        3: "three",
    }.get(x, "unknown")  # 默认值 "unknown"

# Python 3.10+ 的 match-case（模式匹配）
def match_value(x):
    match x:
        case 1:
            return "one"
        case 2:
            return "two"
        case 3:
            return "three"
        case _:
            return "unknown"
```

Python 会将变量隐式转换为布尔值（True/False），规则如下：

视为 False 的情况：

* 空容器：[]、{}、()、set()、""（空字符串）
* 数字 0、0.0
* None
* False 本身

其他情况：均视为 True

```python
profile_data = {}
if profile_data:  # 等价于 if len(profile_data) > 0:
    print("有资料")
else:
    print("无资料")  # 会执行这里
```

## 循环语句

```python

# for
# 遍历列表
fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)

# 遍历字符串
for char in "Python":
    print(char)

# 使用range()函数
for i in range(5):  # 0到4
    print(i)

for i in range(2, 6):  # 2到5
    print(i)

for i in range(0, 10, 2):  # 0到9，步长为2
    print(i)

# while
# 简单while循环
count = 0
while count < 5:
    print(count)
    count += 1

# 无限循环（需要有退出条件）
while True:
    user_input = input("输入'quit'退出: ")
    if user_input == 'quit':
        break

# 中断
# break - 完全终止循环
# continue - 跳过当前迭代，继续下一次循环
# else - 循环正常结束后执行（非break终止）
for i in range(5):
    print(i)
else:
    print("循环正常结束")
```

## 输入和输出

input 注意类型，默认字符串类型

## 数学函数

* abs()
* ceil()
* floor()
* round()
...

## 运算

* 除法需要注意：/(除) //(地板除法，舍弃小数)
* 逻辑运算符： and, or, not
* 成员运算符：in 和 not in
* 幂运算： **
* 身份运算符： is 和 is not

## 随机数

```python
rand_float = random.random()  # [0.0, 1.0) 生成 0-1 之间的随机浮点数
rand_int = random.randint(1, 10)  # [1, 10] 包含两端的随机整数
rand_range = random.randrange(1, 10)  # [1, 10) 不包含10
rand_range_step = random.randrange(1, 10, 2)  # 1,3,5,7,9

# 从序列中随机选择
items = ['apple', 'banana', 'cherry']
random_choice = random.choice(items)  # 随机选一个
random_sample = random.sample(items, 2)  # 随机选多个（不重复）
random_shuffle = random.shuffle(items)  # 打乱顺序（原地修改）
```

## 函数

### 函数参数

位置参数

```python
def greet(name, age):
    print(f"{name} 今年 {age} 岁了。")
```

默认参数

```python
def power(base, exponent=2):
    return base ** exponent
```

关键字参数

```python
def person_info(name, age, city):
    print(f"{name}, {age} years old, from {city}")

person_info(age=30, city="New York", name="Alice")
```

可变参数

```python
def variable_args(*args, **kwargs):
    print("位置参数:", args)
    print("关键字参数:", kwargs)
```

参数顺序

位置参数→ 默认参数 → 可变位置参数（*args）→ 命名关键字参数 → 可变关键字参数（**kwargs）

```python
def register_user(username, password, email=None, *interests, country, city="Unknown", **profile_data):
    """
    注册新用户
    
    参数:
        username (str): 必填 - 用户名
        password (str): 必填 - 密码
        email (str, optional): 可选 - 邮箱，默认为None
        *interests (str): 可变数量的兴趣标签
        country (str): 必须用关键字指定 - 国家（命名关键字参数）
        city (str): 可选 - 城市，默认"Unknown"
        **profile_data: 其他用户资料（如年龄、职业等）
    """
    print("\n=== 用户注册信息 ===")
    print(f"用户名: {username}")
    print(f"密码: {'*' * len(password)}")
    if email:
        print(f"邮箱: {email}")
    if interests:
        print(f"兴趣: {', '.join(interests)}")
    print(f"国家: {country}, 城市: {city}")
    if profile_data:
        print("其他资料:")
        for key, value in profile_data.items():
            print(f"  - {key}: {value}")

# 调用示例
register_user(
    "tech_guy", 
    "secure123", 
    "tech@example.com", 
    "编程", "游戏",  # 这些会被 *interests 捕获
    country="China",        # 命名关键字参数必须明确写 country=
    city="Beijing",         # 可选命名关键字参数
    age=18,                 # 这些会被 **profile_data 捕获
    occupation="工程师"
)
```

### 返回值

可以返回多个值(实际上是返回一个元组)

```python
def min_max(numbers):
    return min(numbers), max(numbers)

minimum, maximum = min_max([1, 2, 3, 4, 5])
```

没有return语句：则默认返回 None

### 作用域

使用 global 关键字在函数内部修改全局变量

```python
x = 10  # 全局变量

def modify_global():
    global x
    x = 20
```

### Lambda 函数

```python
# 普通函数
def square(x):
    return x ** 2

# Lambda 等价写法
square = lambda x: x ** 2

# 常用场景：配合 sorted/map/filter
names = ["Alice", "Bob", "Charlie"]
sorted_names = sorted(names, key=lambda x: len(x))  # 按长度排序
```

### 高阶函数

接收函数作为参数，返回修改后的函数

```python
# 常见高阶函数
# map：映射
squared = map(lambda x: x ** 2, [1, 2, 3])  # → [1, 4, 9]

# filter：过滤
even = filter(lambda x: x % 2 == 0, [1, 2, 3, 4])  # → [2, 4]

# reduce：累计
from functools import reduce
product = reduce(lambda x, y: x * y, [1, 2, 3, 4])  # → 24
```

#### 装饰器

是闭包的一个重要应用，提供了一种优雅的方式来修改或增强现有函数的行为，而无需改变其内部代码

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        print("Something is happening before the function is called.")
        result = func(*args, **kwargs)
        print("Something is happening after the function is called.")
        return result
    return wrapper

@my_decorator
def say_hello(name):
    print(f"Hello, {name}!")

say_hello("Alice")

# 不使用 @ 语法糖等价形式：

def say_hello(name):
    print(f"Hello, {name}!")

say_hello = my_decorator(say_hello) # 手动调用装饰器

say_hello("Alice")
```

### 类型提示(Python 3.5+)

```python
def greet(name: str) -> str:
    return f"Hello, {name}"
```

### 生成器函数

* 使用 yield 代替 return
* 延迟计算： 值是在需要时才生成的，而不是一次性全部生成并存储在内存中。这对于处理大量数据或无限序列非常有用
* 节省内存： 尤其是当数据量很大时，生成器比一次性生成所有元素的列表更节省内存
* 可迭代性： 生成器对象是迭代器，可以使用 for 循环进行遍历
* 每次调用 next() 或迭代时产生一个值

```python
def count_up_to(n):
    i = 1
    while i <= n:
        yield i
        i += 1

gen = count_up_to(3)
# 使用迭代获取值
for num in gen:
    print(num)
# 使用next获取下一个值
print(next(gen))
```

### 偏函数

固定函数的部分参数，生成一个新函数

场景：参数预设,简化函数调用

Python 的 functools 模块提供了 partial 函数来实现偏函数

functools.partial(func, *args, **keywords)

* func：你想要固定参数的原始函数
* *args：你想要固定位置参数
* **keywords：你想要固定关键字参数

```python
from functools import partial

# 原函数
def power(base, exponent):
    return base ** exponent

# 创建偏函数：固定 exponent=2（即平方函数）
square = partial(power, exponent=2)  

print(square(3))  # 输出 9（相当于 power(3, exponent=2)）
```

## 类

```python
class Person:
    species = "Homo sapiens"  # 类变量，所有实例共享

    # __init__ 是构造函数。self 代表实例本身，是方法中必须的第一个参数（自动传入）
    def __init__(self, name, age):
        self.name = name  # 实例变量
        self.age = age
        # 私有变量，Python 没有真正的“私有”，但可以通过约定和名称改写来实现
        self._internal_var = 10  # 约定私有变量，只是一个约定，用于子类可能需要访问
        self.__private_var = 20  # Python 会将其改写为 _ClassName__variable 的形式，用于继承场景下避免命名冲突

    # 实例方法
    def greet(self):
        return f"Hello, my name is {self.name} and I'm {self.age} years old."
```

继承

```python
class Animal:  # 父类/基类
    def __init__(self, name):
        self.name = name
    
    def eat(self):
        raise NotImplementedError("子类必须实现此方法")

    def speak(self):
        return "动物叫声"

class Dog(Animal):  # 子类/派生类

    # super 使用
    def __init__(self, name, age):
        super().__init__(name)  # 调用父类的__init__
        self.age = age

    def speak(self):  # 方法重写
        return "汪汪汪"

# 多继承
class Father:
    pass

class Mother:
    pass

class Child(Father, Mother):  # 多继承
    pass
```

多态

```python
# 两种方式
# 1.方法重写，需要继承关系
class Animal:
    def speak(self):
        print("动物发出声音")

class Dog(Animal):
    def speak(self):  # 重写父类方法
        print("汪汪汪")

class Cat(Animal):
    def speak(self):  # 重写父类方法
        print("喵喵喵")

# 多态调用
animals = [Dog(), Cat()]
for animal in animals:
    animal.speak()
# 输出：
# 汪汪汪
# 喵喵喵

# 2.鸭子类型，不需要继承关系，Python更推崇鸭子类型，比较灵活
# 如果它走起来像鸭子，叫起来像鸭子，那么它就是鸭子
class Duck:
    def quack(self):
        print("嘎嘎嘎")

class Person:
    def quack(self):
        print("人在模仿鸭子叫")

class Car:
    def drive(self):
        print("汽车行驶中")

def make_quack(obj):
    if hasattr(obj, 'quack'):  # 检查对象是否有quack方法
        obj.quack()
    else:
        print("这个对象不会叫")

# 调用
make_quack(Duck())   # 嘎嘎嘎
make_quack(Person()) # 人在模仿鸭子叫
make_quack(Car())    # 这个对象不会叫
```

<!-- 
常用模块

多线程 协程

数据库

网络请求 -->
