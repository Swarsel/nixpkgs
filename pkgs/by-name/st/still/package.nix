{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  nix-update-script,
  pixman,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "still";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "faergeek";
    repo = "still";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bZo4SvBB5pSdvwxuE3+A2iz1um1kSZQ62chR0lOjpj8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    pixman
    wayland
    wayland-protocols
  ];

  postInstall = ''
    install -Dm644 $src/LICENSE $out/share/licenses/still/LICENSE
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Freeze the screen of a Wayland compositor until a provided command exits";
    homepage = "https://github.com/faergeek/still";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.fazzi ];
    platforms = lib.platforms.linux;
    mainProgram = "still";
  };
})
