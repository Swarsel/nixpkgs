{
  lib,
  fetchurl,
  gccStdenv,
}:

gccStdenv.mkDerivation (finalAttrs: {
  pname = "altermime";
  version = "0.3.11";

  src = fetchurl {
    url = "https://pldaniels.com/altermime/altermime-${finalAttrs.version}.tar.gz";
    hash = "sha256-R17ScQWH0k8R0A2vpcP234rHnhO4xdVNLqNVdrV5/Zc=";
  };

  postPatch = ''
    mkdir -p $out/bin
    substituteInPlace Makefile \
      --replace-fail "/usr/local" "$out" \
      --replace-fail "strip " "${gccStdenv.cc.targetPrefix}strip "
  '';

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=format"
    "-Wno-error=format-truncation"
    "-Wno-error=pointer-compare"
    "-Wno-error=memset-elt-size"
    "-Wno-error=restrict"
  ];

  meta = {
    description = "MIME alteration tool";
    license = lib.licenses.sendmail;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.all;
    mainProgram = "altermime";
    downloadPage = "https://pldaniels.com/altermime/";
  };
})
