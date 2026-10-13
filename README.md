# agent-dotfiles

Claude Code と Codex の個人設定（Skillと、全リポジトリ共通の指示ファイル）を管理するリポジトリ。ここが原本で、`install.sh` でホームディレクトリからsymlinkを張る。設定を直すときは、このリポジトリのファイルを編集すればよい。

## 反映する

```sh
# 全Skillと home/ の設定ファイル
./install.sh --home

# 指定したSkillだけ
./install.sh <skill名> [<skill名>...]
```

反映先は次のとおり。いずれもsymlinkを張る。

| リポジトリ | 反映先 | 反映する条件 |
|---|---|---|
| `skills/<name>/` | `~/.claude/skills/<name>/`、`~/.agents/skills/<name>/` | 常に（Skill名を指定した場合はそのSkillだけ） |
| `home/.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | `--home` のときだけ |
| `home/.codex/AGENTS.md` | `~/.codex/AGENTS.md` | `--home` のときだけ |

`home/` 配下のファイルは、`home/` を `~` に読み替えた場所に反映される。新しい設定ファイルを管理したくなったら、同じ相対パスで `home/` に置いて再実行する。

反映先に通常のファイルがあれば、`<名前>.bak.<日時>` に退避してから置き換える。初回に既存の `~/.claude/CLAUDE.md` などが退避された場合は、その中身を `home/` 側のファイルに移す。実行前に `--dry-run` で確認できる。

既存ファイルを編集するだけなら再実行は要らない。ファイルを追加したときだけ再実行する。

その他のオプション:

- `--copy` — symlinkの代わりにコピーする
- `--dry-run` — 実行せず、何をするかだけ表示する

## Skill一覧

| Skill | 用途 |
|---|---|
| [technical-writing](skills/technical-writing/SKILL.md) | 日本語の技術文書（Issue、設計書、ADR、実装プランなど）を、読み手が要約なしで理解できるように書く・直す |

## Skillを追加する

`skills/<name>/SKILL.md` を作り、`./install.sh` を実行する。ディレクトリ名とfrontmatterの `name` は一致させる。

```markdown
---
name: <name>
description: いつ使うか、いつ使わないか
---

本文
```

## 補足

- Claude Code はリポジトリ内の `AGENTS.md` も読むが、ユーザーレベルの指示は `~/.claude/CLAUDE.md` からしか読まない。そのため Claude Code 用と Codex 用で別のファイルを置いている
- claude.ai（チャット）のスキルはこのリポジトリと同期しない。SKILL.md を更新したら、claude.ai 側にも登録し直す
