{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  bison,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cocom";
  version = "0.996";

  src = fetchurl {
    url = "mirror://sourceforge/cocom/cocom-${finalAttrs.version}.tar.gz";
    hash = "sha256-4UOrVW15o17zHsHiQIl8m4qNC2aT5QorbkfX/UsgBRk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    bison
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString (
      [
        "-Wno-error=implicit-int"
        "-Wno-error=implicit-function-declaration"
      ]
      ++ lib.optional stdenv.cc.isGNU "-std=gnu17"
    );

    RANLIB = "${stdenv.cc.targetPrefix}gcc-ranlib";
  };

  autoreconfFlags = "REGEX";
  hardeningDisable = [ "format" ];

  meta = {
    description = "Tool set oriented towards the creation of compilers";
    homepage = "https://cocom.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ puffnfresh ];
    platforms = lib.platforms.unix;
  };
})
