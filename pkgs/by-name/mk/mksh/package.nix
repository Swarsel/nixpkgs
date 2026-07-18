{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mksh";
  version = "59c";

  src = fetchurl {
    hash = "sha256-d64WZaM38cSMYda5Yds+UhGbOOWIhNHIloSvMfh7xQY=";

    urls = [
      "http://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-R${finalAttrs.version}.tgz"
      "http://pub.allbsd.org/MirOS/dist/mir/mksh/mksh-R${finalAttrs.version}.tgz"
    ];
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  buildPhase = ''
    runHook preBuild
    sh ./Build.sh -r
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D mksh $out/bin/mksh
    install -D dot.mkshrc $out/share/mksh/mkshrc
    installManPage mksh.1
    runHook postInstall
  '';

  dontConfigure = true;

  passthru = {
    shellPath = "/bin/mksh";
  };

  meta = {
    description = "MirBSD Korn Shell";

    longDescription = ''
      The MirBSD Korn Shell is a DFSG-free and OSD-compliant (and OSI
      approved) successor to pdksh, developed as part of the MirOS
      Project as native Bourne/POSIX/Korn shell for MirOS BSD, but
      also to be readily available under other UNIX(R)-like operating
      systems.
    '';

    homepage = "http://www.mirbsd.org/mksh.htm";
    changelog = "http://www.mirbsd.org/mksh.htm#clog";

    license = with lib.licenses; [
      miros
      isc
      unicode-dfs-2016
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "mksh";
  };
})
