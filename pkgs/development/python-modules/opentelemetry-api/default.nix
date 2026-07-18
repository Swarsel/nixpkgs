{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecated,
  hatchling,
  importlib-metadata,
  opentelemetry-test-utils,
  pytestCheckHook,
  typing-extensions,
  writeScript,
}:

let
  self = buildPythonPackage rec {
    pname = "opentelemetry-api";
    version = "1.43.0";

    # to avoid breakage, every package in opentelemetry-python must inherit this version, src, and meta
    src = fetchFromGitHub {
      owner = "open-telemetry";
      repo = "opentelemetry-python";
      tag = "v${version}";
      hash = "sha256-NnRx0sMVlht2CVXeKjP7mZlzhyOqU/YyveDMWRbmAD8=";
    };

    doCheck = false;

    nativeCheckInputs = [
      opentelemetry-test-utils
      pytestCheckHook
    ];

    build-system = [ hatchling ];

    dependencies = [
      deprecated
      importlib-metadata
      typing-extensions
    ];

    pyproject = true;
    pythonImportsCheck = [ "opentelemetry" ];
    pythonRelaxDeps = [ "importlib-metadata" ];
    sourceRoot = "${src.name}/opentelemetry-api";

    passthru = {
      # Enable tests via passthru to avoid cyclic dependency with opentelemetry-test-utils.
      tests.${self.pname} = self.overridePythonAttrs { doCheck = true; };

      updateScript = writeScript "update.sh" ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p nix-update

        set -eu -o pipefail
        nix-update --version-regex 'v(.*)' python3Packages.opentelemetry-api
        nix-update python3Packages.opentelemetry-instrumentation
      '';
    };

    meta = {
      description = "OpenTelemetry Python API";
      homepage = "https://github.com/open-telemetry/opentelemetry-python/tree/main/opentelemetry-api";
      changelog = "https://github.com/open-telemetry/opentelemetry-python/releases/tag/${src.tag}";
      license = lib.licenses.asl20;
      maintainers = [ lib.maintainers.natsukium ];
    };
  };
in
self
