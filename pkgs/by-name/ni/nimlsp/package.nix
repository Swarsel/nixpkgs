{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  nim-unwrapped,
  srcOnly,
}:
buildNimPackage (finalAttrs: {
  pname = "nimlsp";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "PMunch";
    repo = "nimlsp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jUNW+tukZXv41HTWP2F2BdEn7nesFXVg2TffKPWfSss=";
  };

  buildInputs =
    let
      # Needs this specific version to build.
      jsonSchemaSrc = fetchFromGitHub {
        hash = "sha256-f9F1oam/ZXwDKXqGMUUQ5+tMZKTe7t4UlZ4U1LAkRss=";
        owner = "PMunch";
        repo = "jsonschema";
        rev = "7b41c03e3e1a487d5a8f6b940ca8e764dc2cbabf";
      };
    in
    [ jsonSchemaSrc ];

  doCheck = false;
  lockFile = ./lock.json;

  nimDefines = [
    "nimcore"
    "nimsuggest"
    "debugCommunication"
    "debugLogging"
  ];

  nimFlags = [
    "--threads:on"
    "-d:explicitSourcePath=${srcOnly nim-unwrapped}"
    "-d:tempDir=/tmp"
  ];

  meta = {
    description = "Language Server Protocol implementation for Nim";
    homepage = "https://github.com/PMunch/nimlsp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xtrayambak ];
    mainProgram = "nimlsp";
  };
})
