{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libgcrypt,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libcotp";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "paolostivanin";
    repo = "libcotp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iNmCQHAl2LIkdJiVByc9CWiJSTo1HIz5Ma5Xjo2n9mA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ libgcrypt ];
  __structuredAttrs = true;

  meta = {
    description = "C library that generates TOTP and HOTP";
    homepage = "https://github.com/paolostivanin/libcotp";
    changelog = "https://github.com/paolostivanin/libcotp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alexbakker ];
    platforms = lib.platforms.all;
  };
})
