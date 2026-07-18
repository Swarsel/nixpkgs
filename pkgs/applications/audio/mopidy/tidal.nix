{
  lib,
  fetchFromGitHub,
  mopidy,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "Mopidy-Tidal";
  version = "0.3.12";

  src = fetchFromGitHub {
    owner = "EbbLabs";
    repo = "mopidy-tidal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1u1MMLtVNZkVhmUr5DW34TlJ2s/YGRKXjqi+SrtClR4=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [ python3Packages.poetry-core ];

  dependencies = [
    mopidy
    python3Packages.tidalapi
  ];

  enabledTestPaths = [ "tests/" ];
  pyproject = true;

  meta = {
    description = "Mopidy extension for playing music from Tidal";
    homepage = "https://github.com/EbbLabs/mopidy-tidal";
    changelog = "https://github.com/EbbLabs/mopidy-tidal/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
