{
  lib,
  fetchFromGitHub,
  aircrack-ng,
  bully,
  cowpatty,
  fetchpatch,
  hashcat,
  hcxdumptool,
  hcxtools,
  iw,
  john,
  macchanger,
  pixiewps,
  python3,
  python3Packages,
  reaverwps-t6x,
  which,
  wirelesstools,
  wireshark-cli,
}:

let
  pythonDependencies = with python3Packages; [
    chardet
    scapy
  ];
in
python3.pkgs.buildPythonApplication rec {
  pname = "wifite2";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "kimocoder";
    repo = "wifite2";
    rev = version;
    hash = "sha256-G2AKKZUDS2UQm95TEhGJIucyMRcm7oL0d3J8uduEQhw=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-BUAowBajfnZ1x6Z3Ce3L0rAERv7v/KrdHcdvKxTxSrM=";
      url = "https://salsa.debian.org/pkg-security-team/wifite/raw/debian/2.7.0-1/debian/patches/Disable-aircrack-failing-test.patch";
    })
    (fetchpatch {
      hash = "sha256-wCwfNkF/GvOU5FWPmQ3dJ4Txthz9T9TO2xhSL5vllQc=";
      url = "https://salsa.debian.org/pkg-security-team/wifite/raw/debian/2.7.0-1/debian/patches/Disable-two-failing-tests.patch";
    })
    (fetchpatch {
      hash = "sha256-8xs+O2ILSRcvsw2pyx2gEBFHdduoI+xmUvDBchKz2Qs=";
      url = "https://salsa.debian.org/pkg-security-team/wifite/raw/debian/2.7.0-1/debian/patches/fix-for-new-which.patch";
    })
  ];

  propagatedBuildInputs = [
    aircrack-ng
    wireshark-cli
    reaverwps-t6x
    cowpatty
    hashcat
    hcxtools
    hcxdumptool
    wirelesstools
    which
    bully
    pixiewps
    john
    iw
    macchanger
  ]
  ++ pythonDependencies;

  nativeCheckInputs = propagatedBuildInputs ++ [ python3.pkgs.unittestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Rewrite of the popular wireless network auditor, wifite";
    homepage = "https://github.com/kimocoder/wifite2";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      lassulus
      danielfullmer
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wifite";
  };
}
