# holiday-cn

[![Build Status](https://github.com/xxl6097/holiday-cn/workflows/CI/badge.svg)](https://github.com/xxl6097/holiday-cn/actions)
[![Release](https://img.shields.io/github/release/xxl6097/holiday-cn.svg)](https://github.com/xxl6097/holiday-cn/releases/latest)
[![CalVer](https://img.shields.io/badge/calver-YYYY.0M.0D-22bfda.svg)](http://calver.org)
[![JSDelivr](https://data.jsdelivr.com/v1/package/gh/xxl6097/holiday-cn/badge?style=rounded)](https://www.jsdelivr.com/package/gh/xxl6097/holiday-cn)
![Maintenance](https://img.shields.io/maintenance/yes/2026.svg)

中国法定节假日数据 自动每日抓取国务院公告

- [x] 提供 JSON 格式节假日数据
- [x] 提供 ICS 日历订阅
- [x] CI 自动更新（默认维护最近 5 年以上数据）
- [x] 数据变化时自动发布新版本 ( `Watch` - `Release only` 以获取邮件提醒! )
- [x] [发布页面]提供 JSON 打包下载

## 数据格式

[JSON Schema](./schema.json)

```TypeScript
interface Holidays {
  /** 完整年份, 整数。*/
  year: number;
  /** 所用国务院文件网址列表 */
  papers: string[];
  days: {
    /**
     * 节假日名称；
     * 补班日标注为 `补班日（原节日名）`，如 `补班日（春节）`。
     */
    name: string;
    /** 日期, ISO 8601 格式 */
    date: string;
    /** 是否为休息日 */
    isOffDay: boolean;
  }[]
}
```

示例：

```json
{
    "year": 2026,
    "papers": ["https://www.gov.cn/zhengce/zhengceku/202511/content_7047091.htm"],
    "days": [
        { "name": "元旦", "date": "2026-01-01", "isOffDay": true },
        { "name": "补班日（元旦）", "date": "2026-01-04", "isOffDay": false }
    ]
}
```

## 本地运行

需要 Python 3.12+，首次运行会自动创建 `.venv` 并安装依赖。

```bash
./run.sh                # 更新最近 6 年（今年及之前 4 年 + 次年）
./run.sh all            # 更新 2007 年至今全部数据
./run.sh fetch 2026     # 抓取指定年份并打印 JSON
./run.sh test           # 运行测试
./run.sh lint           # 检查代码格式
./run.sh format         # 格式化代码
./run.sh release        # 更新数据并在有变化时发布 Release
```

生成的文件统一存储在 `json/` 目录：

- `json/{年份}.json`：对应年份的节假日数据
- `json/{年份}.ics`：对应年份的日历文件
- `json/holiday-cn.ics`：最近 4 年至次年的日历文件

## 注意事项

- 年份是按照国务院文件标题年份而不是日期年份，12 月份的日期可能会被下一年的文件影响，因此应检查两个文件。

- `与周末连休` 的周末不是法定节假日，数据里不会包含，见[《全国年节及纪念日放假办法》](https://www.gov.cn/zhengce/content/202411/content_6986380.htm) [#213](https://github.com/NateScarlet/holiday-cn/issues/213#issuecomment-1869546011) [#221](https://github.com/NateScarlet/holiday-cn/issues/221)

- 补班日可通过 `name` 是否以 `补班日（` 开头识别，也可直接判断 `isOffDay` 是否为 `false`。

## 通过互联网使用

提示：任何第三方服务都可能故障或停止服务，如果稳定性要求高请自己搭建静态文件服务。

JSON 和 ICS 文件均位于仓库 `json/` 目录。

数据地址格式:

`https://raw.githubusercontent.com/xxl6097/holiday-cn/main/json/{年份}.json`

或使用 JSDelivr：

`https://cdn.jsdelivr.net/gh/xxl6097/holiday-cn@main/json/{年份}.json`

`https://fastly.jsdelivr.net/gh/xxl6097/holiday-cn@main/json/{年份}.json`

也可尝试使用 [ghproxy](https://github.com/hunshcn/gh-proxy) 或其他 Github 加速：

`https://{ghproxy服务}/https://raw.githubusercontent.com/xxl6097/holiday-cn/main/json/{年份}.json`

## ICalendar 订阅

`json/{年份}.ics` 为对应年份的节假日，`json/holiday-cn.ics` 为最近 4 年至次年的节假日。

订阅地址示例：

`https://raw.githubusercontent.com/xxl6097/holiday-cn/main/json/{年份}.ics`

`https://raw.githubusercontent.com/xxl6097/holiday-cn/main/json/holiday-cn.ics`

也可使用 JSDelivr：

`https://cdn.jsdelivr.net/gh/xxl6097/holiday-cn@main/json/{年份}.ics`

`https://cdn.jsdelivr.net/gh/xxl6097/holiday-cn@main/json/holiday-cn.ics`

感谢 @retanoj 的 ics 格式转换实现

## 作为 git 子模块使用

参见 [Git 工具 - 子模块](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E5%AD%90%E6%A8%A1%E5%9D%97)

[发布页面]: https://github.com/xxl6097/holiday-cn/releases
