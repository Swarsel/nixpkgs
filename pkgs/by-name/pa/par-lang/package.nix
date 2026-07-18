{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage {
  pname = "par-lang";
  version = "0-unstable-2026-06-24";

  src = fetchFromGitHub {
    owner = "par-team";
    repo = "par-lang";
    rev = "fb93d7dd2c21a7825a57c74d6f22b250bb25d9bc";
    hash = "sha256-9NKBjOMyemgPX/r7ot/RLut1FqWl8RfuuHhXUnkv1IM=";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-8lG+cKN3/W+LYWhmOfDwGiq6u3nlLJaD5uNABaY0zRY=";
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/par new hello
    diff -U3 --color=auto <($out/bin/par run --package hello 2>&1) <(echo 'Hello, World!')

    runHook postInstallCheck
  '';

  postFixup =
    let
      runtimeDependencies = [
        libGL
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxi
        libxrandr
      ];
    in
    lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath ${lib.makeLibraryPath runtimeDependencies} $out/bin/par
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      desktopName = "Par Playground";
      exec = "par playground %f";
      genericName = "Experimental concurrent programming language";
      name = "par-playground";
    })
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Experimental concurrent programming language";
    homepage = "https://github.com/par-team/par-lang";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "par";
  };
}
