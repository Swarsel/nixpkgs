{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  flex,
  gettext,
  glib,
  nix-update-script,
  pkg-config,
  readline,
  txt2man,
  versionCheckHook,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mdbtools";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "mdbtools";
    repo = "mdbtools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XWkFgQZKx9/pjVNEqfp9BwgR7w3fVxQ/bkJEYUvCXPs=";
  };

  nativeBuildInputs = [
    pkg-config
    bison
    flex
    autoreconfHook
    txt2man
    which
  ];

  buildInputs = [
    glib
    readline
  ];

  configureFlags = [ "--disable-scrollkeeper" ];
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=unused-but-set-variable";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;

  postUnpack = ''
    cp -v ${gettext}/share/gettext/m4/lib-{link,prefix,ld}.m4 source/m4
  '';

  versionCheckProgram = "${placeholder "out"}/bin/mdb-ver";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = ".mdb (MS Access) format tools";
    homepage = "https://mdbtools.github.io/";
    changelog = "https://github.com/mdbtools/mdbtools/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2
    ];

    platforms = lib.platforms.unix;
  };
})
