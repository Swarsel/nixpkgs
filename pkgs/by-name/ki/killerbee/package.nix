{
  lib,
  fetchFromGitHub,
  libgcrypt,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "killerbee";
  version = "3.0.0-beta.2";

  src = fetchFromGitHub {
    owner = "riverloopsec";
    repo = "killerbee";
    tag = finalAttrs.version;
    hash = "sha256-WM0Z6sd8S71F8FfhhoUq3MSD/2uvRTY/FsBP7VGGtb0=";
  };

  buildInputs = [ libgcrypt ];
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    pycrypto
    pyserial
    pyusb
    rangeparser
    scapy
  ];

  pyproject = true;
  pythonImportsCheck = [ "killerbee" ];

  meta = {
    description = "IEEE 802.15.4/ZigBee Security Research Toolkit";
    homepage = "https://github.com/riverloopsec/killerbee";
    changelog = "https://github.com/riverloopsec/killerbee/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux;
  };
})
