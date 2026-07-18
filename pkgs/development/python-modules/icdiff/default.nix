{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pkgs,
  pytestCheckHook,
  python,
  pythonAtLeast,
  setuptools,
  writableTmpDirAsHomeHook,
}:
let
  inherit (pkgs) bash git less;
in

buildPythonPackage rec {
  pname = "icdiff";
  version = "2.0.10";

  src = fetchFromGitHub {
    owner = "jeffkaufman";
    repo = "icdiff";
    tag = "release-${version}";
    hash = "sha256-7/EvuHNWE9kdb35TFuqT8ShjyciodsRNkBMG0WvTy1c=";
  };

  patches = [ ./0001-Don-t-test-black-or-flake8.patch ];

  # Before the wheel gets created, fix up the shebangs.
  preBuild = ''
    patchShebangs test.sh icdiff git-icdiff
  '';

  # Odd behavior in the sandbox
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    bash
    git
    less
    writableTmpDirAsHomeHook
  ];

  checkPhase = ''
    runHook preCheck

    ./test.sh ${python.interpreter}

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "icdiff" ];

  meta = {
    description = "Improved colorized diff";
    homepage = "https://github.com/jeffkaufman/icdiff";
    changelog = "https://github.com/jeffkaufman/icdiff/releases/tag/release-${version}/CHANGELOG.md";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
