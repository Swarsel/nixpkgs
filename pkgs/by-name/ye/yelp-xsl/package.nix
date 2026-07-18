{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gnome,
  itstool,
  libxslt,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yelp-xsl";
  version = "49.0";

  src = fetchurl {
    url = "mirror://gnome/sources/yelp-xsl/${lib.versions.major finalAttrs.version}/yelp-xsl-${finalAttrs.version}.tar.xz";
    hash = "sha256-WdQ6j4/me3hPFPmgTdSnoJKn9KZKZecbkP4CpHpQ++w=";
  };

  postPatch = ''
    patchShebangs \
      xslt/common/domains/gen_yelp_xml.sh
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gettext
    itstool
    libxslt
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "yelp-xsl";
    };
  };

  meta = {
    description = "Yelp's universal stylesheets for Mallard and DocBook";
    homepage = "https://gitlab.gnome.org/GNOME/yelp-xsl";

    license = with lib.licenses; [
      # See https://gitlab.gnome.org/GNOME/yelp-xsl/blob/master/COPYING
      # Stylesheets
      lgpl2Plus
      # Icons, unclear: https://gitlab.gnome.org/GNOME/yelp-xsl/issues/25
      gpl2
      # highlight.js
      bsd3
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
