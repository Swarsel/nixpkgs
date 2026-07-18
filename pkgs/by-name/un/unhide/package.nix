{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cmake,
  iproute2,
  lsof,
  net-tools,
  pkg-config,
  procps,
  psmisc,
}:

let
  makefile = fetchurl {
    hash = "sha256-bSo3EzpcsFmVvwyPgjCCDOJLbzNpxJ6Eptp2hNK7ZXk=";
    url = "https://gitlab.archlinux.org/archlinux/packaging/packages/unhide/-/raw/27c25ad5e1c6123e89f1f35423a0d50742ae69e9/Makefile";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "unhide";
  version = "20240510";

  src = fetchFromGitHub {
    owner = "YJesus";
    repo = "Unhide";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CcS/rR/jPgbcF09aM4l6z52kwFhdQI1VZOyDF2/X6Us=";
  };

  postPatch = ''
    cp ${makefile} Makefile
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    iproute2
    lsof
    net-tools
    procps
    psmisc
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  dontConfigure = true;

  meta = {
    description = "Forensic tool to find hidden processes and TCP/UDP ports by rootkits/LKMs";
    homepage = "https://github.com/YJesus/Unhide";
    changelog = "https://github.com/YJesus/Unhide/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tochiaha ];
    platforms = lib.platforms.all;
    mainProgram = "unhide";
  };
})
