{
  lib,
  stdenv,
  anki,
  buildPythonPackage,
  hatchling,
  swift,
}:

buildPythonPackage (finalAttrs: {
  inherit (anki) version src;
  pname = "anki-mac-helper";
  nativeBuildInputs = [ swift ];

  # This is intended to emulate github:ankitects/anki/qt/mac/helper_build.py,
  # but targets the platform directly instead of universal binary + lipo.
  preBuild = ''
    swiftc \
      -target ${stdenv.hostPlatform.darwinArch}-apple-macos11 \
      -emit-library \
      -module-name ankihelper \
      -O \
      *.swift \
      -o anki_mac_helper/libankihelper.dylib
  '';

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "anki_mac_helper" ];
  sourceRoot = "${finalAttrs.src.name}/qt/mac";

  meta = {
    description = "Small support library for Anki on Macs";
    homepage = "https://github.com/ankitects/anki";
    license = lib.licenses.agpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      euank
      junestepp
      oxij
    ];

    platforms = lib.platforms.darwin;
  };
})
