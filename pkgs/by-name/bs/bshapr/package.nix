{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bshapr";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "BShapr";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-9I4DPRl6i/VL8Etw3qLGZkP45BGsbxFxNOvRy3B3I+M=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    cairo
    lv2
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Beat / envelope shaper LV2 plugin";
    homepage = "https://github.com/sjaehn/BShapr";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
