{
  lib,
  stdenv,
  fetchFromSourcehut,
  gtk3,
  installShellFiles,
  meson,
  ninja,
  pkg-config,
  wayland,
  wrapGAppsHook3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wofi";
  version = "1.5.3";

  src = fetchFromSourcehut {
    owner = "~scoopta";
    repo = "wofi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rMvDWJx07Q19ieFlt0e3/zx2ZP0jJfURIwMiGFPmLis=";
    vc = "hg";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # https://todo.sr.ht/~scoopta/wofi/121
    ./do_not_follow_symlinks.patch
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wrapGAppsHook3
    installShellFiles
  ];

  buildInputs = [
    wayland
    gtk3
  ];

  postInstall = ''
    installManPage man/wofi*
  '';

  meta = {
    description = "Launcher/menu program for wlroots based wayland compositors such as sway";
    homepage = "https://hg.sr.ht/~scoopta/wofi";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = with lib.platforms; linux;
    mainProgram = "wofi";
  };
})
