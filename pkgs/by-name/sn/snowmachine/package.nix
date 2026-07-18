{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "snowmachine";
  version = "2.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-GhCfiMPEYa9EGCyVDncqKtLKpSN0SwIQ0XnmGEXBQ5I=";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    colorama
    hatchling
  ];

  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "snowmachine" ];

  meta = {
    description = "Python script that will make your terminal snow";
    homepage = "https://github.com/sontek/snowmachine";
    license = with lib.licenses; [ bsd3 ];

    maintainers = with lib.maintainers; [
      djanatyn
      sontek
    ];

    mainProgram = "snowmachine";
  };
})
