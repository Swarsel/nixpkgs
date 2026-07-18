{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pillow,
  pytestCheckHook,
  uv-build,
}:
buildPythonPackage (finalAttrs: {
  pname = "odfdo";
  version = "3.22.10";

  src = fetchFromGitHub {
    owner = "jdum";
    repo = "odfdo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H/aJhWqkQGtG7bppM1AxWo/GBGYR6qAF7d/nxrby30M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pillow
  ];

  build-system = [ uv-build ];
  dependencies = [ lxml ];
  pyproject = true;

  meta = {
    description = "OpenDocument Format (ODF, ISO/IEC 26300) library for Python";
    homepage = "https://github.com/jdum/odfdo";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ungeskriptet ];
  };
})
