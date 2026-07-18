{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fsnotifier";
  version = "2024.2.0";

  src = fetchFromGitHub {
    owner = "JetBrains";
    repo = "intellij-community";
    rev = "0f6d9ccb67b8fcad0d802cd76209d503c4ed66a6";
    hash = "sha256-3TAiVvKi50JQRrVG6J7LUJKTiuOTDyKt4DhoA1QmbrM=";
    sparseCheckout = [ "native/fsNotifier/linux" ];
  };

  # fix for hard-links in nix-store, https://github.com/JetBrains/intellij-community/pull/2171
  patches = [ ./fsnotifier.patch ];

  buildPhase = ''
    mkdir -p $out/bin

    $CC -O2 -Wall -Wextra -Wpedantic -D "VERSION=\"${finalAttrs.version}\"" -std=c11 main.c inotify.c util.c -o fsnotifier

    cp fsnotifier $out/bin/fsnotifier
  '';

  sourceRoot = "${finalAttrs.src.name}/native/fsNotifier/linux";

  meta = {
    description = "IntelliJ Platform companion program for watching and reporting file and directory structure modification";
    homepage = "https://github.com/JetBrains/intellij-community/tree/master/native/fsNotifier/linux";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "fsnotifier";
  };
})
