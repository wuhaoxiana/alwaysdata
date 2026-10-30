<p align="center">
  <b>Your own VLESS proxy on free hosting in a single command. No VPS, no payment card.</b>
</p>

<p align="center">
  <a href="https://github.com/AppsGanin/alwaysdata-xray/stargazers"><img src="https://img.shields.io/github/stars/AppsGanin/alwaysdata-xray?style=for-the-badge&logo=github&color=FFD33D&labelColor=24292e" alt="Stars"></a>
  <a href="https://github.com/XTLS/Xray-core/releases"><img src="https://img.shields.io/github/v/release/XTLS/Xray-core?include_prereleases&style=for-the-badge&logo=github&label=Xray-core&color=6d28d9&labelColor=24292e" alt="Xray-core"></a>
  <img src="https://img.shields.io/badge/VLESS-XHTTP-8A2BE2?style=for-the-badge&labelColor=24292e" alt="VLESS over XHTTP">
  <a href="https://www.alwaysdata.com"><img src="https://img.shields.io/badge/alwaysdata-free%20plan-2ea44f?style=for-the-badge&labelColor=24292e" alt="alwaysdata free plan"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/AppsGanin/alwaysdata-xray?style=for-the-badge&color=22c55e" alt="License: MIT"></a>
</p>

<p align="center">
  <a href="#-quick-start">🚀 Quick start</a> &nbsp;·&nbsp; <a href="#-clients">📱 Clients</a> &nbsp;·&nbsp; <a href="#-faq">❓ FAQ</a> &nbsp;·&nbsp; <a href="#-support-the-project">💝 Support</a>
</p>

<p align="center">
  ⭐ <b>If the project helped you, give it a star! It's free and really keeps it going.</b>
</p>

