{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "kerbrute";
  version = "0.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-ok/yttRSkCaEdV4aM2670qERjgDBll6Oi3L5TV5YEEA=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    impacket
  ];

  # This package does not have any tests
  doCheck = false;

  installCheckPhase = ''
    $out/bin/kerbrute --version
  '';

  format = "setuptools";

  meta = {
    description = "Kerberos bruteforce utility";
    homepage = "https://github.com/TarlogicSecurity/kerbrute";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ applePrincess ];
    mainProgram = "kerbrute";
  };
})
