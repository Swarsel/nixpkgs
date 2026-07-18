{
  lib,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  bc,
  jq,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pyp";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "hauntsaninja";
    repo = "pyp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u9yxjYNQrtYtFtUh5tTJ1mGmGB+Ry+FRupli8RzRu3c=";
  };

  nativeCheckInputs =
    (with python3Packages; [
      pytestCheckHook
    ])
    ++ [
      addBinToPathHook
      bc
      jq
      versionCheckHook
    ];

  __structuredAttrs = true;

  build-system = with python3Packages; [
    flit-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyp" ];

  meta = {
    description = "Easily run Python at the shell";
    homepage = "https://github.com/hauntsaninja/pyp";
    changelog = "https://github.com/hauntsaninja/pyp/blob/${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];

    maintainers = with lib.maintainers; [
      rmcgibbo
    ];

    mainProgram = "pyp";
  };
})
