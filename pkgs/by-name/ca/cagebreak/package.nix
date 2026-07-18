{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  fontconfig,
  libdrm,
  libevdev,
  libinput,
  libxcb-wm,
  libxkbcommon,
  makeWrapper,
  meson,
  ninja,
  nixosTests,
  pango,
  pixman,
  pkg-config,
  scdoc,
  systemd,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_19,
  xwayland,
  withXwayland ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cagebreak";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "project-repo";
    repo = "cagebreak";
    tag = finalAttrs.version;
    hash = "sha256-ADRtfzmn8DmDNbiJO3WbhQZiriJoUAG2TxPmx+RwPXE=";
  };

  postPatch = ''
    # TODO: investigate why is this happening
    sed -i -e 's|<drm_fourcc.h>|<libdrm/drm_fourcc.h>|' *.c

    # Patch cagebreak to read its default configuration from $out/share/cagebreak
    sed -i "s|/etc/xdg/cagebreak|$out/share/cagebreak|" meson.build cagebreak.c
    substituteInPlace meson.build \
      --replace "/usr/share/licenses" "$out/share/licenses"
  '';

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    cairo
    fontconfig
    libdrm
    libevdev
    libinput
    libxkbcommon
    libxcb-wm
    pango
    pixman
    systemd
    wayland
    wayland-protocols
    wlroots_0_19
  ];

  mesonFlags = [
    "-Dman-pages=true"
    "-Dversion_override=${finalAttrs.version}"
    "-Dxwayland=${lib.boolToString withXwayland}"
  ];

  postFixup = lib.optionalString withXwayland ''
    wrapProgram $out/bin/cagebreak \
      --prefix PATH : "${lib.makeBinPath [ xwayland ]}"
  '';

  passthru.tests.basic = nixosTests.cagebreak;

  meta = {
    description = "Wayland tiling compositor inspired by ratpoison";
    homepage = "https://github.com/project-repo/cagebreak";
    changelog = "https://github.com/project-repo/cagebreak/blob/${finalAttrs.version}/Changelog.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "cagebreak";
  };
})
