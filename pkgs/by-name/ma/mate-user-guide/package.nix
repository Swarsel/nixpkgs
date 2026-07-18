{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  itstool,
  libxml2,
  yelp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-user-guide";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-user-guide-${finalAttrs.version}.tar.xz";
    sha256 = "U+8IFPUGVEYU7WGre+UiHMjTqfFPfvlpjJD+fkYBS54=";
  };

  postPatch = ''
    substituteInPlace mate-user-guide.desktop.in.in \
      --replace-fail "Exec=yelp" "Exec=${yelp}/bin/yelp"
  '';

  nativeBuildInputs = [
    itstool
    gettext
    libxml2
  ];

  buildInputs = [
    yelp
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-user-guide";
  };

  meta = {
    description = "MATE User Guide";
    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      gpl2Plus
      fdl11Plus
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
