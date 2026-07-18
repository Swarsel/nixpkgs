{
  lib,
  fetchFromGitHub,
  awesomeversion,
  buildPythonPackage,
  docutils,
  flaky,
  installShellFiles,
  jq,
  lxml,
  nix-update-script,
  packaging,
  platformdirs,
  pycurl,
  pytest-asyncio,
  pytest-httpbin,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  structlog,
  tornado,
  zstandard,
}:

buildPythonPackage rec {
  pname = "nvchecker";
  version = "2.20";

  src = fetchFromGitHub {
    owner = "lilydjwg";
    repo = "nvchecker";
    tag = "v${version}";
    hash = "sha256-udwflm3C7C6Q7rSA0x0+8uf1F5quy2okf2IyZqKtA3E=";
  };

  nativeBuildInputs = [
    docutils
    installShellFiles
  ];

  postBuild = ''
    patchShebangs docs/myrst2man.py
    make -C docs man
  '';

  nativeCheckInputs = [
    flaky
    pytest-asyncio
    pytest-httpbin
    pytestCheckHook
  ];

  postInstall = ''
    installManPage docs/_build/man/nvchecker.1
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    structlog
    platformdirs
    tornado
    pycurl
  ];

  disabledTestMarks = [ "needs_net" ];

  optional-dependencies = {
    # vercmp = [ pyalpm ];
    awesomeversion = [ awesomeversion ];
    htmlparser = [ lxml ];
    jq = [ jq ];
    pypi = [ packaging ];
    rpmrepo = [ lxml ] ++ lib.optionals (pythonOlder "3.14") [ zstandard ];
  };

  pyproject = true;
  pythonImportsCheck = [ "nvchecker" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "New version checker for software";
    homepage = "https://github.com/lilydjwg/nvchecker";
    changelog = "https://github.com/lilydjwg/nvchecker/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
  };
}
