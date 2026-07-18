{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pscript,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage (finalAttrs: {
  pname = "vbuild";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "manatlan";
    repo = "vbuild";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p9v1FiYn0cI+f/25hvjwm7eb1GqxXvNnmXBGwZe9fk0=";
  };

  postPatch = ''
    # Switch to poetry-core, patch can't be applied, https://github.com/manatlan/vbuild/pull/12
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"' \
      --replace-fail 'requires = ["poetry>=0.12"]' 'requires = ["poetry-core>=1.0.0"]' \
      --replace-fail 'build-backend = "poetry.masonry.api"' 'build-backend = "poetry.core.masonry.api"'
    # https://github.com/manatlan/vbuild/commit/b9861bffd5d15491d5b5a4cb2a96bb71ceff0c35 is incomplete
    substituteInPlace vbuild/__init__.py \
      --replace-fail ", pkgutil" ", importlib.util" \
      --replace-fail "pkgutil.find_loader" "importlib.util.find_spec"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ pscript ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.13") [
    # https://github.com/manatlan/vbuild/issues/13
    "tests/test_py2js.py"
    "tests/test_PyStdLibIncludeOrNot.py"
    "test_py_comp.py"
  ];

  disabledTests = [
    # Tests require network access
    "test_min"
    "test_pycomp_onlineClosurable"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    "test_ok"
  ];

  pyproject = true;
  pythonImportsCheck = [ "vbuild" ];
  pythonRelaxDeps = [ "pscript" ];

  meta = {
    description = "Module to compile your VueJS components to standalone HTML/JS/CSS";
    homepage = "https://github.com/manatlan/vbuild";
    changelog = "https://github.com/manatlan/vbuild/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
