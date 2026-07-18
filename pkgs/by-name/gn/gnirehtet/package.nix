{
  lib,
  stdenv,
  fetchFromGitHub,
  androidenv,
  fetchzip,
  makeWrapper,
  rustPlatform,
}:
let
  version = "2.5.1";
  apk = stdenv.mkDerivation {
    inherit version;
    pname = "gnirehtet.apk";

    src = fetchzip {
      url = "https://github.com/Genymobile/gnirehtet/releases/download/v${version}/gnirehtet-rust-linux64-v${version}.zip";
      hash = "sha256-e1wwMhcco9VNoBUzbEq1ESbkX2bqTOkCbPmnV9CpvGo=";
    };

    installPhase = ''
      mkdir $out
      mv gnirehtet.apk $out
    '';
  };
in
rustPlatform.buildRustPackage rec {
  inherit version;
  pname = "gnirehtet";

  src = fetchFromGitHub {
    owner = "Genymobile";
    repo = "gnirehtet";
    rev = "v${version}";
    hash = "sha256-ewLYCZgkjbh6lR9e4iTddCIrB+5dxyviIXhOqlZsLqc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-xfRTGGlL1/Bq04aGWJSGgkoTGKYiiUAdkHu4zJS3x/U=";

  postInstall = ''
    wrapProgram $out/bin/gnirehtet \
    --set GNIREHTET_APK ${apk}/gnirehtet.apk \
    --set ADB ${androidenv.androidPkgs.platform-tools}/bin/adb
  '';

  sourceRoot = "${src.name}/relay-rust";

  passthru = {
    inherit apk;
  };

  meta = {
    description = "Reverse tethering over adb for Android";

    longDescription = ''
      This project provides reverse tethering over adb for Android: it allows devices to use the internet connection of the computer they are plugged on. It does not require any root access (neither on the device nor on the computer).

      This relies on adb, make sure you have the required permissions/udev rules.
    '';

    homepage = "https://github.com/Genymobile/gnirehtet";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # gnirehtet.apk
    ];

    maintainers = with lib.maintainers; [ symphorien ];
    platforms = lib.platforms.unix;
    mainProgram = "gnirehtet";
  };
}
