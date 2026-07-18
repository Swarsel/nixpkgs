{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  grim,
  inih,
  libdrm,
  libgbm,
  makeWrapper,
  meson,
  ninja,
  pipewire,
  pkg-config,
  scdoc,
  slurp,
  systemdLibs,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-wlr";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = "xdg-desktop-portal-wlr";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-MBPHRVw1J+z8V8V9v06L9QJl2jM6P3GxXuQ8XDOdah0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
    makeWrapper
  ];

  buildInputs = [
    inih
    libdrm
    libgbm
    pipewire
    systemdLibs
    wayland
    wayland-protocols
  ];

  mesonFlags = [
    "-Dsd-bus-provider=libsystemd"
  ];

  postInstall = ''
    wrapProgram $out/libexec/xdg-desktop-portal-wlr --prefix PATH ":" ${
      lib.makeBinPath [
        bash
        grim
        slurp
      ]
    }
  '';

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "xdg-desktop-portal backend for wlroots";
    homepage = "https://github.com/emersion/xdg-desktop-portal-wlr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ minijackson ];
    platforms = lib.platforms.linux;
  };
})
