{
  lib,
  fetchFromGitHub,
  bcc,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "ebpf-usb";
  version = "0-unstable-2022-04-03";

  src = fetchFromGitHub {
    owner = "francisrstokes";
    repo = "ebpf-usb";
    rev = "3ab6f0d8c6ece51bbb5cc5e05daa4008eccd70e8";
    hash = "sha256-n3ttFej9sroTqAOgyAejwKT+aMt/z7HlVPV6CVGPNUQ=";
  };

  postPatch = ''
    substituteInPlace ebpf-usb.py \
      --replace '#!/usr/bin/env -S python3 -u' '#!/usr/bin/env python3'
  '';

  # no tests
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 ebpf-usb.py $out/bin/ebpf-usb
    runHook postInstall
  '';

  makeWrapperArgs = [
    "--set PYTHONUNBUFFERED 1"
  ];

  pyproject = false;

  pythonPath = [
    bcc
  ]
  ++ (with python3Packages; [
    hexdump
  ]);

  meta = {
    description = "Python script for USB monitoring using eBPF";
    homepage = "https://github.com/francisrstokes/ebpf-usb";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ mevatron ];
    mainProgram = "ebpf-usb";
  };
}
