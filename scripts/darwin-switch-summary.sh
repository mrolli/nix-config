#!/usr/bin/env bash
set -euo pipefail

host="id-mrolli-mbp-M4-24"
flake_dir="${NIX_SYSTEM_FLAKE_DIR:-$HOME/.config/nix-config}"

usage() {
  cat <<'EOF'
Usage: darwin-switch-summary [--host <name>]

Builds the Darwin system output, prints a summary of what changes compared to the
currently running system, shows an applications version-change table, and asks
whether to switch.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --host)
    host="${2:?missing host value}"
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

for cmd in nix jq darwin-rebuild sudo; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

resolve_current_system() {
  local candidate
  for candidate in /run/current-system /nix/var/nix/profiles/system; do
    if [[ -e "$candidate" ]]; then
      readlink "$candidate" >/dev/null 2>&1 || true
      realpath "$candidate"
      return 0
    fi
  done
  return 1
}

nix_path_info_json() {
  local target_path="$1"
  if nix path-info --recursive --json --json-format 2 "$target_path" >"$2" 2>/dev/null; then
    return 0
  fi
  nix path-info --recursive --json "$target_path" >"$2"
}

cd "$flake_dir"
attr="darwinConfigurations.${host}.system"
tmp_dir="$(mktemp -d)"
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT

echo "Building ${attr} ..."
new_system_path="$(nix build --no-link --print-out-paths ".#${attr}")"

if ! current_system_path="$(resolve_current_system)"; then
  echo "Could not resolve current system profile path." >&2
  exit 1
fi

echo "Current system: ${current_system_path}"
echo "New system:     ${new_system_path}"
echo

nix_path_info_json "$current_system_path" "$tmp_dir/current-closure.json"
nix_path_info_json "$new_system_path" "$tmp_dir/new-closure.json"

echo "### System change summary"
jq -n \
  --slurpfile current "$tmp_dir/current-closure.json" \
  --slurpfile next "$tmp_dir/new-closure.json" \
  '
  def closureEntries($doc):
    if ($doc | type) == "array" then
      $doc
    elif ($doc | type) == "object" and (($doc.info // null) | type) == "object" then
      $doc.info
      | to_entries
      | map(
          . as $entry
          | $entry.value
          | if (.path // null) == null then
              . + { path: (($entry.value.storeDir // "/nix/store") + "/" + $entry.key) }
            else
              .
            end
        )
    elif ($doc | type) == "object" then
      if (($doc.path // null) | type) == "string" then
        [$doc]
      else
        $doc
        | to_entries
        | map(select(.value | type == "object"))
        | map(.value + { path: (.value.path // .key) })
      end
    else
      []
    end;

  def toMap($arr):
    reduce ($arr[] | select((.path // null) != null)) as $item ({}; .[$item.path] = $item);

  (closureEntries($current[0])) as $cur
  | (closureEntries($next[0])) as $nxt
  | (toMap($cur)) as $curMap
  | (toMap($nxt)) as $nxtMap
  | ($curMap | keys_unsorted) as $curPaths
  | ($nxtMap | keys_unsorted) as $nxtPaths
  | ($nxtPaths - $curPaths) as $added
  | ($curPaths - $nxtPaths) as $removed
  | {
      current_paths: ($curPaths | length),
      next_paths: ($nxtPaths | length),
      added_paths: ($added | length),
      removed_paths: ($removed | length),
      current_closure_size: (($cur | map(.narSize // 0) | add) // 0),
      next_closure_size: (($nxt | map(.narSize // 0) | add) // 0)
    }
  | .closure_size_delta = (.next_closure_size - .current_closure_size)
  ' >"$tmp_dir/summary.json"

jq -r '
  [
    "Current closure paths: \(.current_paths)",
    "New closure paths:     \(.next_paths)",
    "Added paths:           \(.added_paths)",
    "Removed paths:         \(.removed_paths)",
    "Current closure size:  \(.current_closure_size) bytes",
    "New closure size:      \(.next_closure_size) bytes",
    "Closure size delta:    \(.closure_size_delta) bytes"
  ] | .[]
' "$tmp_dir/summary.json"

jq -n \
  --slurpfile current "$tmp_dir/current-closure.json" \
  --slurpfile next "$tmp_dir/new-closure.json" \
  '
  def closureEntries($doc):
    if ($doc | type) == "array" then
      $doc
    elif ($doc | type) == "object" and (($doc.info // null) | type) == "object" then
      $doc.info
      | to_entries
      | map(
          . as $entry
          | $entry.value
          | if (.path // null) == null then
              . + { path: (($entry.value.storeDir // "/nix/store") + "/" + $entry.key) }
            else
              .
            end
        )
    elif ($doc | type) == "object" then
      if (($doc.path // null) | type) == "string" then
        [$doc]
      else
        $doc
        | to_entries
        | map(select(.value | type == "object"))
        | map(.value + { path: (.value.path // .key) })
      end
    else
      []
    end;

  def normalize($path):
    ($path | split("/") | last | sub("^[a-z0-9]{32}-"; "")) as $drvName
    | (
        if ($drvName | test("^(?<name>.+)-(?<version>[0-9][A-Za-z0-9.+:_~-]*)$")) then
          ($drvName | capture("^(?<name>.+)-(?<version>[0-9][A-Za-z0-9.+:_~-]*)$"))
        else
          { name: $drvName, version: null }
        end
      );

  def toVersionMap($arr):
    reduce $arr[] as $item ({};
      (normalize($item.path)) as $n
      | if $n.version == null then . else .[$n.name] = $n.version end
    );

  (toVersionMap(closureEntries($current[0]))) as $cur
  | (toVersionMap(closureEntries($next[0]))) as $nxt
  | (($cur | keys_unsorted) + ($nxt | keys_unsorted) | unique) as $all
  | [
      $all[] as $name
      | ($cur[$name] // null) as $before
      | ($nxt[$name] // null) as $after
      | select($before != $after)
      | {
          app: $name,
          before: $before,
          after: $after,
          change: (
            if $before == null then "added"
            elif $after == null then "removed"
            else "updated"
            end
          )
        }
    ]
  | sort_by(.app)
  ' >"$tmp_dir/app-changes.json"

echo
echo "### Application version changes"

if [[ "$(jq 'length' "$tmp_dir/app-changes.json")" -eq 0 ]]; then
  echo "No application/package version changes detected."
else
  jq -r '
    ["| App | Previous | New | Change |", "|---|---|---|---|"]
    + (map("| \(.app) | \(.before // "-") | \(.after // "-") | \(.change) |"))
    | .[]
  ' "$tmp_dir/app-changes.json"
fi

echo
read -r -p "Switch to the new configuration now? [y/N] " answer
if [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
  sudo darwin-rebuild switch --flake ".#${host}"
else
  echo "Skipped switch."
fi
