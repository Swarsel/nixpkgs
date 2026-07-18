{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "key-rack";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "sophie-h";
    repo = "key-rack";
    rev = finalAttrs.version;
    hash = "sha256-mthXtTlyrIChaKKwKosTsV1hK9OQ/zLScjrq6D3CRsg=";
    domain = "gitlab.gnome.org";
  };

  patches = [ ./0001-fix-E0716.patch ];

  postPatch = ''
    patchShebangs --build build-aux/{checks.sh,read-manifest.py}
  '';

  nativeBuildInputs = [
    cargo
    rustc
    meson
    ninja
    pkg-config
    python3
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [ libadwaita ];

  # Workaround for the gettext-sys issue
  # https://github.com/Koka/gettext-rs/issues/114
  env.NIX_CFLAGS_COMPILE = lib.optionalString (
    stdenv.cc.isClang && lib.versionAtLeast stdenv.cc.version "16"
  ) "-Wno-error=incompatible-function-pointer-types";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-iV9ILi3/Uqi8lDHh1Uf2caz6Kc129CDThnqTN9VfUHc=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "View and edit your apps’ keys";
    homepage = "https://gitlab.gnome.org/sophie-h/key-rack";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ getchoo ];
    platforms = lib.platforms.linux;
    mainProgram = "key-rack";
  };
})
