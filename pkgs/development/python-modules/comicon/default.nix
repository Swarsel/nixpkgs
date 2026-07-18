{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ebooklib,
  lxml,
  nix-update-script,
  pillow,
  poetry-core,
  pypdf,
  python-slugify,
}:

buildPythonPackage rec {
  pname = "comicon";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "potatoeggy";
    repo = "comicon";
    tag = "v${version}";
    hash = "sha256-E5Jmk/dQcEuH7kq5RL80smHUuL/Sw0F1wk4V1/4sKSQ=";
  };

  doCheck = false; # test artifacts are not public

  build-system = [
    poetry-core
  ];

  dependencies = [
    ebooklib
    lxml
    pillow
    pypdf
    python-slugify
  ];

  pyproject = true;
  pythonImportsCheck = [ "comicon" ];

  pythonRelaxDeps = [
    "ebooklib"
    "lxml"
    "pillow"
    "pypdf"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight comic converter library between CBZ, PDF, and EPUB";
    homepage = "https://github.com/potatoeggy/comicon";
    changelog = "https://github.com/potatoeggy/comicon/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ Scrumplex ];
  };
}
