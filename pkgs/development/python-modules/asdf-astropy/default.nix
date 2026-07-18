{
  lib,
  fetchFromGitHub,
  asdf,
  asdf-coordinates-schemas,
  asdf-standard,
  asdf-transform-schemas,
  astropy,
  buildPythonPackage,
  numpy,
  packaging,
  pytest-astropy-header,
  pytest-doctestplus,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "asdf-astropy";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "astropy";
    repo = "asdf-astropy";
    tag = finalAttrs.version;
    hash = "sha256-dHi+VFMo5RcJAIExR8OFTljtG3P/VXT2jzkbBobwVKg=";
  };

  postPatch = ''
    # pytest chokes on unhandled options in the [tool.pytest.ini_options] section
    sed -i "/asdf_schema_/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytest-astropy-header
    pytest-doctestplus
    pytestCheckHook
    scipy
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asdf
    asdf-coordinates-schemas
    asdf-standard
    asdf-transform-schemas
    astropy
    numpy
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "asdf_astropy" ];

  meta = {
    description = "Extension library for ASDF to provide support for Astropy";
    homepage = "https://github.com/astropy/asdf-astropy";
    changelog = "https://github.com/astropy/asdf-astropy/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
