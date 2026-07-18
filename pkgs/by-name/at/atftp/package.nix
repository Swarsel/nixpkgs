{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  gcc,
  makeWrapper,
  pcre2,
  perl,
  ps,
  readline,
  tcp_wrappers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atftp";
  version = "0.8.1";

  src = fetchurl {
    url = "mirror://sourceforge/atftp/atftp-${finalAttrs.version}.tar.gz";
    hash = "sha256-lsvb0vFmFcicnbNr6bMG3hdtmhwD3LjLd3Ylv+BovCs=";
  };

  # fix test script
  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  buildInputs = [
    gcc
    pcre2
    readline
    tcp_wrappers
  ];

  # Expects pre-GCC5 inline semantics
  env.NIX_CFLAGS_COMPILE = "-std=gnu89";
  doCheck = true;

  nativeCheckInputs = [
    perl
    ps
  ];

  meta = {
    description = "Advanced tftp tools";
    homepage = "https://sourceforge.net/projects/atftp/";
    changelog = "https://sourceforge.net/p/atftp/code/ci/v${finalAttrs.version}/tree/Changelog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
  };
})
