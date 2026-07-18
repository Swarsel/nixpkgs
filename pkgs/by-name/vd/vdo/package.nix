{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libuuid,
  lvm2_dmeventd, # <libdevmapper-event.h>
  python3,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "vdo";
  version = "8.3.2.1";

  src = fetchFromGitHub {
    owner = "dm-vdo";
    repo = "vdo";
    rev = version;
    hash = "sha256-y3u9f17jMV9dwhfJrsW/GOqszVNvPLDyETfku1t3Djo=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    libuuid
    lvm2_dmeventd
    zlib
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyyaml
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "INSTALLOWNER="
    # all of these paths are relative to DESTDIR and have defaults that don't work for us
    "bindir=/bin"
    "defaultdocdir=/share/doc"
    "mandir=/share/man"
    "python3_sitelib=${python3.sitePackages}"
  ];

  postInstall = ''
    installShellCompletion --bash $out/usr/share/bash-completion/completions/*
    rm -rv $out/usr

    wrapPythonPrograms
  '';

  enableParallelBuilding = true;
  pythonPath = propagatedBuildInputs;

  meta = {
    description = "Set of userspace tools for managing pools of deduplicated and/or compressed block storage";
    homepage = "https://github.com/dm-vdo/vdo";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];

    # platforms are defined in https://github.com/dm-vdo/vdo/blob/master/utils/uds/atomicDefs.h
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "s390-linux"
      "powerpc64-linux"
      "powerpc64le-linux"
    ];
  };
}
