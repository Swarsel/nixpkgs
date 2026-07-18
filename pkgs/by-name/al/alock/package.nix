{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gitUpdater,
  imlib2,
  libgcrypt,
  libx11,
  libxrender,
  pam,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alock";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "Arkq";
    repo = "alock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xfPhsXZrTlEqea75SvacDfjM9o21MTudrqfNN9xtdcg=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libx11
    pam
    libgcrypt
    libxrender
    imlib2
  ];

  configureFlags = [
    "--enable-pam"
    "--enable-hash"
    "--enable-xrender"
    "--enable-imlib2"
  ];

  env.PAM_DEFAULT_SERVICE = "login";

  passthru.updateScript = gitUpdater {
    allowedVersions = "\\.";
    rev-prefix = "v";
  };

  meta = {
    description = "Simple screen lock application for X server";

    longDescription = ''
      alock locks the X server until the user enters a password
      via the keyboard. If the authentication was successful
      the X server is unlocked and the user can continue to work.

      alock does not provide any fancy animations like xlock or
      xscreensaver and never will. It's just for locking the current
      X session.
    '';

    homepage = "https://github.com/Arkq/alock";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      chris-martin
    ];

    platforms = lib.platforms.linux;
    mainProgram = "alock";
  };
})
