{
  lib,
  stdenv,
  fetchurl,
  allegro,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "liquidwar5";
  version = "5.6.6";

  src = fetchurl {
    url = "https://www.ufoot.org/download/liquidwar/v5/${finalAttrs.version}/liquidwar-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-JF2AZuzDiCm9EQ8AiQ6230TgmMgML7yJpG80BFqsQ/c=";
  };

  buildInputs = [ allegro ];
  configureFlags = lib.optional stdenv.hostPlatform.isx86_64 "--disable-asm";

  env.NIX_CFLAGS_COMPILE = toString [
    # Workaround build failure on -fno-common toolchains like upstream
    # gcc-10. Otherwise build fails as:
    #   ld: random.o:(.bss+0x0): multiple definition of `LW_RANDOM_ON'; game.o:(.bss+0x4): first defined here
    "-fcommon"

    "-lm"
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Classic version of a quick tactics game LiquidWar";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
  };
})
