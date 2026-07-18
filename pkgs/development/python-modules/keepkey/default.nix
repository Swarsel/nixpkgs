{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ecdsa,
  hidapi,
  libusb1,
  mnemonic,
  protobuf,
  pytest,
}:

buildPythonPackage rec {
  pname = "keepkey";
  version = "7.2.1";

  src = fetchFromGitHub {
    owner = "keepkey";
    repo = "python-keepkey";
    rev = "v${version}";
    sha256 = "00hqppdj3s9y25x4ad59y8axq94dd4chhw9zixq32sdrd9v8z55a";
  };

  # Remove impossible dependency constraint
  postPatch = "sed -i -e 's|hidapi==|hidapi>=|' setup.py";

  propagatedBuildInputs = [
    ecdsa
    hidapi
    libusb1
    mnemonic
    protobuf
  ];

  # tests requires hardware
  doCheck = false;
  nativeCheckInputs = [ pytest ];
  format = "setuptools";

  meta = {
    description = "KeepKey Python client";
    homepage = "https://github.com/keepkey/python-keepkey";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ np ];
    mainProgram = "keepkeyctl";
  };
}
