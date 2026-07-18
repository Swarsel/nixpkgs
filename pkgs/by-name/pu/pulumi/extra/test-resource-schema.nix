{
  lib,
  jq,
  pulumi,
  runCommand,
}:
{
  package,
  name ? lib.removePrefix "pulumi-" (lib.getName package),
  version ? lib.getVersion package,
}:
runCommand "pulumi-resource-${name}-schema-version-check"
  {
    nativeBuildInputs = [
      jq
      pulumi
      package
    ];

    env = {
      PULUMI_DISABLE_AUTOMATIC_PLUGIN_ACQUISITION = "1";
      PULUMI_SKIP_UPDATE_CHECK = "1";
    };

    __darwinAllowLocalNetworking = true;
    expectedVersion = if version != null then version else "null";
    resourceName = name;
    meta.timeout = 120;
  }
  ''
    actualVersion=$(pulumi package get-schema -- "$resourceName" | jq -j .version)
    if [[ $expectedVersion != "$actualVersion" ]]; then
      echo "Expected schema version $expectedVersion, but got $actualVersion" >&2
      false
    fi
    mkdir -p "$out"
  ''
