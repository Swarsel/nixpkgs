{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  crytic-compile,
  # build-system
  hatchling,
  # nativeBuildInputs
  makeWrapper,
  packaging,
  prettytable,
  # postFixup
  solc,
  # tests
  versionCheckHook,
  web3,
  writableTmpDirAsHomeHook,
  withSolc ? false,
}:

buildPythonPackage (finalAttrs: {
  pname = "slither-analyzer";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "slither";
    tag = finalAttrs.version;
    hash = "sha256-sy1vE9XniwyvvZRFnnKhPfmYh2auHHcMel9sZx2YK3c=";
  };

  nativeBuildInputs = [ makeWrapper ];

  nativeCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  postFixup = lib.optionalString withSolc ''
    wrapProgram $out/bin/slither \
      --prefix PATH : "${lib.makeBinPath [ solc ]}"
  '';

  build-system = [ hatchling ];

  dependencies = [
    crytic-compile
    packaging
    prettytable
    web3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "slither"
    "slither.all_exceptions"
    "slither.analyses"
    "slither.core"
    "slither.detectors"
    "slither.exceptions"
    "slither.formatters"
    "slither.printers"
    "slither.slither"
    "slither.slithir"
    "slither.solc_parsing"
    "slither.utils"
    "slither.visitors"
    "slither.vyper_parsing"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Static Analyzer for Solidity";

    longDescription = ''
      Slither is a Solidity static analysis framework written in Python 3. It
      runs a suite of vulnerability detectors, prints visual information about
      contract details, and provides an API to easily write custom analyses.
    '';

    homepage = "https://github.com/trailofbits/slither";
    changelog = "https://github.com/crytic/slither/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      arturcygan
      fab
      hellwolf
    ];

    mainProgram = "slither";
  };
})
