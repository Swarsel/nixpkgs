{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  cmake,
  installShellFiles,
  libGL,
  libgbm,
  makeWrapper,
  pipectl,
  pkg-config,
  scdoc,
  slurp,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlr-protocols,
  installExampleScripts ? true,
}:

let
  wl-present-binpath = lib.makeBinPath [
    pipectl
    slurp
    (placeholder "out")
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "wl-mirror";
  version = "0.18.5";

  src = fetchFromGitHub {
    owner = "Ferdi265";
    repo = "wl-mirror";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KUS0mN9JpLFBDeztzn+3NnJWQZSDZjeqKTFwhRJf+hI=";
  };

  postPatch = ''
    echo 'v${finalAttrs.version}' > version.txt
    substituteInPlace CMakeLists.txt \
      --replace 'WL_PROTOCOL_DIR "/usr' 'WL_PROTOCOL_DIR "${wayland-protocols}' \
      --replace 'WLR_PROTOCOL_DIR "/usr' 'WLR_PROTOCOL_DIR "${wlr-protocols}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
    scdoc
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    libGL
    libgbm
    wayland
    wayland-protocols
    wlr-protocols
    bash
  ];

  cmakeFlags = [
    "-DINSTALL_EXAMPLE_SCRIPTS=${if installExampleScripts then "ON" else "OFF"}"
    "-DINSTALL_DOCUMENTATION=ON"
    "-DWITH_GBM=ON"
  ];

  postInstall = ''
    installShellCompletion --cmd wl-mirror \
      --bash ../scripts/completions/bash-completions/_wl-mirror \
      --zsh ../scripts/completions/zsh-completions/_wl-mirror

    installShellCompletion --cmd wl-present \
      --bash ../scripts/completions/bash-completions/_wl-present \
      --zsh ../scripts/completions/zsh-completions/_wl-present
  ''
  + lib.optionalString installExampleScripts ''
    wrapProgram $out/bin/wl-present --prefix PATH ":" ${wl-present-binpath}
  '';

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "Simple Wayland output mirror client";
    homepage = "https://github.com/Ferdi265/wl-mirror";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ninelore ];
    platforms = lib.platforms.linux;
    mainProgram = "wl-mirror";
  };
})
