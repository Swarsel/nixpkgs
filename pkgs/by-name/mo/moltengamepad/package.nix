{
  lib,
  stdenv,
  fetchFromGitHub,
  go-md2man,
  installShellFiles,
  linuxHeaders,
  udev,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "moltengamepad";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "jgeumlek";
    repo = "MoltenGamepad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pfUx5wUkXcshHvBoD47ZRHfJPGHPSzz72H3WBIauFw0=";
  };

  postPatch = ''
    # https://github.com/jgeumlek/MoltenGamepad/pull/99
    sed -e '16i#include <memory>' -i source/core/uinput.h
    sed -e '8i#include <string>' -i source/core/udev.h
  '';

  strictDeps = true;

  nativeBuildInputs = [
    go-md2man
    installShellFiles
  ];

  buildInputs = [ udev ];

  preBuild = ''
    make eventlists INPUT_HEADER=${linuxHeaders}/include/linux/input-event-codes.h
  '';

  installPhase = ''
    runHook preInstall

    installBin moltengamepad
    installManPage documentation/moltengamepad.1

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "Flexible Linux input device translator, geared for gamepads";
    homepage = "https://github.com/jgeumlek/MoltenGamepad";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "moltengamepad";
  };
})
