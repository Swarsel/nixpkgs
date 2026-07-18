{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chardet,
  click,
  dnspython,
  jinja2,
  python-daemon,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "salmon-mail";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "moggers87";
    repo = "salmon";
    tag = version;
    hash = "sha256-ysBO/ridfy7YPoTsVwAxar9UvfM/qxrx2dp0EtDNLvE=";
  };

  patches = [
    # Fix test_main expecting exit code 0 from click group with no args (click 8.2 returns 2).
    ./test-main-click-8.2-exit-code.patch
  ];

  nativeCheckInputs = [
    jinja2
    unittestCheckHook
  ];

  # The tests use salmon executable installed by salmon itself so we need to add
  # that to PATH
  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  # Darwin tests fail without this. See:
  # https://github.com/NixOS/nixpkgs/pull/82166#discussion_r399909846
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    chardet
    click
    dnspython
    python-daemon
  ];

  pyproject = true;

  pythonImportsCheck = [
    "salmon"
    "salmon.handlers"
  ];

  meta = {
    description = "Pythonic mail application server";
    homepage = "https://salmon-mail.readthedocs.org/";
    changelog = "https://github.com/moggers87/salmon/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jluttine ];
    mainProgram = "salmon";
  };
}
