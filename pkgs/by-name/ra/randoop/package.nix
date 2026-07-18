{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "randoop";
  version = "4.3.4";

  src = fetchurl {
    url = "https://github.com/randoop/randoop/releases/download/v${finalAttrs.version}/randoop-${finalAttrs.version}.zip";
    sha256 = "sha256-yzQw9l3uAq51SHXJ4rsZNRCiFdhOEoSrwv9iPvD2i9c=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/lib $out/doc

    cp -R *.jar $out/lib
    cp README.txt $out/doc
  '';

  meta = {
    description = "Automatic test generation for Java";
    homepage = "https://randoop.github.io/randoop/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
  };
})
