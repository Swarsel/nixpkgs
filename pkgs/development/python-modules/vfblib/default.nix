{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defcon,
  fonttools,
  gitUpdater,
  orjson,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  typing-extensions,
  ufolib2,
  ufonormalizer,
}:

buildPythonPackage rec {
  pname = "vfblib";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "LucasFonts";
    repo = "vfbLib";
    tag = "v${version}";
    hash = "sha256-AXZKJgZADE0J4WHB6pn/b6K3Jwawyq6j0tRt6HyRkpk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools-scm[toml]>=9.2.0" "setuptools-scm"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fonttools
    orjson
    typing-extensions
    ufonormalizer
    ufolib2
    defcon
  ];

  pyproject = true;
  pythonImportsCheck = [ "vfbLib" ];

  pythonRelaxDeps = [
    "ufonormalizer"
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Converter and deserializer for FontLab Studio 5 VFB files";
    homepage = "https://github.com/LucasFonts/vfbLib";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jopejoe1 ];
  };
}
