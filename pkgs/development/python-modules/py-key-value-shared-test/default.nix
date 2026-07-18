{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-key-value-shared-test";
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

  # No tests
  doCheck = false;

  build-system = [
    uv-build
  ];

  pyproject = true;
  pythonImportsCheck = [ "key_value.shared_test" ];
  sourceRoot = "${finalAttrs.src.name}/key-value/key-value-shared-test";

  meta = {
    description = "Utils for key-value-shared";
    homepage = "https://github.com/strawgate/py-key-value/tree/main/key-value/key-value-shared-test";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
