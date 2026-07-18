{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  jansson,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libjwt";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "benmcollins";
    repo = "libjwt";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-0gFMeSW4gfbI6MUctcN8UuKhMDswaT8BzHTV2VuwZzc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    jansson
    openssl
  ];

  meta = {
    description = "JWT C Library";
    homepage = "https://github.com/benmcollins/libjwt";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ pnotequalnp ];
    platforms = lib.platforms.all;
  };
})
