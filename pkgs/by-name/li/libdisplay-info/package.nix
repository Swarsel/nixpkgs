{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  hwdata,
  meson,
  ninja,
  pkg-config,
  python3,
  v4l-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdisplay-info";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "emersion";
    repo = "libdisplay-info";
    rev = finalAttrs.version;
    sha256 = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    patchShebangs tool/gen-search-table.py
  '';

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    hwdata
    python3
  ]
  ++ lib.optionals (stdenv.hostPlatform.emulatorAvailable buildPackages) [
    # Only used for tests, which we cannot run without an emulator
    v4l-utils
  ];

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "EDID and DisplayID library";
    homepage = "https://gitlab.freedesktop.org/emersion/libdisplay-info";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pedrohlc ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    mainProgram = "di-edid-decode";
  };
})
