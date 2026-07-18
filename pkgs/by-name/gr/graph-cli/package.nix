{
  lib,
  fetchPypi,
  python3Packages,
  qt5,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "graph-cli";
  version = "0.1.19";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-AOfUgeVgcTtuf5IuLYy1zFTBCjWZxu0OiZzUVXDIaSc=";
    pname = "graph_cli";
  };

  nativeBuildInputs = [ qt5.wrapQtAppsHook ];
  # does not contain tests despite reference in Makefile
  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    numpy
    pandas
    (matplotlib.override { enableQt = true; })
  ];

  dontWrapQtApps = true;
  pyproject = true;
  pythonImportsCheck = [ "graph_cli" ];

  meta = {
    description = "CLI to create graphs from CSV files";
    homepage = "https://github.com/mcastorina/graph-cli/";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = with lib.maintainers; [ leungbk ];
    mainProgram = "graph";
  };
})
