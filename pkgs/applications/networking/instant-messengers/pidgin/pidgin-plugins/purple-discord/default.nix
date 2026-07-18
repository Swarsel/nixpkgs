{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  imagemagick,
  json-glib,
  pidgin,
}:

stdenv.mkDerivation {
  pname = "purple-discord";
  version = "unstable-2021-10-17";

  src = fetchFromGitHub {
    owner = "EionRobb";
    repo = "purple-discord";
    rev = "b7ac72399218d2ce011ac84bb171b572560aa2d2";
    sha256 = "0xvj9rdvgsvcr55sk9m40y07rchg699l1yr98xqwx7sc2sba3814";
  };

  nativeBuildInputs = [
    imagemagick
    gettext
  ];

  buildInputs = [
    pidgin
    json-glib
  ];

  env = {
    PKG_CONFIG_PURPLE_DATADIR = "${placeholder "out"}/share";
    PKG_CONFIG_PURPLE_PLUGINDIR = "${placeholder "out"}/lib/purple-2";
  };

  meta = {
    description = "Discord plugin for Pidgin";
    homepage = "https://github.com/EionRobb/purple-discord";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ sna ];
    platforms = lib.platforms.linux;
  };
}
