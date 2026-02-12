import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';

/// Demo page for testing Mermaid diagrams
class MermaidDemo extends StatefulWidget {
  const MermaidDemo({super.key});

  @override
  State<MermaidDemo> createState() => _MermaidDemoState();
}

class _MermaidDemoState extends State<MermaidDemo> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<MermaidExample> _examples = [
    // Flowchart examples
    MermaidExample(
      title: '基础流程图 (TD)',
      description: '从上到下的简单流程图',
      code: '''graph TD
    A[开始] --> B{判断}
    B -->|是| C[处理A]
    B -->|否| D[处理B]
    C --> E[结束]
    D --> E''',
    ),
    MermaidExample(
      title: '流程图 (LR)',
      description: '从左到右的流程图',
      code: '''graph LR
    A[输入] --> B[处理]
    B --> C[输出]
    C --> D{验证}
    D -->|通过| E[完成]
    D -->|失败| A''',
    ),
    MermaidExample(
      title: '流程图 (BT)',
      description: '从下到上的流程图',
      code: '''graph BT
    A[数据层] --> B[业务层]
    B --> C[表现层]
    C --> D[用户]''',
    ),
    MermaidExample(
      title: '流程图 (RL)',
      description: '从右到左的流程图',
      code: '''graph RL
    A[结果] --> B[计算]
    B --> C[输入]''',
    ),
    MermaidExample(
      title: '复杂流程图',
      description: '包含多分支和循环的流程图',
      code: '''graph TD
    Start[开始] --> Input[输入数据]
    Input --> Validate{数据有效?}
    Validate -->|是| Process[处理数据]
    Validate -->|否| Error[显示错误]
    Error --> Input
    Process --> Save{保存成功?}
    Save -->|是| Success[成功]
    Save -->|否| Retry{重试?}
    Retry -->|是| Process
    Retry -->|否| Fail[失败]
    Success --> End[结束]
    Fail --> End''',
    ),
    MermaidExample(
      title: '节点形状',
      description: '展示不同的节点形状',
      code: '''graph LR
    A[矩形] --> B(圆角矩形)
    B --> C{菱形}
    C --> D((圆形))
    D --> E>标签]
    E --> F[[子程序]]''',
    ),
    MermaidExample(
      title: '带样式的流程图',
      description: '包含子图的流程图',
      code: '''flowchart TD
    subgraph Frontend
        A[React] --> B[Vue]
        B --> C[Angular]
    end
    subgraph Backend
        D[Node.js] --> E[Python]
        E --> F[Go]
    end
    Frontend --> Backend''',
    ),

    // Sequence diagram examples
    MermaidExample(
      title: '基础时序图',
      description: '简单的消息交互',
      code: '''sequenceDiagram
    Alice->>Bob: Hello Bob
    Bob->>Alice: Hi Alice
    Alice->>Bob: How are you?
    Bob->>Alice: I am fine''',
    ),
    MermaidExample(
      title: '时序图 - 多参与者',
      description: '多个参与者之间的交互',
      code: '''sequenceDiagram
    participant Client
    participant Server
    participant Database
    Client->>Server: 请求数据
    Server->>Database: 查询
    Database-->>Server: 返回结果
    Server-->>Client: 响应数据''',
    ),
    MermaidExample(
      title: 'API 调用流程',
      description: 'REST API 调用示例',
      code: '''sequenceDiagram
    participant User
    participant App
    participant API
    participant DB
    User->>App: 点击按钮
    App->>API: GET /users
    API->>DB: SELECT * FROM users
    DB-->>API: 用户列表
    API-->>App: JSON 响应
    App-->>User: 显示数据''',
    ),
    MermaidExample(
      title: '登录流程',
      description: '用户登录认证流程',
      code: '''sequenceDiagram
    participant U as 用户
    participant C as 客户端
    participant S as 服务器
    participant D as 数据库
    U->>C: 输入账号密码
    C->>S: POST /login
    S->>D: 验证用户
    D-->>S: 用户信息
    S-->>C: JWT Token
    C-->>U: 登录成功''',
    ),

    // Pie chart examples
    MermaidExample(
      title: '饼图 - 基础',
      description: '展示基本的饼图数据',
      code: '''pie
    title 最受欢迎的宠物
    "狗" : 386
    "猫" : 250
    "鸟" : 85
    "鱼" : 65
    "兔子" : 45''',
    ),
    MermaidExample(
      title: '饼图 - 市场份额',
      description: '展示市场份额分布',
      code: '''pie showData
    title 移动操作系统市场份额
    "Android" : 72
    "iOS" : 27
    "其他" : 1''',
    ),
    MermaidExample(
      title: '饼图 - 编程语言',
      description: '开发者最常用的编程语言',
      code: '''pie
    title 最常用的编程语言 2024
    "JavaScript" : 65
    "Python" : 48
    "TypeScript" : 35
    "Java" : 33
    "C#" : 28
    "C++" : 23''',
    ),
    MermaidExample(
      title: '饼图 - 项目时间分配',
      description: '软件开发项目时间分配',
      code: '''pie showData
    title 项目时间分配
    "编码" : 40
    "测试" : 20
    "会议" : 15
    "文档" : 10
    "代码审查" : 10
    "其他" : 5''',
    ),

    // Gantt chart examples
    MermaidExample(
      title: '甘特图 - 基础',
      description: '简单的项目时间线',
      code: '''gantt
    title 项目开发计划
    dateFormat YYYY-MM-DD
    Task A :a1, 2024-01-01, 30d
    Task B :a2, 2024-01-15, 20d
    Task C :a3, 2024-02-01, 15d''',
    ),
    MermaidExample(
      title: '甘特图 - 带分组',
      description: '按阶段分组的项目计划',
      code: '''gantt
    title 软件开发生命周期
    dateFormat YYYY-MM-DD

    section 规划阶段
        需求分析 :done, req, 2024-01-01, 14d
        系统设计 :done, des, after req, 10d

    section 开发阶段
        前端开发 :active, front, 2024-01-25, 30d
        后端开发 :active, back, 2024-01-20, 35d
        API集成 :crit, api, after back, 10d

    section 测试阶段
        单元测试 :test1, 2024-02-25, 10d
        集成测试 :test2, after test1, 7d''',
    ),
    MermaidExample(
      title: '甘特图 - 任务状态',
      description: '展示不同任务状态',
      code: '''gantt
    title 任务状态示例
    dateFormat YYYY-MM-DD

    section 完成
        已完成任务1 :done, d1, 2024-01-01, 10d
        已完成任务2 :done, d2, after d1, 5d

    section 进行中
        当前任务 :active, a1, 2024-01-16, 15d

    section 关键
        关键任务 :crit, c1, 2024-02-01, 10d

    section 里程碑
        版本发布 :milestone, m1, 2024-02-11, 0d''',
    ),
    MermaidExample(
      title: '甘特图 - 产品发布',
      description: '产品发布计划',
      code: '''gantt
    title 产品发布计划 v2.0
    dateFormat YYYY-MM-DD

    section 准备
        市场调研 :done, mr, 2024-01-01, 14d
        竞品分析 :done, ca, 2024-01-08, 10d
        需求确认 :done, rc, after ca, 5d

    section 设计
        UI设计 :active, ui, 2024-01-23, 20d
        UX优化 :ux, after ui, 10d

    section 开发
        核心功能 :crit, core, 2024-02-12, 25d
        新增特性 :feat, after core, 15d
        性能优化 :perf, after feat, 10d

    section 发布
        Beta测试 :beta, 2024-04-02, 14d
        正式发布 :milestone, rel, 2024-04-16, 0d''',
    ),

    // Timeline examples
    MermaidExample(
      title: '时间线 - 基础',
      description: '社交媒体平台发展历史',
      code: '''timeline
    title History of Social Media Platform
    2002 : LinkedIn
    2004 : Facebook
         : Google
    2005 : Youtube
    2006 : Twitter''',
    ),
    MermaidExample(
      title: '时间线 - 编程语言',
      description: '编程语言发展历史',
      code: '''timeline
    title History of Programming Languages
    1950s : Fortran
          : LISP
    1960s : COBOL
          : BASIC
    1970s : C
          : SQL
    1980s : C++
          : Perl
    1990s : Python
          : Java
          : JavaScript
    2000s : C#
          : Go
    2010s : Rust
          : Swift
          : Kotlin''',
    ),
    MermaidExample(
      title: '时间线 - 技术发展',
      description: '计算机技术发展历程',
      code: '''timeline
    title Technology Evolution
    1970-1980 : Personal Computing Era
              : Apple II
              : IBM PC
    1990-2000 : Internet Revolution
              : World Wide Web
              : Google Founded
    2000-2010 : Mobile Era
              : iPhone Launch
              : Android Release
    2010-2020 : Cloud Computing
              : AWS Dominance
              : AI Breakthrough''',
    ),
    MermaidExample(
      title: '时间线 - 产品路线图',
      description: '产品发布时间线',
      code: '''timeline
    title Product Roadmap 2024
    Q1 2024 : Feature A Release
            : User Authentication
    Q2 2024 : Feature B Release
            : Payment Integration
    Q3 2024 : Feature C Release
            : Mobile App Launch
    Q4 2024 : Feature D Release
            : AI Assistant''',
    ),
    MermaidExample(
      title: '时间线 - 公司发展',
      description: '公司里程碑',
      code: '''timeline
    title Company Milestones
    2015 : Company Founded
         : First Product Launch
    2017 : Series A Funding
         : Team Expansion
    2019 : Series B Funding
         : International Expansion
    2021 : IPO
         : 1000+ Employees
    2023 : Acquisition
         : Market Leader''',
    ),

    // Kanban examples
    MermaidExample(
      title: '看板 - 基础',
      description: '简单的任务看板',
      code: '''kanban
  title 我的任务看板

  todo[待办事项]
    task1[学习 Flutter]
    task2[完成项目文档]

  doing[进行中]
    task3[开发新功能]

  done[已完成]
    task4[代码审查]''',
    ),
    MermaidExample(
      title: '看板 - 带优先级',
      description: '展示任务优先级的看板',
      code: '''kanban
  title 项目任务看板

  backlog[需求池]
    task1[数据库优化] @{ priority: "Low" }
    task2[性能测试] @{ priority: "Very Low" }

  todo[待开始]
    task3[用户认证] @{ priority: "Very High" }
    task4[API设计] @{ priority: "High" }

  doing[开发中]
    task5[登录界面] @{ priority: "High" }

  done[完成]
    task6[环境搭建] @{ priority: "Normal" }''',
    ),
    MermaidExample(
      title: '看板 - 团队协作',
      description: '分配负责人的团队看板',
      code: '''kanban
  title 团队协作看板

  todo[待办]
    task1[需求分析] @{ assigned: "张三" }
    task2[UI设计] @{ assigned: "李四" }

  doing[进行中]
    task3[前端开发] @{ assigned: "王五", priority: "High" }
    task4[后端开发] @{ assigned: "赵六", priority: "High" }

  review[代码审查]
    task5[功能A] @{ assigned: "张三", priority: "Normal" }

  done[已完成]
    task6[项目初始化] @{ assigned: "李四" }''',
    ),
    MermaidExample(
      title: '看板 - WIP 限制',
      description: '设置在制品限制的看板',
      code: '''kanban
  title WIP 限制示例

  backlog[需求池] wip:10
    task1[需求A]
    task2[需求B]
    task3[需求C]

  todo[待开始] wip:5
    task4[任务1]
    task5[任务2]

  doing[开发中] wip:3
    task6[开发任务A]
    task7[开发任务B]
    task8[开发任务C]
    task9[开发任务D]

  review[审查] wip:2
    task10[审查1]

  done[完成]
    task11[已完成任务]''',
    ),
    MermaidExample(
      title: '看板 - 完整示例',
      description: '包含所有功能的看板',
      code: '''---
config:
  kanban:
    ticketBaseUrl: 'https://jira.example.com/browse/#TICKET#'
---
kanban
  title 产品开发看板

  backlog[产品待办] wip:10
    task1[用户认证系统] @{ assigned: "张三", ticket: "PROJ-101", priority: "High" }
    task2[数据库设计] @{ assigned: "李四", ticket: "PROJ-102", priority: "Normal" }
    task3[API文档] @{ assigned: "王五", priority: "Low" }

  todo[准备开始] wip:5
    task4[登录界面] @{ assigned: "赵六", priority: "Very High" }
    task5[注册流程] @{ assigned: "张三", ticket: "PROJ-105", priority: "High" }

  doing[开发中] wip:3
    task6[用户仪表板] @{ assigned: "李四", ticket: "PROJ-104", priority: "High" }
    task7[权限管理] @{ assigned: "王五", ticket: "PROJ-106", priority: "Normal" }

  review[代码审查] wip:2
    task8[支付集成] @{ assigned: "赵六", ticket: "PROJ-108", priority: "Very High" }

  done[已完成]
    task9[CI/CD配置] @{ assigned: "张三", ticket: "PROJ-103" }
    task10[环境搭建] @{ assigned: "李四" }''',
    ),
    MermaidExample(
      title: '看板 - 敏捷开发',
      description: 'Scrum 敏捷开发看板',
      code: '''kanban
  title Sprint 23 - 敏捷开发

  sprint_backlog[Sprint待办] wip:8
    story1[用户故事1] @{ assigned: "Alice", priority: "Very High" }
    story2[用户故事2] @{ assigned: "Bob", priority: "High" }
    story3[用户故事3] @{ assigned: "Carol", priority: "Normal" }

  in_progress[进行中] wip:4
    story4[开发功能A] @{ assigned: "Alice", priority: "Very High" }
    story5[开发功能B] @{ assigned: "Bob", priority: "High" }

  testing[测试中] wip:3
    story6[测试功能C] @{ assigned: "David", priority: "High" }

  done[本Sprint完成]
    story7[功能D已上线] @{ assigned: "Carol" }
    story8[Bug修复] @{ assigned: "Alice" }''',
    ),

    // Mixed/Complex examples
    MermaidExample(
      title: 'Git 工作流',
      description: 'Git 分支管理流程',
      code: '''graph LR
    A[main] --> B[develop]
    B --> C[feature_a]
    B --> D[feature_b]
    C --> E[PR]
    D --> E
    E --> F[Review]
    F --> G{通过}
    G -->|是| H[合并]
    G -->|否| C
    H --> I[发布]
    I --> A''',
    ),
    MermaidExample(
      title: 'CI/CD 流程',
      description: '持续集成/持续部署流程',
      code: '''graph TD
    A[提交] --> B[CI]
    B --> C[检查]
    C --> D[测试]
    D --> E[构建]
    E --> F{通过}
    F -->|是| G[部署测试]
    F -->|否| H[通知]
    G --> I[集成测试]
    I --> J{上线}
    J -->|是| K[部署生产]
    J -->|否| L[审批]''',
    ),
    MermaidExample(
      title: '状态机',
      description: '订单状态流转',
      code: '''graph LR
    A((待支付)) --> B((已支付))
    B --> C((已发货))
    C --> D((已收货))
    D --> E((已完成))
    A --> F((已取消))
    B --> G((退款中))
    G --> F''',
    ),
    MermaidExample(
      title: '雷达图 - 技能评估',
      description: '展示多维度技能水平对比',
      code: '''radar-beta
    title 技能评估
    axis 编程, 设计, 沟通, 管理, 创新
    curve 张三{5, 3, 4, 2, 4}
    curve 李四{3, 5, 3, 4, 3}
    showLegend true
    max 5
    graticule polygon
    ticks 5''',
    ),
    MermaidExample(
      title: '雷达图 - 产品特性',
      description: '产品竞争力分析',
      code: '''radar-beta
    title 产品竞争力分析
    axis 性能["Performance"], 易用性["Usability"], 稳定性["Stability"], 扩展性["Scalability"], 安全性["Security"]
    curve 产品A{90, 85, 95, 70, 88}
    curve 产品B{85, 90, 80, 85, 75}
    curve 竞品C{70, 75, 85, 90, 80}
    showLegend true
    max 100
    graticule circle
    ticks 5''',
    ),
    MermaidExample(
      title: '雷达图 - 简单圆形',
      description: '使用圆形网格的雷达图',
      code: '''radar-beta
    title 能力雷达
    axis A, B, C, D, E, F
    curve data1{1, 2, 3, 4, 5, 4}
    curve data2{5, 4, 3, 2, 1, 2}
    graticule circle
    max 5''',
    ),

    // XY Chart examples
    MermaidExample(
      title: 'XY图 - 柱状图',
      description: '季度销售数据柱状图',
      code: '''xychart-beta
    title "季度销售额"
    x-axis [Q1, Q2, Q3, Q4]
    y-axis "销售额(万)" 0 --> 100
    bar [23, 45, 67, 89]''',
    ),
    MermaidExample(
      title: 'XY图 - 柱状+折线',
      description: '柱状图与折线图混合展示',
      code: '''xychart-beta
    title "收入与利润趋势"
    x-axis [Jan, Feb, Mar, Apr, May, Jun]
    y-axis "金额(万)" 0 --> 200
    bar [120, 135, 148, 160, 175, 190]
    line [30, 38, 42, 55, 60, 72]''',
    ),
    MermaidExample(
      title: 'XY图 - 多系列',
      description: '多组数据对比',
      code: '''xychart-beta
    title "产品销量对比"
    x-axis [一月, 二月, 三月, 四月, 五月]
    bar [50, 60, 70, 80, 90]
    bar [40, 55, 65, 75, 85]
    line [45, 58, 68, 78, 88]''',
    ),
    MermaidExample(
      title: 'XY图 - 年度营收',
      description: '12个月营收柱状图+趋势线',
      code: '''xychart-beta
    title "Sales Revenue"
    x-axis [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]
    y-axis "Revenue (in \$)" 4000 --> 11000
    bar [5000, 6000, 7500, 8200, 9500, 10500, 11000, 10200, 9200, 8500, 7000, 6000]
    line [5000, 6000, 7500, 8200, 9500, 10500, 11000, 10200, 9200, 8500, 7000, 6000]''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final example = _examples[_selectedIndex];
    final style = _isDarkMode ? MermaidStyle.dark() : const MermaidStyle();

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF0D1117) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xFF161B22) : null,
        foregroundColor: _isDarkMode ? Colors.white : null,
        title: const Text('Mermaid 图表测试'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            tooltip: '切换主题',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: _isDarkMode ? const Color(0xFF161B22) : null,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isDarkMode
                      ? [const Color(0xFF1F6FEB), const Color(0xFF238636)]
                      : [Colors.blue, Colors.green],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.schema, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Mermaid 图表',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_examples.length} 个示例',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Flowchart section
            _buildSectionHeader('流程图 (Flowchart)', _isDarkMode),
            ..._buildExampleTiles(0, 7),
            const Divider(),
            // Sequence diagram section
            _buildSectionHeader('时序图 (Sequence)', _isDarkMode),
            ..._buildExampleTiles(7, 11),
            const Divider(),
            // Pie chart section
            _buildSectionHeader('饼图 (Pie Chart)', _isDarkMode),
            ..._buildExampleTiles(11, 15),
            const Divider(),
            // Gantt chart section
            _buildSectionHeader('甘特图 (Gantt Chart)', _isDarkMode),
            ..._buildExampleTiles(15, 19),
            const Divider(),
            // Timeline section
            _buildSectionHeader('时间线 (Timeline)', _isDarkMode),
            ..._buildExampleTiles(19, 24),
            const Divider(),
            // Kanban section
            _buildSectionHeader('看板 (Kanban)', _isDarkMode),
            ..._buildExampleTiles(24, 30),
            const Divider(),
            // Radar chart section
            _buildSectionHeader('雷达图 (Radar Chart)', _isDarkMode),
            ..._buildExampleTiles(30, 33),
            const Divider(),
            // XY chart section
            _buildSectionHeader('XY图 (XY Chart)', _isDarkMode),
            ..._buildExampleTiles(33, 37),
            const Divider(),
            // Complex examples
            _buildSectionHeader('复杂示例', _isDarkMode),
            ..._buildExampleTiles(37, _examples.length),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF161B22) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: _isDarkMode
                        ? const Color(0xFF30363D)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schema,
                        color: _isDarkMode ? Colors.blue[300] : Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          example.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? const Color(0xFF238636)
                              : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_selectedIndex + 1}/${_examples.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    example.description,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Diagram display - 使用固定高度，宽度占满屏幕
            Container(
              height: 600, // 固定高度，足够显示复杂图表
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF0D1117) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isDarkMode
                      ? const Color(0xFF30363D)
                      : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveMermaidDiagram(
                  code: example.code,
                  style: style,
                  onNodeTap: (nodeId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('点击了节点: $nodeId'),
                        duration: const Duration(seconds: 1),
                        backgroundColor:
                            _isDarkMode ? const Color(0xFF161B22) : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Code display - 固定高度，宽度占满屏幕
            Container(
              height: 250,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF161B22) : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? const Color(0xFF21262D)
                          : Colors.grey[800],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.code,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Mermaid 代码',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            // Copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('代码已复制'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          tooltip: '复制代码',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        example.code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Navigation buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF161B22) : Colors.white,
          border: Border(
            top: BorderSide(
              color:
                  _isDarkMode ? const Color(0xFF30363D) : Colors.grey.shade300,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _selectedIndex > 0
                  ? () {
                      setState(() {
                        _selectedIndex--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('上一个'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isDarkMode ? const Color(0xFF21262D) : null,
                foregroundColor: _isDarkMode ? Colors.white : null,
              ),
            ),
            Text(
              '${_selectedIndex + 1} / ${_examples.length}',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _selectedIndex < _examples.length - 1
                  ? () {
                      setState(() {
                        _selectedIndex++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('下一个'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isDarkMode ? const Color(0xFF21262D) : null,
                foregroundColor: _isDarkMode ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white54 : Colors.grey,
        ),
      ),
    );
  }

  List<Widget> _buildExampleTiles(int start, int end) {
    return List.generate(end - start, (i) {
      final index = start + i;
      return ListTile(
        leading: Icon(
          _getIconForIndex(index),
          color: _selectedIndex == index
              ? (_isDarkMode ? Colors.blue[300] : Colors.blue)
              : (_isDarkMode ? Colors.white70 : null),
        ),
        title: Text(
          _examples[index].title,
          style: TextStyle(
            fontWeight:
                _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
            color: _isDarkMode ? Colors.white : null,
            fontSize: 14,
          ),
        ),
        selected: _selectedIndex == index,
        selectedTileColor:
            _isDarkMode ? const Color(0xFF21262D) : Colors.blue.withValues(alpha: 0.1),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
      );
    });
  }

  IconData _getIconForIndex(int index) {
    if (index < 7) {
      return Icons.account_tree; // Flowchart
    } else if (index < 11) {
      return Icons.swap_horiz; // Sequence
    } else if (index < 15) {
      return Icons.pie_chart; // Pie chart
    } else if (index < 19) {
      return Icons.view_timeline; // Gantt chart
    } else if (index < 24) {
      return Icons.timeline; // Timeline
    } else if (index < 30) {
      return Icons.view_kanban; // Kanban board
    } else if (index < 33) {
      return Icons.radar; // Radar chart
    } else if (index < 37) {
      return Icons.bar_chart; // XY chart
    } else {
      return Icons.hub; // Complex
    }
  }
}

/// Model for a Mermaid example
class MermaidExample {
  const MermaidExample({
    required this.title,
    required this.description,
    required this.code,
  });

  final String title;
  final String description;
  final String code;
}
