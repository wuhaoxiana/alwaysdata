# wuhaoxian

个人自用的一键部署脚本：在 alwaysdata 免费空间上跑一个常驻服务，客户端接入
`https://<账号>.alwaysdata.net`，出口是 alwaysdata 的法国 IP。

> [!WARNING]
> 免费空间禁止代理类用途，账号随时可能被平台停用。这是个人自用改版，风险自负。

## 文件

| 文件 | 作用 |
| --- | --- |
| `install.sh` / `install.cmd` | 本机执行：把 `start.sh`、`setup.sh` 传到服务器并安装（macOS/Linux、Windows） |
| `setup.sh` | 服务器端执行：安装/更新运行时、生成密钥、输出订阅内容 |
| `start.sh` | 站点入口：由平台的 User program 调用，生成配置并启动 |
| `link.txt` | 服务器端生成：base64 形式的接入链接 |

## 快速开始

需要：一个 alwaysdata 账号，本机有 `ssh`（macOS / Linux / Windows 10+ 自带）。

**1.** 面板里开启 SSH：*Remote access → SSH*。

**2.** 本机在这个目录里执行：

```bash
./install.sh <账号>@ssh-<账号>.alwaysdata.net
```

```bat
:: Windows 10/11
install.cmd <账号>@ssh-<账号>.alwaysdata.net
```

**3.** 面板里把站点指向入口脚本：*Web → Sites* → 编辑 `<账号>.alwaysdata.net`：

| 字段 | 值 |
| --- | --- |
| Type | **User program** |
| Command | `/home/<账号>/start.sh` |
| Working directory | `/home/<账号>` |

Command 直接写脚本路径，别写成 `sh start.sh`：脚本用了 bash 的 `${var//a/b}` 和 `exec -a`，
`dash` 会报 `exec: -a: not found`。

**4.** 取接入链接（服务器上存的是 base64）：

```bash
ssh <账号>@ssh-<账号>.alwaysdata.net bash setup.sh --plain
```

**5.** 导入客户端。需要 Xray 内核的客户端：v2rayNG、Happ、v2RayTun、Streisand。

## 设计说明

- **外部名**：运行时二进制文件叫 `wuhaoxian`，进程名（argv[0]）也是 `wuhaoxian`
  （`exec -a wuhaoxian ./wuhaoxian …`）。用 `exec` 而不是管道，shell 会被直接替换，
  平台重启站点时不会留下孤儿进程占着端口。
- **配置不落盘**：配置模板以 base64 内嵌在 `start.sh` 的 `T='…'` 一行，运行时解码并替换
  占位符 `@I@ @P@ @U@ @R@`，再用 bash here-string 从 stdin 喂给运行时。
  home 目录里不会出现 `config.json`。
  看模板明文：`printf '%s' "$T" | base64 -d`（`T` 就是那一行的值）。
- **运行日志默认丢弃**（`secrets.env` 里 `QUIET=1`）。运行时会往 **stdout** 打一行
  `Xray <版本> (Xray, Penetrates Everything.)` 横幅，`loglevel` 改成 `none` 也压不掉，
  而且它的日志和报错都走 stdout，没法只丢横幅留报错，只能整个丢弃。
  要排查问题：把 `QUIET` 改成 `0`，重启站点，看面板里的站点日志。
  安装时的配置校验（`./start.sh --check`）不受影响，始终有输出。
- **接入链接**：以 base64 存在 `link.txt`，`bash setup.sh --plain` 打印明文。
  注意 base64 只是编码不是加密，谁拿到都能解开。
- **密钥**：`secrets.env` 里是 `UUID` 和 `XHTTP_PATH`。链接泄露了 → 删掉 `secrets.env`，
  重跑安装，重启站点，会得到新的 UUID / path / 链接。
- **平台限制**：alwaysdata 的转发会打断 `stream-up` / `stream-one`，所以链接里的 `mode`
  固定 `packet-up`；服务端配置用 `mode: auto` 两种都收。

## 已验证（用官方 v26.10.10 真二进制实测）

- `start.sh` 生成的配置通过 `xray run -test -c stdin:`（`Configuration OK.`）。
- 真实启动：进程 `exec` 后无子进程残留，端口正常监听。
- `exec -a wuhaoxian` 生效：`/proc/<pid>/cmdline` 与 `comm` 都是 `wuhaoxian`。
- 生成的接入链接与原始版本逐字符一致（base64 前后）。
- `setup.sh` 端到端：下载 → sha256 校验 → 解出成员 → 改名 → 校验配置 → 生成 `secrets.env`
  / `link.txt`；二次运行不重复下载，密钥与链接不变。

## 更新 / 卸载

**更新**：重跑安装，然后在面板里重启站点。会装上最新版运行时，密钥和链接不变。

**卸载**：面板里把站点类型改回去（或删掉站点），然后：

```bash
ssh <账号>@ssh-<账号>.alwaysdata.net "rm -f wuhaoxian setup.sh start.sh secrets.env link.txt"
```

## 其他

- 免费账号 **120 天不登录面板会被停用**，记得偶尔登一下。
- 真正决定会不会被平台盯上的是行为：别跑满 CPU、别长期大流量、别开高并发。
- `LICENSE` 保留原项目的 MIT 声明，未改动。
