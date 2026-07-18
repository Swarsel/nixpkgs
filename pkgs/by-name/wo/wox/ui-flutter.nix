{
  lib,
  autoPatchelfHook,
  flutter341,
  keybinder3,
  libx11,
  libxtst,
  wox,
  xorgproto,
}:
flutter341.buildFlutterApplication (finalAttrs: {
  inherit (wox)
    version
    src
    ;

  pname = "wox-ui-flutter";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    keybinder3
    xorgproto
    libx11
    libxtst
  ];

  gitHashes.extended_text_field = "sha256-GOvaWGklfmJKRWYbVTvpZfKj9QMxxlaqrJkfDKR2T0o=";
  gitHashes.windows_gpu_recovery = "sha256-+LQV2wgbQ0ADM2KeRfgbvCHPODBBsq5XrPulXl6GWG8=";
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${finalAttrs.src.name}/wox.ui.flutter/wox";

  meta = {
    inherit (wox.meta)
      description
      homepage
      mainProgram
      platforms
      license
      maintainers
      ;
  };
})
