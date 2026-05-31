#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_ROOT="$SCRIPT_DIR"
HARUCOM_ROOT="$PROJECT_ROOT/harucom-os"
ROOTFS_ROOT="$HARUCOM_ROOT/rootfs"

require_directory() {
	local path="$1"

	if [[ ! -d "$path" ]]; then
		printf 'Required directory not found: %s\n' "$path" >&2
		exit 1
	fi
}

copy_non_ignored_files() {
	local relative_path source_path destination_path copied_count=0

	mkdir -p "$ROOTFS_ROOT/app" "$ROOTFS_ROOT/lib" "$ROOTFS_ROOT/data"

	while IFS= read -r -d '' relative_path; do
		relative_path="${relative_path#./}"

		if git -C "$SOURCE_ROOT" check-ignore -q --no-index -- "$relative_path"; then
			continue
		fi

		source_path="$SOURCE_ROOT/$relative_path"
		destination_path="$ROOTFS_ROOT/$relative_path"

		mkdir -p "$(dirname -- "$destination_path")"
		cp -p -- "$source_path" "$destination_path"

		copied_count=$((copied_count + 1))
		printf 'Copied %s\n' "$relative_path"
	done < <(
		cd "$SOURCE_ROOT"
		find app lib data -type f -print0
	)

	if [[ "$copied_count" -eq 0 ]]; then
		echo 'No non-ignored files found under shooter_game/app, lib, or data.'
	fi
}

require_directory "$SOURCE_ROOT"
require_directory "$HARUCOM_ROOT"
require_directory "$ROOTFS_ROOT"

git -C "$SOURCE_ROOT" rev-parse --is-inside-work-tree >/dev/null

copy_non_ignored_files

cd "$HARUCOM_ROOT"
bundle exec rake
bundle exec rake flash