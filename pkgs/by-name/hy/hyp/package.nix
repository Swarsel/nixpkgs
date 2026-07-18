{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "hyp-server";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1lafjdcn9nnq6xc3hhyizfwh6l69lc7rixn6dx65aq71c913jc15";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Hyperminimal https server";
    homepage = "https://github.com/rnhmjoj/hyp";

    license = with lib.licenses; [
      gpl3Plus
      mit
    ];

    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.unix;
    mainProgram = "hyp";
  };
}
