{
  lib,
  stdenv,
  fetchurl,
  fonttosfnt,
  installFonts,
  libfaketime,
  mkfontscale,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "envypn-font";
  version = "1.7.1";

  src = fetchurl {
    url = "https://ywstd.fr/files/p/envypn-font/envypn-font-${finalAttrs.version}.tar.gz";
    sha256 = "bda67b6bc6d5d871a4d46565d4126729dfb8a0de9611dae6c68132a7b7db1270";
  };

  nativeBuildInputs = [
    installFonts
    libfaketime
    fonttosfnt
    mkfontscale
  ];

  buildPhase = ''
    runHook preBuild

    # convert pcf fonts to otb
    for i in *e.pcf.gz; do
      faketime -f "1970-01-01 00:00:01" \
      fonttosfnt -v -o "$(basename "$i" .pcf.gz)".otb "$i"
    done

    runHook postBuild
  '';

  postInstall = ''
    mkfontdir "$out/share/fonts/misc"
  '';

  unpackPhase = ''
    tar -xzf $src --strip-components=1
  '';

  meta = {
    description = ''
      Readable bitmap font inspired by Envy Code R
    '';

    homepage = "http://ywstd.fr/p/pj/#envypn";
    license = lib.licenses.miros;
    maintainers = with lib.maintainers; [ erdnaxe ];
    platforms = lib.platforms.all;
  };
})
