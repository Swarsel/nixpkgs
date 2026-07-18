{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  loguru,
  pytestCheckHook,
  rich,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "logurich";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "PakitoSec";
    repo = "logurich";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rQuASijZnIPM5+00U7n4+rTBiUILCcCH+UW56NCTr2k=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.20,<0.10.0" "uv_build"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];

  dependencies = [
    loguru
    rich
  ];

  optional-dependencies = {
    click = [
      click
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "logurich" ];
  pythonRelaxDeps = [ "rich" ];

  meta = {
    description = "Logger that combine loguru and rich";
    homepage = "https://github.com/PakitoSec/logurich";
    changelog = "https://github.com/PakitoSec/logurich/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
