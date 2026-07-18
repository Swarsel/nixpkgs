{
  lib,
  fetchFromGitHub,
  # dependencies
  beartype,
  buildPythonPackage,
  inline-snapshot,
  py-key-value-shared-test,
  pytest-xdist,
  # tests
  pytestCheckHook,
  typing-extensions,
  # build-system
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-key-value-shared";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "strawgate";
    repo = "py-key-value";
    tag = finalAttrs.version;
    hash = "sha256-4ji+GzJTv1QnC5n/OaL9vR65j8BQmJsVGGnjjuulDiU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        "uv_build>=0.8.2,<0.9.0" \
        "uv_build"
  '';

  nativeCheckInputs = [
    inline-snapshot
    py-key-value-shared-test
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    uv-build
  ];

  dependencies = [
    beartype
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "key_value.shared" ];
  sourceRoot = "${finalAttrs.src.name}/key-value/key-value-shared";

  meta = {
    description = "Shared code between key-value-aio and key-value-sync";
    homepage = "https://github.com/strawgate/py-key-value/tree/main/key-value/key-value-shared";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
