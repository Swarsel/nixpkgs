{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  meson,
  ninja,
  pkg-config,
  python3,
  testers,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wayland-protocols";
  version = "1.49";

  src = fetchurl {
    url = "https://gitlab.freedesktop.org/wayland/${finalAttrs.pname}/-/releases/${finalAttrs.version}/downloads/${finalAttrs.pname}-${finalAttrs.version}.tar.xz";
    hash = "sha256-7EyPdJQtbf96zotM5HZPDvn/YYqTXZdOp37e4q0kCxQ=";
  };

  postPatch = lib.optionalString finalAttrs.finalPackage.doCheck ''
    patchShebangs tests/
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    wayland-scanner
  ];

  mesonFlags = [ "-Dtests=${lib.boolToString finalAttrs.finalPackage.doCheck}" ];

  doCheck =
    stdenv.hostPlatform == stdenv.buildPlatform
    &&
      # https://gitlab.freedesktop.org/wayland/wayland-protocols/-/issues/48
      stdenv.hostPlatform.linker == "bfd"
    &&
      # Even with bfd linker, the above issue occurs on platforms with stricter linker requirements
      # https://gitlab.freedesktop.org/wayland/wayland-protocols/-/issues/48#note_1453201
      !(stdenv.hostPlatform.isPower64 && stdenv.hostPlatform.isBigEndian)
    && lib.meta.availableOn stdenv.hostPlatform wayland;

  nativeCheckInputs = [
    python3
    wayland
  ];

  checkInputs = [ wayland ];
  depsBuildBuild = [ pkg-config ];

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
  };

  passthru.updateScript = gitUpdater {
    url = "https://gitlab.freedesktop.org/wayland/wayland-protocols.git";
  };

  passthru.version = finalAttrs.version;

  meta = {
    description = "Wayland protocol extensions";

    longDescription = ''
      wayland-protocols contains Wayland protocols that add functionality not
      available in the Wayland core protocol. Such protocols either add
      completely new functionality, or extend the functionality of some other
      protocol either in Wayland core, or some other protocol in
      wayland-protocols.
    '';

    homepage = "https://gitlab.freedesktop.org/wayland/wayland-protocols";
    license = lib.licenses.mit; # Expat version
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "wayland-protocols" ];
  };
})
