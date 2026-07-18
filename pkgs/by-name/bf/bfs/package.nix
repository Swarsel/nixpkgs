{
  lib,
  stdenv,
  fetchFromGitHub,
  acl,
  attr,
  libcap,
  liburing,
  oniguruma,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bfs";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "tavianator";
    repo = "bfs";
    tag = finalAttrs.version;
    hash = "sha256-+hGxdsk9MU5MVvvx3C2cqomboNxD0UZ5y7t84fAwfqs=";
  };

  buildInputs = [
    oniguruma
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    acl
    attr
    libcap
    liburing
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  # The configure script is not from GNU autotools, so most options injected by Nix are not supported
  configurePhase = ''
    runHook preConfigure
    ./configure --prefix=$out --enable-release
    runHook postConfigure
  '';

  meta = {
    description = "Breadth-first version of the UNIX find command";

    longDescription = ''
      bfs is a variant of the UNIX find command that operates breadth-first rather than
      depth-first. It is otherwise intended to be compatible with many versions of find.
    '';

    homepage = "https://github.com/tavianator/bfs";
    license = lib.licenses.bsd0;

    maintainers = with lib.maintainers; [
      yesbox
      cafkafk
    ];

    platforms = lib.platforms.unix;
    mainProgram = "bfs";
  };
})
