{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  coreutils,
  glibc,
  gnugrep,
  gnused,
  libx11,
  makeWrapper,
  ncurses,
  util-linux,
  xterm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bashrun2";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "hbekel";
    repo = "bashrun2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U2ntplhyv8KAkaMd2D6wRsUIYkhJzxdgHo2xsbNRfqM=";
  };

  patches = [
    ./remote-permissions.patch
  ];

  postPatch = ''
    substituteInPlace \
      man/bashrun2.1 \
      --replace-fail '/usr/bin/brwctl' "$out/bin/brwctl"

    substituteInPlace \
      src/bindings \
      src/registry \
      src/utils \
      src/bashrun2 \
      src/frontend \
      src/remote \
      src/plugin \
      src/engine \
      src/bookmarks \
      --replace-fail '/bin/rm' '${coreutils}/bin/rm'

    substituteInPlace \
      src/bashrun2 \
      --replace-fail '#!/usr/bin/env bash' '#!${lib.getExe bashInteractive}'

    substituteInPlace \
      src/remote \
      --replace-fail '/bin/cp' '${coreutils}/bin/cp'
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    libx11
  ];

  postFixup = ''
    wrapProgram $out/bin/bashrun2 \
      --prefix PATH : "$out/bin:${
        lib.makeBinPath [
          ncurses
          coreutils
          gnused
          gnugrep
          glibc
          bashInteractive
          xterm
          util-linux
        ]
      }" \
      --prefix XDG_CONFIG_DIRS : "$out/etc/xdg"
  '';

  meta = {
    description = "Application launcher based on a modified bash session in a small terminal window";
    homepage = "http://henning-liebenau.de/bashrun2/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dopplerian ];
    mainProgram = "bashrun2";
  };
})
