{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  jax,
  numpy,
  # build-system
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyvers";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "vmoens";
    repo = "pyvers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aXHOgKd/w1RKdL0wLoM4F05JWTaKAL3i3UerLcBG+vs=";
  };

  nativeCheckInputs = [
    jax
    numpy
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyvers" ];

  meta = {
    description = "Python library for dynamic dispatch based on module versions and backends";
    homepage = "https://github.com/vmoens/pyvers";
    changelog = "https://github.com/vmoens/pyvers/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
