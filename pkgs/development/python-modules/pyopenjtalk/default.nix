{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  cython,
  fetchzip,
  numpy,
  pytestCheckHook,
  python,
  setuptools,
  setuptools-scm,
  tqdm,
}:

let
  dic-dirname = "open_jtalk_dic_utf_8-1.11";
  dic-src = fetchzip {
    hash = "sha256-+6cHKujNEzmJbpN9Uan6kZKsPdwxRRzT3ZazDnCNi3s=";
    name = dic-dirname;
    url = "https://github.com/r9y9/open_jtalk/releases/download/v1.11.1/${dic-dirname}.tar.gz";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "pyopenjtalk";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "r9y9";
    repo = "pyopenjtalk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f0JNiMCeKpTY+jH3/9LuCkX2DRb9U8sN0SezT6OTm/E=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # the built extension modules are only present in $out
    # so we make sure to resolve pyopenjtalk from $out
    rm -r pyopenjtalk
  '';

  postInstall = ''
    # the package searches for a cached dic directory in this location
    ln -s ${dic-src} $out/${python.sitePackages}/pyopenjtalk/${dic-dirname}
  '';

  build-system = [
    cmake
    cython
    numpy
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    tqdm
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pyopenjtalk" ];

  meta = {
    description = "Python wrapper for OpenJTalk";
    homepage = "https://github.com/r9y9/pyopenjtalk";
    changelog = "https://github.com/r9y9/pyopenjtalk/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
