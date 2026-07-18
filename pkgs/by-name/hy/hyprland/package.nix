{
  lib,
  fetchFromGitHub,
  aquamarine,
  binutils,
  cairo,
  cmake,
  epoll-shim,
  gcc15Stdenv,
  glaze,
  glslang,
  hyprcursor,
  hyprgraphics,
  hyprland-qtutils,
  hyprlang,
  hyprutils,
  hyprwayland-scanner,
  hyprwire,
  lcms2,
  libGL,
  libdrm,
  libexecinfo,
  libgbm,
  libinput,
  libuuid,
  libxcb,
  libxcb-errors,
  libxcb-wm,
  libxcursor,
  libxdmcp,
  libxkbcommon,
  lua5_5,
  makeWrapper,
  muparser,
  pango,
  pciutils,
  pkg-config,
  pkgconf,
  python3,
  re2,
  stdenvAdapters,
  systemd,
  tomlplusplus,
  uwsm,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xwayland,
  debug ? false,
  enableXWayland ? true,
  withSystemd ? lib.meta.availableOn gcc15Stdenv.hostPlatform systemd,
  wrapRuntimeDeps ? true,
}:
let
  inherit (builtins)
    foldl'
    ;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists)
    concatLists
    optionals
    ;
  inherit (lib.strings)
    makeBinPath
    optionalString
    cmakeBool
    ;
  inherit (lib.trivial)
    importJSON
    ;

  info = importJSON ./info.json;

  # possibility to add more adapters in the future, such as keepDebugInfo,
  # which would be controlled by the `debug` flag
  # Condition on darwin to avoid breaking eval for darwin in CI,
  # even though darwin is not supported anyway.
  adapters = lib.optionals (!gcc15Stdenv.targetPlatform.isDarwin) [
    stdenvAdapters.useMoldLinker
  ];

  customStdenv = foldl' (acc: adapter: adapter acc) gcc15Stdenv adapters;
in
customStdenv.mkDerivation (finalAttrs: {
  pname = "hyprland" + optionalString debug "-debug";
  version = "0.55.4";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IuT0HnOr/0rAw+GXr+OwWx89FjA4Og1FqP7vywEwRJM=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "man"
    "dev"
  ];

  postPatch = ''
    # Fix hardcoded paths to /usr installation
    substituteInPlace src/render/types.hpp \
      --replace-fail /usr $out

    # Remove extra @PREFIX@ to fix pkg-config paths
    substituteInPlace hyprland.pc.in \
      --replace-fail  "@PREFIX@/" ""
    substituteInPlace example/hyprland.desktop.in \
      --replace-fail  "@PREFIX@/" ""
    substituteInPlace systemd/hyprland-uwsm.desktop \
      --replace-fail "Exec=uwsm " "Exec=${lib.getExe uwsm} " \
      --replace-fail "TryExec=uwsm" "TryExec=${lib.getExe uwsm}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    hyprwayland-scanner
    hyprwire
    makeWrapper
    cmake
    pkg-config
    wayland-scanner
    # for udis86
    python3
  ];

  buildInputs = concatLists [
    [
      aquamarine
      cairo
      glaze
      glslang
      hyprcursor.dev
      hyprgraphics
      hyprlang
      hyprutils
      lcms2
      libGL
      libdrm
      libgbm
      libinput
      libuuid
      libxcursor
      libxkbcommon
      lua5_5
      muparser
      pango
      pciutils
      re2
      tomlplusplus
      wayland
      wayland-protocols
    ]
    (optionals customStdenv.hostPlatform.isBSD [ epoll-shim ])
    (optionals customStdenv.hostPlatform.isMusl [ libexecinfo ])
    (optionals enableXWayland [
      libxcb
      libxcb-errors
      libxcb-wm
      libxdmcp
      xwayland
    ])
    (optionals withSystemd [ systemd ])
  ];

  cmakeFlags = mapAttrsToList cmakeBool {
    "BUILT_WITH_NIX" = true;
    "CMAKE_DISABLE_PRECOMPILE_HEADERS" = true;
    "NO_SYSTEMD" = !withSystemd;
    "NO_UWSM" = !withSystemd;
    "NO_XWAYLAND" = !enableXWayland;
    "TRACY_ENABLE" = false;
  };

  # variables used by CMake, and shown in `hyprctl version`
  env = {
    GIT_BRANCH = info.branch;
    # The amount of commits altogether. Not really worth getting that info from
    # GitHub's API, so we set a dummy value.
    GIT_COMMITS = "-1";
    GIT_COMMIT_DATE = info.date;
    GIT_COMMIT_HASH = info.commit_hash;
    GIT_COMMIT_MESSAGE = info.commit_message;
    GIT_DIRTY = "clean";
    GIT_TAG = info.tag;
  };

  postInstall = ''
    ${optionalString wrapRuntimeDeps ''
      wrapProgram $out/bin/Hyprland \
        --suffix PATH : ${
          makeBinPath [
            binutils
            hyprland-qtutils
            pciutils
            pkgconf
          ]
        }
    ''}
  '';

  cmakeBuildType = if debug then "Debug" else "RelWithDebInfo";

  depsBuildBuild = [
    # to find wayland-scanner when cross-compiling
    pkg-config
  ];

  dontStrip = debug;
  separateDebugInfo = !debug;

  passthru = {
    providedSessions = [ "hyprland" ] ++ optionals withSystemd [ "hyprland-uwsm" ];
    updateScript = ./update.sh;
  };

  meta = {
    description = "Dynamic tiling Wayland compositor that doesn't sacrifice on its looks";
    homepage = "https://github.com/hyprwm/Hyprland";
    changelog = "https://github.com/hyprwm/Hyprland/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    mainProgram = "Hyprland";
    teams = [ lib.teams.hyprland ];
  };
})
