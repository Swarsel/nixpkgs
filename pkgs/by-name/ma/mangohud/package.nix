{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  addDriverRunpath,
  appstream,
  coreutils,
  curl,
  dbus,
  glfw,
  glslang,
  gnugrep,
  gnused,
  hwdata,
  libGL,
  libx11,
  libxkbcommon,
  libxrandr,
  linuxPackages,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  pkgsi686Linux,
  python3Packages,
  replaceVars,
  spdlog,
  unzip,
  wayland,
  xdg-utils,
  gamescopeSupport ? true,
  lowerBitnessSupport ? stdenv.hostPlatform.isx86_64, # Support 32 bit on 64bit
  mangoappSupport ? gamescopeSupport,
  mangohudctlSupport ? gamescopeSupport,
  nvidiaSupport ? lib.meta.availableOn stdenv.hostPlatform linuxPackages.nvidia_x11.settings.libXNVCtrl,
  waylandSupport ? true,
  x11Support ? true,
}:

assert lib.assertMsg (
  x11Support || waylandSupport
) "either x11Support or waylandSupport should be enabled";

assert lib.assertMsg (nvidiaSupport -> x11Support) "nvidiaSupport requires x11Support";
assert lib.assertMsg (mangoappSupport -> x11Support) "mangoappSupport requires x11Support";

