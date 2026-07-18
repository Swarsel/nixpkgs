{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pandoc-include";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "pandoc-include";
    tag = "v${version}";
    hash = "sha256-M0frQGg2nHbgY53ejMdbXKLJjXQgx8aNUVxeDDIHdp4=";
  };

  propagatedBuildInputs = with python3Packages; [
    natsort
    panflute
    lxml
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pandoc_include.main" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pandoc filter to allow file and header includes";
    homepage = "https://github.com/DCsunset/pandoc-include";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ppenguin
      DCsunset
    ];

    mainProgram = "pandoc-include";
  };
}
