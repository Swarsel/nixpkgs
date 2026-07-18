{
  lib,
  stdenv,
  callPackage,
  fetchFromCodeberg,
  libxkbcommon,
  pam,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
  zig_0_16,
}:
let
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "waylock";
  version = "1.6.0";

  src = fetchFromCodeberg {
    owner = "ifreund";
    repo = "waylock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A/XPgoon1J+fmEVUGuqvqbimRRDfLPkzkMYipPaKrfo=";
  };

  postPatch = ''
    substituteInPlace build.zig --replace-fail "1.4.0-dev" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    pkg-config
    scdoc
    wayland-scanner
    zig
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    pam
  ];

  preBuild = ''
    substituteInPlace pam.d/waylock --replace-fail "system-auth" "login"
  '';

  deps = callPackage ./build.zig.zon.nix { };

  zigBuildFlags = [
    "-Dman-pages"
    "--system"
    "${finalAttrs.deps}"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Small screenlocker for Wayland compositors";
    homepage = "https://codeberg.org/ifreund/waylock";
    changelog = "https://codeberg.org/ifreund/waylock/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      adamcstephens
      jordanisaacs
    ];

    platforms = lib.platforms.linux;
    mainProgram = "waylock";
  };
})
