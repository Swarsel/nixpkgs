{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  gitMinimal,
  mypy-protobuf_3_6,
  pkgs,
  poetry-core,
  protobuf,
  protoletariat,
  pynng,
  pytestCheckHook,
  pythonOlder,
  typing-extensions,
}:
buildPythonPackage (finalAttrs: {
  pname = "kicad-python";
  version = "0.5.0";

  src = fetchFromGitLab {
    owner = "kicad/code";
    repo = "kicad-python";
    tag = finalAttrs.version;
    hash = "sha256-FIWTYBUauq4yUdnijjPgxaXynh/U03ppnLU8YVkKYHw=";
    fetchSubmodules = true;
  };

  # fixes: FileExistsError: File already exists .../kipy/__init__.py
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'script =' "#"
  '';

  nativeBuildInputs = [
    pkgs.protobuf
    mypy-protobuf_3_6
    gitMinimal
  ];

  preBuild = ''
    python build.py
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    poetry-core
    protoletariat
  ];

  dependencies = [
    protobuf
    pynng
  ]
  ++ (lib.optional (pythonOlder "3.13") typing-extensions);

  pyproject = true;
  pythonImportsCheck = [ "kipy" ];
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "KiCad API Python Bindings";
    homepage = "https://kicad.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    downloadPage = "https://gitlab.com/kicad/code/kicad-python";
  };
})
