{
  lib,
  stdenv,
  fetchFromGitHub,
  dmidecode,
  ethtool,
  installShellFiles,
  iproute2,
  makeWrapper,
  multipath-tools,
  pciutils,
  sysvinit,
}:
let
  binPath = [
    iproute2
    dmidecode
    ethtool
    pciutils
    multipath-tools
    iproute2
    sysvinit
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "xsos";
  version = "0.7.33";

  src = fetchFromGitHub {
    owner = "ryran";
    repo = "xsos";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VEOY422/+4veMlN9HOtPB/THDiFLNnRfbUJpKjc/cqE=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a xsos $out/bin
    wrapProgram "$out/bin/xsos" --prefix PATH : ${lib.makeBinPath binPath}
    installShellCompletion --bash --name xsos.bash xsos-bash-completion.bash
  '';

  meta = {
    description = "Summarize system info from sosreports";
    homepage = "https://github.com/ryran/xsos";
    license = lib.licenses.gpl3;
    maintainers = [ ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "xsos";
  };
})
