{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cups,
  # runtime
  dmidecode,
  gawk,
  glslang,
  gtk3,
  iperf,
  json-glib,
  lerc,
  libdatrie,
  libdecor,
  libepoxy,
  libnghttp2,
  libpsl,
  libsForQt5,
  libselinux,
  libsepol,
  libsoup_3,
  libsysprof-capture,
  libthai,
  libxdmcp,
  libxkbcommon,
  libxtst,
  makeWrapper,
  mesa-demos,
  nix-update-script,
  pcre2,
  pkg-config,
  sqlite,
  sysbench,
  udisks,
  util-linux,
  vulkan-headers,
  vulkan-tools,
  wayland,
  wrapGAppsHook4,
  xdg-utils,
  xrandr,
  printingSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hardinfo2";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "hardinfo2";
    repo = "hardinfo2";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-rrb7iwR5kd7kJSncbE+yzdG55L7IaF7919kLsl/A5pY=";
  };

  patches = [
    ./remove-update.patch
    ./default-no-theme.patch
  ];

  # fix absolute path for xdg-open
  postPatch = ''
    substituteInPlace deps/sysobj_early/gui/uri_handler.c \
      --replace-fail /usr/bin/xdg-open "${lib.getExe' xdg-utils "xdg-open"}"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config

    glslang

    wrapGAppsHook4
    libsForQt5.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    gtk3
    json-glib
    lerc
    libdatrie
    libdecor
    libepoxy
    libnghttp2
    libpsl
    libselinux
    libsepol
    libsoup_3
    libsysprof-capture
    libthai
    libxkbcommon
    pcre2
    sqlite
    util-linux
    libxdmcp
    libxtst
    vulkan-headers
    wayland
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "${placeholder "out"}/share")
    (lib.cmakeFeature "CMAKE_INSTALL_SERVICEDIR" "${placeholder "out"}/lib")
  ];

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapProgram $out/bin/hardinfo2 \
      --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.runtimeLibs}

      substituteInPlace $out/lib/systemd/system/hardinfo2.service \
        --replace-fail "ExecStart=/usr/bin/hwinfo2_fetch_sysdata" "ExecStart=$out/bin/hwinfo2_fetch_sysdata"
  '';

  dontWrapQtApps = true;
  hardeningDisable = [ "fortify" ];

  runtimeDeps = [
    # system stats
    dmidecode
    mesa-demos # glxinfo + vkgears for benchmark

    # display info
    vulkan-tools # vulkaninfo
    xrandr

    # additional tooling for benchmarks
    # https://github.com/hardinfo2/hardinfo2/blob/release-2.2.13/shell/shell.c#L641-L652
    gawk
    iperf
    sysbench
    udisks
  ];

  runtimeLibs = lib.optionals printingSupport [ cups ];
  # account for tags having a release- prefix
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=release-(.*)" ]; };

  meta = {
    description = "System information and benchmarks for Linux systems";
    homepage = "http://www.hardinfo2.org/";
    changelog = "https://github.com/hardinfo2/hardinfo2/releases/tag/release-${finalAttrs.version}";

    license = with lib.licenses; [
      gpl2Plus
      gpl3Plus
      lgpl2Plus
    ];

    maintainers = with lib.maintainers; [
      sigmanificient
      jk
    ];

    platforms = lib.platforms.linux;
    mainProgram = "hardinfo2";
    downloadPage = "https://github.com/hardinfo2/hardinfo2/";
  };
})