let
  # Derived from subprojects/imgui.wrap
  imgui = rec {
    version = "1.91.6";

    src = fetchFromGitHub {
      owner = "ocornut";
      repo = "imgui";
      tag = "v${version}";
      hash = "sha256-CLS26CRzzY4vUBgILjSQVvziHMyPGK4fwwcLZcOAzPw=";
    };

    patch = fetchurl {
      hash = "sha256-L3l3EUugfQZVmq+IkKkqTr0lGGWS1ER5VGBaryJEY00=";
      url = "https://wrapdb.mesonbuild.com/v2/imgui_${version}-3/get_patch";
    };
  };

  # Derived from subprojects/implot.wrap
  implot = rec {
    version = "0.16";

    src = fetchFromGitHub {
      owner = "epezent";
      repo = "implot";
      tag = "v${version}";
      hash = "sha256-/wkVsgz3wiUVZBCgRl2iDD6GWb+AoHN+u0aeqHHgem0=";
    };

    patch = fetchurl {
      hash = "sha256-HGsUYgZqVFL6UMHaHdR/7YQfKCMpcsgtd48pYpNlaMc=";
      url = "https://wrapdb.mesonbuild.com/v2/implot_${version}-1/get_patch";
    };
  };

  # Derived from subprojects/vulkan-headers.wrap
  vulkan-headers = rec {
    version = "1.4.346";

    src = fetchFromGitHub {
      owner = "KhronosGroup";
      repo = "Vulkan-Headers";
      tag = "v${version}";
      hash = "sha256-JTBW5CF5hlHWkhCjjRd08hpoAarB5W3FJbHzhQM4YFs=";
    };
  };

  # Derived from subprojects/vulkan-headers.wrap
  vulkan-utility-libraries = rec {
    version = "1.4.346";

    src = fetchFromGitHub {
      owner = "KhronosGroup";
      repo = "Vulkan-Utility-Libraries";
      tag = "v${version}";
      hash = "sha256-FWZe6NdhLmI/3bm3OIK646vkWkIQ5xmBa4jlSVHSnDs=";
    };
  };

  libXNVCtrl = linuxPackages.nvidia_x11.settings.libXNVCtrl;
  mangohud32 = pkgsi686Linux.mangohud;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "mangohud";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DKmVC/YCKQp1XTdGCqZtAqoUuMhE+WUDEEETvcXbn1Y=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  patches = [
    # Add @libraryPath@ template variable to fix loading the preload
    # library and @dataPath@ to support overlaying Vulkan apps without
    # requiring MangoHud to be installed
    ./preload-nix-workaround.patch

    # Hard code dependencies. Can't use makeWrapper since the Vulkan
    # layer can be used without the mangohud executable by setting MANGOHUD=1.
    (replaceVars ./hardcode-dependencies.patch {
      inherit hwdata;
      libGL = libGL;
      libX11 = libx11;
      libdbus = dbus.lib;

      path = lib.makeBinPath [
        coreutils
        curl
        gnugrep
        gnused
        xdg-utils
      ];
    })
  ];

  postPatch = ''
    substituteInPlace bin/mangohud.in \
      --subst-var-by libraryPath ${
        lib.makeSearchPath "lib/mangohud" (
          [
            (placeholder "out")
          ]
          ++ lib.optional lowerBitnessSupport mangohud32
        )
      } \
      --subst-var-by version "${finalAttrs.version}" \
      --subst-var-by dataDir ${placeholder "out"}/share

    (
      cd subprojects
      unzip ${imgui.patch}
      unzip ${implot.patch}
      cp -R --no-preserve=mode,ownership packagefiles/vulkan-headers/* Vulkan-Headers-${vulkan-headers.version}
      cp -R --no-preserve=mode,ownership packagefiles/vulkan-utility-libraries/* ${vulkan-utility-libraries.src} Vulkan-Utility-Libraries-${vulkan-utility-libraries.version}
    )
  '';

  strictDeps = true;

  nativeBuildInputs = [
    addDriverRunpath
    glslang
    python3Packages.mako
    meson
    ninja
    pkg-config
    unzip
  ];

  buildInputs = [
    dbus
    spdlog
  ]
  ++ lib.optional waylandSupport wayland
  ++ lib.optional x11Support libx11
  ++ lib.optional nvidiaSupport libXNVCtrl
  ++ lib.optional (x11Support || waylandSupport) libxkbcommon
  ++ lib.optionals mangoappSupport [
    glfw
    libxrandr
  ];

  mesonFlags = [
    "-Duse_system_spdlog=enabled"
    "-Dtests=disabled" # amdgpu test segfaults in nix sandbox
    (lib.mesonEnable "with_x11" x11Support)
    (lib.mesonEnable "with_wayland" waylandSupport)
    (lib.mesonEnable "with_xnvctrl" nvidiaSupport)
    (lib.mesonBool "mangoapp" mangoappSupport)
    (lib.mesonBool "mangohudctl" mangohudctlSupport)
  ];

  doCheck = true;

  nativeCheckInputs = [
    appstream
  ];

  # Support 32bit Vulkan applications by linking in 32bit Vulkan layers
  # This is needed for the same reason the 32bit preload workaround is needed.
  postInstall = lib.optionalString lowerBitnessSupport ''
    ln -s ${mangohud32}/share/vulkan/implicit_layer.d/MangoHud.x86.json \
      "$out/share/vulkan/implicit_layer.d"
  '';

  postFixup =
    let
      archMap = {
        "i686-linux" = "x86";
        "x86_64-linux" = "x86_64";
      };
      layerPlatform = archMap."${stdenv.hostPlatform.system}" or null;
    in
    # We need to give the different layers separate names or else the loader
    # might try the 32-bit one first, fail and not attempt to load the 64-bit
    # layer under the same name.
    lib.optionalString (layerPlatform != null) ''
      substituteInPlace $out/share/vulkan/implicit_layer.d/MangoHud.${layerPlatform}.json \
        --replace-fail "VK_LAYER_MANGOHUD_overlay" "VK_LAYER_MANGOHUD_overlay_${toString stdenv.hostPlatform.parsed.cpu.bits}"
    ''
    + lib.optionalString nvidiaSupport ''
      # Add OpenGL driver and libXNVCtrl paths to RUNPATH to support NVIDIA cards
      addDriverRunpath "$out/lib/mangohud/libMangoHud.so"
      patchelf --add-rpath ${libXNVCtrl}/lib "$out/lib/mangohud/libMangoHud.so"
    ''
    + lib.optionalString mangoappSupport ''
      addDriverRunpath "$out/bin/mangoapp"
    '';

  # Unpack subproject sources
  postUnpack = ''
    (
      cd "$sourceRoot/subprojects"
      cp -R --no-preserve=mode,ownership ${imgui.src} imgui-${imgui.version}
      cp -R --no-preserve=mode,ownership ${implot.src} implot-${implot.version}
      cp -R --no-preserve=mode,ownership ${vulkan-headers.src} Vulkan-Headers-${vulkan-headers.version}
      cp -R --no-preserve=mode,ownership ${vulkan-utility-libraries.src} Vulkan-Utility-Libraries-${vulkan-utility-libraries.version}
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more";
    homepage = "https://github.com/flightlessmango/MangoHud";
    changelog = "https://github.com/flightlessmango/MangoHud/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kira-bruneau
      zeratax
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mangohud";
  };
})
