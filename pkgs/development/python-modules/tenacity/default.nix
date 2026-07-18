{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools-scm,
  tornado,
  typeguard,
}:

buildPythonPackage (finalAttrs: {
  pname = "tenacity";
  version = "9.1.4";

  src = fetchFromGitHub {
    owner = "jd";
    repo = "tenacity";
    tag = finalAttrs.version;
    hash = "sha256-JiWfIlStps3HZQw4KEohKAUWWZtMAuluXXzvqU+p8V4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    tornado
    typeguard
  ];

  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "tenacity" ];

  meta = {
    description = "Retrying library for Python";
    homepage = "https://github.com/jd/tenacity";
    changelog = "https://github.com/jd/tenacity/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jakewaksbaum ];
  };
})
