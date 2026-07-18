{
  lib,
  buildPythonPackage,
  fetchPypi,
  fire,
  flit-core,
  intelhex,
  libusb1,
  tqdm,
}:

buildPythonPackage rec {
  pname = "nkdfu";
  version = "0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8l913dOCxHKFtpQ83p9RV3sUlu0oT5PVi14FSuYJ9fg=";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    fire
    tqdm
    intelhex
    libusb1
  ];

  # no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "nkdfu" ];

  meta = {
    description = "Python tool for Nitrokeys' firmware update";
    homepage = "https://github.com/Nitrokey/nkdfu";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = [ ];
    mainProgram = "nkdfu";
  };
}
