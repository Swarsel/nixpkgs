{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  desktop-file-utils,
  gettext,
  glib,
  gnutls,
  gtk2,
  libbfd,
  libxml2,
  pkg-config,
  zlib,
  enableGui ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtk-gnutella";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "gtk-gnutella";
    repo = "gtk-gnutella";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xVVmPcXIc5RN1j9PYqHaqllKp+8UQ8S2LU0z23QngFs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bison
    desktop-file-utils
    gettext
    pkg-config
  ];

  buildInputs = [
    glib
    gnutls
    libbfd
    libxml2
    zlib
  ]
  ++ lib.optionals enableGui [
    gtk2
  ];

  configureFlags = [
    "--configure-only"
  ]
  ++ lib.optionals (!enableGui) [
    "--topless"
  ];

  # Classic 'incompatible pointer type'
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  postInstall = ''
    install -Dm0444 src/gtk-gnutella.man $out/share/man/man1/gtk-gnutella.1
  '';

  __structuredAttrs = true;
  configureScript = "./build.sh";
  enableParallelBuilding = true;

  meta = {
    description = "GTK Gnutella client, optimized for speed and scalability";
    homepage = "https://gtk-gnutella.sourceforge.net/"; # Code: https://github.com/gtk-gnutella/gtk-gnutella
    changelog = "https://raw.githubusercontent.com/gtk-gnutella/gtk-gnutella/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.doronbehar ];
    platforms = lib.platforms.unix;
    mainProgram = "gtk-gnutella";
    # The last successful Darwin Hydra build was in 2023
    broken = stdenv.hostPlatform.isDarwin;
  };
})
