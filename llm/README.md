# LLM Proxy

> 面向多上游、多协议、多认证形态的统一 LLM 接入层。

LLM_Proxy 将模型服务、鉴权方式、协议转换和后台运维收敛到同一个 Flask + gevent 服务中，对下游提供 OpenAI Chat Completions、OpenAI Responses 和 Claude Messages 兼容接口，支持常规 Provider 代理和 Codex / Claude OAuth 账号文件代理，内置 Provider 管理、Auth Group 凭据池、白名单控制、日志统计、请求调试和 Hook 扩展能力。

客户端只需记住一个地址；服务端集中维护模型路由、Key 池、OAuth 账号、访问控制和统计信息。

本项目基于 [VonSdite/LLM_Proxy](https://github.com/VonSdite/LLM_Proxy) 进行包装hook.

### 环境要求

- Python >= 3.12
- pip

## 安装使用指导

请参考：[Wiki https://clouddevops.huawei.com/domains/1499/wiki/6132/WIKI2026020600363](https://clouddevops.huawei.com/domains/1499/wiki/6132/WIKI2026020600363)


## 脚本说明

项目提供以下快捷脚本，双击即可运行（仅支持 Windows）：

| 脚本 | 用途 |
|------|------|
| `LP_init.bat` | 初始化：环境检查、依赖安装、域账号验证、区域选择、模型同步 |
| `LP_update.bat` | 自动更新：从 OneBox 下载最新版本覆盖更新 |
| `LP_run.bat` | 启动服务：启动 LLM Proxy 后台服务（Flask + gevent），支持透传 `--config` 等参数 |
| `LP_get_models.bat` | 查询模型：查询当前可用的 Codemate 模型列表 |
| `scripts/LP_package.bat` | 打包：按 pyproject.toml 版本号 + 时间戳打包为 zip |

## 接口概览

| 路由 | 说明 | 下游协议 | 支持模型来源 |
| --- | --- | --- | --- |
| `POST /v1/chat/completions` | OpenAI Chat Completions 兼容接口 | `openai_chat` | Provider、Codex / Claude OAuth |
| `POST /v1/responses` | OpenAI Responses / Codex 风格接口 | `openai_responses` | Provider、Codex / Claude OAuth |
| `POST /v1/messages` | Claude Messages 兼容接口 | `claude_chat` | Provider、Codex / Claude OAuth |
| `GET /v1/models` | 返回当前已注册模型列表 | 不适用 | Provider、Codex / Claude OAuth |

## 配置介绍

### 顶层配置

- `server.host`：监听地址，默认 `127.0.0.1`
- `server.port`：监听端口，默认 `31943`
- `chat.whitelist_enabled`：是否启用聊天白名单
- `admin.username` / `admin.password`：配置后开启后台登录功能
- `auth_groups`：凭据池配置
- `providers`：上游模型入口配置
- `database.path`：SQLite 数据库路径，默认 `data/requests.db`
- `logging.path`：日志目录，默认 `logs`
- `logging.level`：日志级别，例如 `INFO`、`DEBUG`
- `logging.llm_request_debug_enabled`：是否把请求与响应写入 trace 日志
- `oauth.enabled`：是否在后台导航显示 OAuth 管理入口
- `oauth.proxy`：OAuth 请求使用的代理地址
- `oauth.verify_ssl`：OAuth 网络请求是否校验证书，默认 `false`

### `providers[]` 字段说明

- `name`：Provider 名称，必须唯一
- `enabled`：是否启用，默认 `true`
- `api`：上游接口地址
- `source_format`：上游真实协议格式（`openai_chat` / `openai_responses` / `claude_chat`）
- `api_key`：单 Provider 凭据
- `auth_group`：凭据池名称，和 `api_key` 二选一
- `proxy`：上游代理地址
- `timeout_seconds`：上游请求超时，默认 `1200`
- `max_retries`：失败重试次数，默认 `3`
- `verify_ssl`：是否校验证书
- `model_list`：暴露的模型列表
- `hook`：Hook 文件路径（相对 `hooks/` 目录）

### `authGroups[]` 字段说明

- `name`：认证组名称，必须唯一
- `strategy`：当前支持 `least_inflight`
- `cooldown_seconds_on_429`：组级默认冷却时间
- `entries[]`：凭据条目列表

`entries[]` 支持：`id`、`enabled`、`headers`、`max_concurrency`、`cooldown_seconds_on_429`、`request_quota_per_minute` / `request_quota_per_day`、`token_quota_per_minute` / `token_quota_per_day`

### 环境变量（.env）

| 变量名 | 说明 | 必填 |
|--------|------|------|
| `USER_ID` | 华为域账号 | 是 |
| `USER_PWD` | 域密码 | 是 |

## 数据与目录

| 路径 | 说明 |
|------|------|
| `config.yaml` | 主配置文件 |
| `config.sample.yaml` | 配置样例 |
| `.env` | 凭证配置（不提交到版本库） |
| `.env.example` | 凭证模板 |
| `hooks/` | Hook 扩展目录 |
| `scripts/` | 工具脚本（init、update、get_models、package、download） |
| `data/oauth/codex/` | Codex OAuth 认证目录 |
| `data/oauth/claude/` | Claude OAuth 认证目录 |
| `data/requests.db` | SQLite 默认库 |
| `logs/` | 日志目录 |
| `docs/architecture-4plus1.md` | 架构文档 |

## Hook 扩展

Hook 文件需要导出一个名为 `Hook` 的类，可选扩展点：

- `header_hook(ctx, headers) -> headers` — 注入 Header / Cookie / Token
- `request_guard(ctx, body) -> body` — 请求字段补充、删改和护栏
- `response_guard(ctx, body) -> body` — 成功响应清洗和改写

完整说明见 [hooks/example_hook.py](hooks/example_hook.py) 和 [config.sample.yaml](config.sample.yaml)。


## 如何反馈问题

1. **CodeHub Issue**：在项目 CodeHub 仓库提交 Issue，描述问题现象、复现步骤和环境信息
2. **内部沟通**：通过 WeLink 联系项目维护者
3. **反馈内容建议包含**：
   - 问题描述与预期行为
   - 复现步骤
   - 相关日志（`logs/app.log`、`logs/access.log`）
   - 运行环境（Python 版本、操作系统、网络区域）

## 如何贡献代码

### 贡献流程

1. **Fork 仓库**：在 CodeHub 上 Fork 本项目到你的命名空间
2. **创建分支**：从 `master` 创建特性分支
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **开发与测试**：在特性分支上完成开发和本地测试
4. **提交代码**：提交信息请清晰描述变更内容，格式见下方 [Commit 信息规范](#commit-信息规范)
   ```bash
   git commit -m "[feat] 简要描述本次变更"
   ```
5. **推送分支**：
   ```bash
   git push origin feature/your-feature-name
   ```
6. **提交 Merge Request**：在 CodeHub 上向 `master` 分支提交 MR，填写变更说明

### 代码规范

- 遵循项目已有的代码风格和命名约定
- 使用 [Ruff](https://docs.astral.sh/ruff/) 进行代码检查和格式化（配置见 `pyproject.toml`）
- 目标 Python 版本 >= 3.12

### Commit 信息规范

提交信息使用中文，统一采用 `[类型] 简要描述` 的方括号格式（与仓库提交历史保持一致），示例：

```
[feat] 新增 uv 环境自动探测
[fix] 修复 pip 静默失败不报错的问题
[sync] 同步外部版本，支持 hook 注入 fetch 模型
```

类型取值：

| 类型 | 含义 |
|------|------|
| `feat` | 新功能、新特性 |
| `fix` | 缺陷修复 |
| `sync` | 同步外部版本或上游变更 |
| `refactor` | 重构，不改变外部行为 |
| `docs` | 文档更新 |
| `chore` | 构建、脚本、依赖等杂项维护 |

要求：

- 描述简明扼要，说明「做了什么」，必要时用顿号分隔多个点
- 单次提交聚焦单一主题，混合多个无关改动时拆分为多次提交
- 涉及破坏性变更时，在描述开头标注 `[break]`，例如 `[feat][break] 重命名配置字段`


### 注意事项

- **敏感信息**：`.env`、`data/`、`logs/` 等已在 `.gitignore` 中排除，请勿提交
- **向后兼容**：修改配置格式或接口行为时，请考虑已有用户的升级路径
- **版本更新**：后续通过 `git pull` 或下载项目压缩包更新

## 合规说明

Hook 和认证扩展能力的设计目标是支持合法授权前提下的协议兼容与私有集成。请仅在拥有访问权限的前提下使用相关能力，并遵守上游服务的产品条款、访问策略和安全要求。
