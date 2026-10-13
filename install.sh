#!/usr/bin/env bash
# リポジトリの内容をホームディレクトリへ反映する。既定ではsymlinkを張るので、
# リポジトリを編集すればそのまま反映される（再実行は、ファイルを追加したときだけでよい）。
#
#   ./install.sh                     全Skillを反映する（home/ は反映しない）
#   ./install.sh technical-writing   指定したSkillだけ反映する
#   ./install.sh --home              Skillに加えて home/ も反映する
#   ./install.sh --copy              symlinkの代わりにコピーする
#   ./install.sh --dry-run           実行せずに、何をするかだけ表示する
#
# 反映先:
#   skills/<name>/  -> ~/.claude/skills/<name>/ と ~/.agents/skills/<name>/
#   home/<path>     -> ~/<path>   （例: home/.claude/CLAUDE.md -> ~/.claude/CLAUDE.md）
#
# 反映先に同名の通常ファイルがあれば、<名前>.bak.<日時> に退避してから置き換える。
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_targets=(
  "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
  "${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"
)
home_dir="${INSTALL_HOME:-$HOME}"
stamp="$(date +%Y%m%d%H%M%S)"

mode=link
dry_run=false
install_home=false
names=()
for arg in "$@"; do
  case "$arg" in
    --home) install_home=true ;;
    --copy) mode=copy ;;
    --link) mode=link ;;
    --dry-run) dry_run=true ;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "不明なオプション: $arg" >&2; exit 1 ;;
    *) names+=("$arg") ;;
  esac
done

run() {
  if $dry_run; then echo "+ $*"; else "$@"; fi
}

# src を dest に反映する。既存のsymlinkは張り直し、通常のファイル・ディレクトリは退避する
place() {
  local src="$1" dest="$2"
  run mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    run rm "$dest"
  elif [ -e "$dest" ]; then
    run mv "$dest" "$dest.bak.$stamp"
    echo "退避: $dest -> $dest.bak.$stamp"
  fi
  if [ "$mode" = link ]; then
    run ln -s "$src" "$dest"
  else
    run cp -R "$src" "$dest"
  fi
  echo "$mode: $dest"
}

if [ ${#names[@]} -eq 0 ]; then
  for d in "$repo_dir"/skills/*/; do
    [ -f "$d/SKILL.md" ] && names+=("$(basename "$d")")
  done
fi

for name in "${names[@]}"; do
  src="$repo_dir/skills/$name"
  if [ ! -f "$src/SKILL.md" ]; then
    echo "Skillが見つからない: $name（$src/SKILL.md がない）" >&2
    exit 1
  fi
  for target in "${skill_targets[@]}"; do
    place "$src" "$target/$name"
  done
done

if $install_home && [ -d "$repo_dir/home" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#"$repo_dir/home/"}"
    place "$f" "$home_dir/$rel"
  done < <(find "$repo_dir/home" -type f -print0 | sort -z)
fi
