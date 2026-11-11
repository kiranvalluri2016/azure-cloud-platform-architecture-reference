#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bicep_command="${BICEP_COMMAND:-bicep}"
output_dir="${LOCAL_VALIDATION_OUTPUT_DIR:-/tmp/azure-cloud-platform-architecture-reference-validation}"

mkdir -p "$output_dir/templates" "$output_dir/parameters"

if ! command -v "$bicep_command" >/dev/null 2>&1; then
  echo "Bicep CLI not found. Set BICEP_COMMAND to a local Bicep executable." >&2
  exit 2
fi

while IFS= read -r template; do
  relative_path="${template#"$project_root/"}"
  output_name="${relative_path//\//_}"
  "$bicep_command" build "$template" --outfile "$output_dir/templates/${output_name%.bicep}.json"
  "$bicep_command" lint "$template"
done < <(find "$project_root/infra" -name '*.bicep' -type f | LC_ALL=C sort)

while IFS= read -r parameter_file; do
  relative_path="${parameter_file#"$project_root/"}"
  output_name="${relative_path//\//_}"
  "$bicep_command" build-params "$parameter_file" --outfile "$output_dir/parameters/${output_name%.bicepparam}.json"
done < <(find "$project_root/infra/params" -name '*.bicepparam' -type f | LC_ALL=C sort)

python3 -m unittest discover -s "$project_root/tests" -v
echo "Local static validation completed. No Azure login or deployment command was executed."
