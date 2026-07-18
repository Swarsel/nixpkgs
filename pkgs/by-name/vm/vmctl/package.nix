{
  lib,
  fetchFromGitHub,
  cdrtools,
  cloud-utils,
  coreutils,
  gawk,
  getopt,
  makeWrapper,
  openssh,
  qemu,
  qemu-utils,
  socat,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "vmctl";
  version = "1.00";

  src = fetchFromGitHub {
    owner = "SamsungDS";
    repo = "vmctl";
    rev = "8cc71d4350f4f5814ffd7a3091a5c1a9d2e25158";
    hash = "sha256-nIJEgd62yq3DKhaMnB2OEaGN/zC5/Z5cTtO3iQEVF44=";
  };

  postPatch = ''
    substituteInPlace vmctl \
      --replace 'BASEDIR="$(dirname "$(readlink -f "''${BASH_SOURCE[0]}")")"' 'BASEDIR="${placeholder "out"}"'
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm555 vmctl -t "$out/bin"
    wrapProgram "$out/bin/vmctl" \
      --set PATH "${
        lib.makeBinPath [
          openssh
          socat
          gawk
          cloud-utils
          cdrtools
          qemu
          qemu-utils
          coreutils
          getopt
        ]
      }"
    cp -r {cmd,common,contrib,lib} $out

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Command line tool focused on NVMe testing in QEMU";
    homepage = "https://github.com/SamsungDS/vmctl";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ panky ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
