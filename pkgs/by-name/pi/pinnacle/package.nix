{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  callPackage,
  cargo,
  git,
  libdisplay-info,
  libgbm,
  libglvnd,
  libinput,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  lua54Packages,
  lua5_4,
  makeWrapper,
  mesa,
  pkg-config,
  protobuf,
  rustPlatform,
  rustc,
  seatd,
  systemdLibs,
  wayland,
  xwayland,
  extraLuaPackages ? (ps: [ ]),
}:
let
  version = "0.2.4";
  pinnacle-src = fetchFromGitHub {
    owner = "pinnacle-comp";
    repo = "pinnacle";
    sha256 = "sha256-T8wZjgOTzYKfYUV1ShLBIi2xoCdVn9I7sux/pDH+8ic=";
    tag = "v${version}";
  };
  buildRustConfig = callPackage ./pinnacle-config.nix { inherit pinnacle-src; };

  meta = {
    description = "A WIP Smithay-based Wayland compositor, inspired by AwesomeWM and configured in Lua or Rust";
    homepage = "https://pinnacle-comp.github.io/pinnacle/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ cassandracomar ];
    platforms = lib.platforms.linux;
    mainProgram = "pinnacle";
  };

  lua-client-api = lua54Packages.buildLuarocksPackage rec {
    inherit meta version;
    pname = "pinnacle-client-api";
    src = pinnacle-src;

    propagatedBuildInputs = with lua54Packages; [
      cqueues
      http
      lua-protobuf
      compat53
      luaposix
    ];

    postConfigure = ''
      substituteInPlace "$rockspecFilename" \
        --replace-fail '"compat53 ~> 0.14"' '"compat53 >= 0.14"'
    '';

    postInstall = ''
      mkdir -p $out/share/pinnacle/protobuf/pinnacle
      cp -rL --no-preserve ownership,mode ../../api/protobuf/pinnacle $out/share/pinnacle/protobuf
      mkdir -p $out/share/pinnacle/snowcap/protobuf/snowcap
      cp -rL --no-preserve ownership,mode ../../snowcap/api/protobuf/snowcap $out/share/pinnacle/snowcap/protobuf
      mkdir -p $out/share/pinnacle/protobuf/google
      cp -rL --no-preserve ownership,mode ../../api/protobuf/google $out/share/pinnacle/protobuf
      mkdir -p $out/share/pinnacle/snowcap/protobuf/google
      cp -rL --no-preserve ownership,mode ../../snowcap/api/protobuf/google $out/share/pinnacle/snowcap/protobuf
    '';

    knownRockspec = "${pinnacle-src}/api/lua/rockspecs/pinnacle-api-0.2.4-1.rockspec";
    sourceRoot = "${src.name}/api/lua";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit meta version;
  pname = "pinnacle-server";
  src = pinnacle-src;

  nativeBuildInputs = [
    pkg-config
    protobuf
    lua54Packages.luarocks
    lua5_4
    lua-client-api
    git
    wayland
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    wayland

    # libs
    seatd.dev
    systemdLibs.dev
    libxkbcommon
    libinput
    mesa
    xwayland
    libdisplay-info
    libgbm
    lua5_4

    # winit on x11
    libxcursor
    libxrandr
    libxi
    libx11
  ];

  cargoHash = "sha256-hM19RB2+ejC+OFU4keH+PKWYf5NRUXJ1W33eSUhKR/g=";

  preCheck = ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ wayland ]}";
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  postInstall = ''
    wrapProgram $out/bin/pinnacle --prefix PATH ":" ${
      lib.makeBinPath [
        rustc
        cargo
        finalAttrs.passthru.luaEnv
        xwayland
      ]
    }
    install -m755 ./resources/pinnacle-session $out/bin/pinnacle-session
    mkdir -p $out/share/wayland-sessions
    install -m644 ./resources/pinnacle.desktop $out/share/wayland-sessions/pinnacle.desktop
    patchShebangs $out/bin/pinnacle-session
    mkdir -p $out/share/xdg-desktop-portal
    install -m644 ./resources/pinnacle-portals.conf $out/share/xdg-desktop-portal/pinnacle-portals.conf
    install -m644 ./resources/pinnacle-portals.conf $out/share/xdg-desktop-portal/pinnacle-uwsm-portals.conf
  '';

  __structuredAttrs = true;

  cargoTestFlags = [
    "--exclude"
    "wlcs_pinnacle"
    "--all"
    "--"
    "--skip"
    "process_spawn"
  ];

  checkFeatures = [ "testing" ];
  checkNoDefaultFeatures = true;

  runtimeDependencies = [
    wayland
    mesa
    libglvnd # libEGL
  ];

  passthru = {
    inherit buildRustConfig;
    lua-client-api = lua-client-api;

    luaEnv = lua5_4.withPackages (
      ps:
      [
        finalAttrs.passthru.lua-client-api
        ps.cjson
      ]
      ++ (extraLuaPackages ps)
    );

    providedSessions = [ "pinnacle" ];
  };
})
