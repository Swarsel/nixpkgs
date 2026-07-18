{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  installer,
  mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "installer";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "installer";
    rev = version;
    hash = "sha256-GkHLZfzHfTcBL8wQmIGlNkVodEw9Pih4i1SS36mSfBo=";
  };

  patches = [
    # Add -m flag to installer to correctly support cross
    # https://github.com/pypa/installer/pull/258
    ./cross.patch
  ];

  nativeBuildInputs = [ flit-core ];
  # We need to disable tests because this package is part of the bootstrap chain
  # and its test dependencies cannot be built yet when this is being built.
  doCheck = false;
  pyproject = true;

  passthru.tests = {
    pytest = buildPythonPackage {
      inherit version;
      pname = "${pname}-pytest";

      nativeCheckInputs = [
        installer
        mock
        pytestCheckHook
      ];

      dontBuild = true;
      dontInstall = true;
      pyproject = false;
    };
  };

  meta = {
    description = "Low-level library for installing a Python package from a wheel distribution";
    homepage = "https://github.com/pypa/installer";
    changelog = "https://github.com/pypa/installer/blob/${src.rev}/docs/changelog.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.cpcloud ];
    teams = [ lib.teams.python ];
  };
}
