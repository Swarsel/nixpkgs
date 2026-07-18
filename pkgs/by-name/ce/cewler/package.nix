{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cewler";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "roys";
    repo = "cewler";
    rev = "v${version}";
    hash = "sha256-Od9O71122jVwqZ5ntoBQQtyNQjt2RRbZT8DzWFPUN84=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pypdf
    rich
    scrapy
    tld
    twisted
  ];

  # Tests require network access
  doCheck = false;
  pyproject = true;
  pythonRelaxDeps = true;
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Custom Word List generator Redefined";
    homepage = "https://github.com/roys/cewler";
    license = lib.licenses.cc-by-nc-40;
    maintainers = with lib.maintainers; [ emilytrau ];
    mainProgram = "cewler";
  };
}
