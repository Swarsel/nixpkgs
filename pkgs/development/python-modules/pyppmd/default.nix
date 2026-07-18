{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  hypothesis,
  pytest-benchmark,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyppmd";
  version = "1.1.1";

  src = fetchFromCodeberg {
    owner = "miurahr";
    repo = "pyppmd";
    tag = "v${version}";
    hash = "sha256-0t1vyVMtmhb38C2teJ/Lq7dx4usm4Bzx+k7Zalf/nXE=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-benchmark
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];

  pythonImportsCheck = [
    "pyppmd"
  ];

  meta = {
    description = "PPMd compression/decompression library";
    homepage = "https://codeberg.org/miurahr/pyppmd";
    changelog = "https://codeberg.org/miurahr/pyppmd/src/tag/v${version}/Changelog.rst#v${version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pitkling
      PopeRigby
    ];
  };
}
