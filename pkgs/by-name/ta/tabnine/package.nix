{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:
let
  sources = lib.importJSON ./sources.json;
  platform =
    if (builtins.hasAttr stdenv.hostPlatform.system sources.platforms) then
      builtins.getAttr (stdenv.hostPlatform.system) sources.platforms
    else
      throw "Not supported on ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  inherit (sources) version;
  pname = "tabnine";

  src = fetchurl {
    inherit (platform) hash;
    url = "https://update.tabnine.com/bundles/${sources.version}/${platform.name}/TabNine.zip";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    install -Dm755 TabNine $out/bin/TabNine
    install -Dm755 TabNine-deep-cloud $out/bin/TabNine-deep-cloud
    install -Dm755 TabNine-deep-local $out/bin/TabNine-deep-local
    install -Dm755 WD-TabNine $out/bin/WD-TabNine
    runHook postInstall
  '';

  dontBuild = true;
  # Work around the "unpacker appears to have produced no directories"
  # case that happens when the archive doesn't have a subdirectory.
  sourceRoot = ".";

  passthru = {
    platform = platform.name;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Smart Compose for code that uses deep learning to help you write code faster";
    homepage = "https://tabnine.com";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.attrNames sources.platforms;
  };
}