A personal [Xray](https://github.com/XTLS/Xray-core) proxy (VLESS over XHTTP) on the free
[alwaysdata](https://www.alwaysdata.com) plan. Clients connect to `https://<account>.alwaysdata.net`,
traffic exits to the internet from a French alwaysdata IP.


## ✨ Features

- 💸 **Free:** runs on the alwaysdata free plan, no VPS to rent or maintain
- 🔒 **Real HTTPS:** alwaysdata serves the certificate for `<account>.alwaysdata.net`, Xray sits behind its proxy
- ⚡ **One command:** from macOS, Linux or Windows over one SSH connection (the password is asked once), or right on the server
- ✅ **Verified download:** the Xray archive is checked against the SHA-256 from its release
- 🔁 **Safe re-runs:** re-running the install updates Xray and the scripts, the UUID, path and link stay the same
- 🤫 **No access log:** Xray logs warnings only, connections are not recorded

## 🧭 How it works

```mermaid
flowchart LR
    C["📱 Client<br/>v2rayNG, Happ, …"] -- "VLESS + XHTTP<br/>HTTPS :443" --> P["alwaysdata<br/>HTTPS proxy"]
    P -- "HTTP<br/>$IP:$PORT" --> X["Xray<br/>started by start.sh"]
    X --> I["🌍 Internet<br/>French IP"]
```

The alwaysdata site runs `start.sh` as a *User program*. The script builds the Xray config from `secrets.env`
and the `IP` / `PORT` that alwaysdata assigns, then starts Xray.

## 🚀 Quick start

**You need:** an alwaysdata account and `ssh` on your computer (built into macOS, Linux and Windows 10/11).

**1. Enable SSH** in the alwaysdata panel: *Remote access → SSH*.

**2. Run the installer** from this folder (it also needs `tar`, built in as well):

```bash
# macOS / Linux
./install.sh <account>@ssh-<account>.alwaysdata.net
```

```bat
:: Windows 10/11
install.cmd <account>@ssh-<account>.alwaysdata.net
```

Or install right on the server, no need to download this repository. Log in with
`ssh <account>@ssh-<account>.alwaysdata.net` and run:

```bash
cd ~ && { [ ! -e wuhaoxian ] || mv wuhaoxian wuhaoxian.old; } && mkdir -p wuhaoxian && cd wuhaoxian && curl -fsSLO "https://raw.githubusercontent.com/wuhaoxiana/alwaysdata/main/{start,setup}.sh" && bash setup.sh
```

Either way, `start.sh` and `setup.sh` end up in `~/wuhaoxian`, the newest Xray is installed, the config is checked
and your link is printed as base64 (decode it with `base64 -d`):

```text
Configuration OK.
Site: User program, command /home/<account>/wuhaoxian/start.sh, working directory /home/<account>/wuhaoxian (restart the site after updates)
dmxlc3M6Ly8xMTExMTExMS0yMjIyLTMzMzMtNDQ0NC01NTU1NTU1NTU1NTVAZGVtby5hbHdheXNkYXRhLm5ldDo0NDM/ZW5jcnlwdGlvbj1ub25lJnNlY3VyaXR5PXRscyZzbmk9ZGVtby5hbHdheXNkYXRhLm5ldCZ0eXBlPXhodHRwJmhvc3Q9ZGVtby5hbHdheXNkYXRhLm5ldCZwYXRoPSUyRjExMTExMTExMjIyMjMzMzM0NDQ0NTU1NTU1NTU1NTU1Jm1vZGU9cGFja2V0LXVwI2RlbW8=
```

That base64 line decodes back to:

```text
vless://<uuid>@<account>.alwaysdata.net:443?encryption=none&security=tls&sni=<account>.alwaysdata.net&type=xhttp&host=<account>.alwaysdata.net&path=%2F<path>&mode=packet-up#<account>
```

**3. Point the site at Xray.** In the panel: *Web → Sites* → edit `<account>.alwaysdata.net`:

| Field             | Value                                |
| ----------------- | ------------------------------------ |
| Type              | **User program**                     |
| Command           | `/home/<account>/wuhaoxian/start.sh` |
| Working directory | `/home/<account>/wuhaoxian`          |

**4. Import the link** into your client: it is base64-encoded, so decode it first (`base64 -d` on `cache.txt` or the
printed line), then paste the resulting `vless://…` link. Done 🎉

> [!TIP]
> Lost the link? It is saved on the server (base64-encoded):
>
> ```bash
> ssh <account>@ssh-<account>.alwaysdata.net "base64 -d wuhaoxian/cache.txt"
> ```

## 📱 Clients

XHTTP needs an Xray-based client.

| Client                             | Core     | XHTTP           |
| ---------------------------------- | -------- | --------------- |
| v2rayNG, Happ, v2RayTun, Streisand | Xray     | ✅ works         |
| Hiddify, NekoBox, etc.             | sing-box | ⚠️ may not work |

## 🔄 Update

Re-run the install, then restart the site in the panel. That updates Xray to the newest release and the scripts
to your local copies (or, with the server command, to the latest version on GitHub). Secrets are kept, the link
stays the same.

> [!NOTE]
> Installs before October 2026 lived right in the home folder, and older installs used `~/xray`. The update moves them
> into `~/wuhaoxian` (the link stays the same) and asks you to change the site's command and working directory to the
> ones in step 3.

**Need new secrets** (e.g. the link leaked)? Delete `~/wuhaoxian/secrets.env` on the server, re-run the install and restart
the site. You get a new UUID, path and link.

## 🗑️ Uninstall

Change the site type back in the panel (or delete the site), then:

```bash
ssh <account>@ssh-<account>.alwaysdata.net "rm -rf ~/wuhaoxian"
```

## ❓ FAQ

<details>
<summary><b>Why XHTTP mode <code>packet-up</code>?</b></summary>

The alwaysdata proxy breaks `stream-up` and `stream-one`. The server accepts any mode, the link tells the client
to use `packet-up`.

</details>

<details>
<summary><b>Why a pre-release Xray?</b></summary>

`setup.sh` installs the newest Xray release, pre-releases included (v26.9.9 as of September 2026).
`start.sh` lists the VLESS user under `users`, which Xray reads only since v26.5.9, and GitHub's latest stable
release (v26.3.27) is older.

A future release may change the config format again, so check the relay after updating.

</details>

<details>
<summary><b>Will the account stay alive?</b></summary>

Not guaranteed. Proxies are against the free plan's rules, and free accounts are also suspended if you don't log
into the panel for 120 days.

</details>

> [!IMPORTANT]
> Log into the alwaysdata panel at least once every 120 days, otherwise the free account is suspended.

## 📄 License

[MIT](LICENSE) © 2026 Dmitry Ganin
