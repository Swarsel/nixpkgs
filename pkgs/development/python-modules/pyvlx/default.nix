{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecated,
  pytestCheckHook,
  pyyaml,
  setuptools,
  setuptools-scm,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyvlx";
  version = "0.2.36";

  src = fetchFromGitHub {
    owner = "Julius2342";
    repo = "pyvlx";
    tag = finalAttrs.version;
    hash = "sha256-Kmwbw9hUryeSvdJ9ru0zGYaEN3ZKtAbuakLASzTDH2g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    deprecated
    pyyaml
    zeroconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyvlx" ];

  meta = {
    description = "Python client to work with Velux units";

    longDescription = ''
      PyVLX uses the Velux KLF 200 interface to control io-Homecontrol
      devices, e.g. Velux Windows.
    '';

    homepage = "https://github.com/Julius2342/pyvlx";
    changelog = "https://github.com/Julius2342/pyvlx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
