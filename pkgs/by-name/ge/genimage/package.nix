{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gettext,
  libconfuse,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "genimage";
  version = "20";

  src = fetchFromGitHub {
    owner = "pengutronix";
    repo = "genimage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6pKqvpoEQWebubl6K5FzEAv2aUsBXgOBEAdcCwARkrU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libconfuse
    gettext
  ];

  postInstall = ''
    # As there is no manpage or built-in --help, add the README file for
    # documentation.
    docdir="$out/share/doc/genimage"
    mkdir -p "$docdir"
    cp -v README.rst "$docdir"
  '';

  meta = {
    description = "Generate filesystem images from directory trees";
    homepage = "https://git.pengutronix.de/cgit/genimage";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.all;
    mainProgram = "genimage";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
