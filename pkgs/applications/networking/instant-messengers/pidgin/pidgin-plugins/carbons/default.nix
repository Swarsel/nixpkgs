{
  lib,
  stdenv,
  fetchFromGitHub,
  libxml2,
  pidgin,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "pidgin-carbons";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "gkdr";
    repo = "carbons";
    rev = "v${version}";
    sha256 = "sha256-qiyIvmJbRmCrAi/93UxDVtO76nSdtzUVfT/sZGxxAh8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxml2
    pidgin
  ];

  makeFlags = [ "PURPLE_PLUGIN_DIR=$(out)/lib/pidgin" ];

  meta = {
    description = "XEP-0280: Message Carbons plugin for libpurple";
    homepage = "https://github.com/gkdr/carbons";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
