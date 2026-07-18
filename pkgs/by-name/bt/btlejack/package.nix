{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "btlejack";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "virtualabs";
    repo = "btlejack";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-Q6y9murV1o2i1sluqTVB5+X3B7ywFsI0ZvlJjHrHSpo=";
  };

  postPatch = ''
    sed -i "s|^.*'argparse',$||" setup.py
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.pyserial
    python3Packages.halo
  ];

  pyproject = true;

  meta = {
    description = "Bluetooth Low Energy Swiss-army knife";
    homepage = "https://github.com/virtualabs/btlejack";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "btlejack";
  };
})
