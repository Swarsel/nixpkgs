{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  py,
  pytest,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  setuptools-scm,
  wheel,
}:

buildPythonPackage rec {
  pname = "pytest-forked";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-forked";
    tag = "v${version}";
    hash = "sha256-owkGwF5WQ17/CXwTsIYJ2AgktekRB4qhtsDxR0LCI/k=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-tTRW0p3tOotQMtjjJ6RUKdynsAnKRz0RAV8gAUHiNNA=";
      # https://github.com/pytest-dev/pytest-forked/actions
      name = "pytest8-compat.patch";
      url = "https://github.com/pytest-dev/pytest-forked/commit/b2742322d39ebda97d5170922520f3bb9c73f614.patch";
    })
    # https://github.com/pytest-dev/pytest-forked/pull/96
    ./pytest9-compat.patch
  ];

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  buildInputs = [ pytest ];
  propagatedBuildInputs = [ py ];

  nativeCheckInputs = [
    py
    pytestCheckHook
  ];

  disabledTests =
    if (pythonAtLeast "3.12" && stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) then
      [
        # non reproducible test failure on hydra, works on community builder
        # https://hydra.nixos.org/build/252537267
        "test_xfail"
      ]
    else
      null;

  pyproject = true;
  setupHook = ./setup-hook.sh;

  meta = {
    description = "Run tests in isolated forked subprocesses";
    homepage = "https://github.com/pytest-dev/pytest-forked";
    changelog = "https://github.com/pytest-dev/pytest-forked/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
