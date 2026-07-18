{
  lib,
  stdenv,
  callPackage,
  fetchFromCodeberg,
  libGL,
  libevdev,
  libinput,
  libx11,
  libxkbcommon,
  pixman,
  pkg-config,
  scdoc,
  udev,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
  xwayland,
  zig_0_16,
  withManpages ? true,
  xwaylandSupport ? true,
}:
let
  wlroots = wlroots_0_20;
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "river-classic";
  version = "0.3.17";

  src = fetchFromCodeberg {
    owner = "river";
    repo = "river-classic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+Geq3AetoiHB8xkMGf9nsYq8Mse2fZ5Edg1iOZ30f1A=";
  };

  outputs = [ "out" ] ++ lib.optionals withManpages [ "man" ];

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    xwayland
    zig
  ]
  ++ lib.optional withManpages scdoc;

  buildInputs = [
    libGL
    libevdev
    libinput
    libxkbcommon
    pixman
    udev
    wayland
    wayland-protocols
    wlroots
  ]
  ++ lib.optional xwaylandSupport libx11;

  postInstall = ''
    install -Dm644 contrib/river.desktop --target-directory=$out/share/wayland-sessions
    install -Dm755 example/init --target-directory=$out/example
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  deps = callPackage ./build.zig.zon.nix { };
  versionCheckProgramArg = "-version";

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ]
  ++ lib.optional withManpages "-Dman-pages"
  ++ lib.optional xwaylandSupport "-Dxwayland";

  passthru = {
    providedSessions = [ "river" ];
    updateScript = ./update.sh;
  };

  meta = {
    description = "Dynamic tiling wayland compositor";

    longDescription = ''
      river-classic is a dynamic tiling Wayland compositor with
      flexible runtime configuration.

      It is a fork of [river](https://codeberg.org/river/river) 0.3
      intended for users that are happy with how river 0.3 works and
      do not wish to deal with the majorly breaking changes from the
      river 0.4.0 release.
    '';

    homepage = "https://codeberg.org/river/river-classic";
    changelog = "https://codeberg.org/river/river-classic/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      adamcstephens
      moni
      rodrgz
    ];

    platforms = lib.platforms.linux;
    mainProgram = "river";
  };
})
