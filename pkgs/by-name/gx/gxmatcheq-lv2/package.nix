{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  gcc13Stdenv,
  libx11,
  lv2,
  pkg-config,
  xorgproto,
}:
let
  # see: https://github.com/brummer10/GxMatchEQ.lv2/issues/8
  # Use gcc13 on Linux, but default stdenv (clang) elsewhere
  buildStdenv = if stdenv.hostPlatform.isLinux then gcc13Stdenv else stdenv;
in
buildStdenv.mkDerivation (finalAttrs: {
  pname = "GxMatchEQ.lv2";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "GxMatchEQ.lv2";
    rev = "V${finalAttrs.version}";
    hash = "sha256-4jg6DYkNRuNuQpOnsZfwJAZljBmBRzS6NcJKjv+r7Ss=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    xorgproto
    cairo
    lv2
  ];

  # error: format not a string literal and no format arguments [-Werror=format-security]
  hardeningDisable = [ "format" ];
  installFlags = [ "INSTALL_DIR=$(out)/lib/lv2" ];

  meta = {
    description = "Matching Equalizer to apply EQ curve from one source to another source";
    homepage = "https://github.com/brummer10/GxMatchEQ.lv2";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
  };
})
