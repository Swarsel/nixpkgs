{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "rubicon-objc";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "beeware";
    repo = "rubicon-objc";
    tag = "v${version}";
    hash = "sha256-h2KMfV6vduhO0AsMNiZ+nFJubhrrt4rNXpdngelDMpU=";
  };

  postPatch = ''
    sed -i 's/"setuptools==.*"/"setuptools"/' pyproject.toml
    sed -i 's/"setuptools_scm==.*"/"setuptools_scm"/' pyproject.toml
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    make -C tests/objc
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "rubicon.objc" ];

  meta = {
    description = "Bridge interface between Python and Objective-C";
    homepage = "https://github.com/beeware/rubicon-objc/";
    changelog = "https://github.com/beeware/rubicon-objc/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.darwin;
  };
}
