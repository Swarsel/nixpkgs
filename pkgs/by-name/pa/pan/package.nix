{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  gcr,
  gettext,
  gmime3,
  gnupg,
  gnutls,
  gspell,
  gtk3,
  intltool,
  itstool,
  libnotify,
  libsecret,
  libxml2,
  pkg-config,
  wrapGAppsHook3,
  gnomeSupport ? true,
  spellChecking ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pan";
  version = "0.165";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "pan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y9ejT/XTMoWMLSIOePEtPCUy51JThJrBBOCdSUTk2yc=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
    intltool
    itstool
    libxml2
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gmime3
    libnotify
    gnutls
  ]
  ++ lib.optionals spellChecking [ gspell ]
  ++ lib.optionals gnomeSupport [
    libsecret
    gcr
  ];

  cmakeFlags = [
    (lib.cmakeBool "WANT_GSPELL" spellChecking)
    (lib.cmakeBool "WANT_GKR" gnomeSupport)
    (lib.cmakeBool "ENABLE_MANUAL" true)
    (lib.cmakeBool "WANT_GMIME_CRYPTO" true)
    (lib.cmakeBool "WANT_WEBKIT" false) # We don't have webkitgtk_3_0
    (lib.cmakeBool "WANT_NOTIFY" true)
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ gnupg ]})
  '';

  meta = {
    description = "GTK-based Usenet newsreader good at both text and binaries";
    homepage = "http://pan.rebelbase.com";

    license = with lib.licenses; [
      gpl2Only
      fdl11Only
    ];

    maintainers = with lib.maintainers; [
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pan";
  };
})
