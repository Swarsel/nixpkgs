{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  nixosTests,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "darktile";
  version = "0.0.11";

  src = fetchFromGitHub {
    owner = "liamg";
    repo = "darktile";
    rev = "v${finalAttrs.version}";
    hash = "sha256-M3vySAyYwqscR9n0GGXp1ttO/mhdSCponZNYJRBBI18=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxcursor
    libxrandr
    libxinerama
    libxi
    libxext
    libxxf86vm
    libGL
  ];

  vendorHash = null;
  passthru.tests.test = nixosTests.terminal-emulators.darktile;

  meta = {
    description = "GPU rendered terminal emulator designed for tiling window managers";
    homepage = "https://github.com/liamg/darktile";
    changelog = "https://github.com/liamg/darktile/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mikaelfangel ];
    platforms = lib.platforms.linux;
    badPlatforms = [ "aarch64-linux" ];
    mainProgram = "darktile";
    downloadPage = "https://github.com/liamg/darktile/releases";
  };
})
