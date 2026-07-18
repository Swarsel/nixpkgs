{
  lib,
  stdenv,
  fetchFromGitLab,
  aml,
  cairo,
  fetchpatch, # Added for applying patch
  freerdp,
  glslang,
  gst_all_1,
  lcms2,
  libGL,
  libdisplay-info_0_2,
  libdrm,
  libevdev,
  libgbm,
  libinput,
  libjpeg,
  libva,
  libwebp,
  libxcb-cursor,
  libxcursor,
  libxkbcommon,
  lua5_4_compat,
  meson,
  neatvnc,
  ninja,
  nix-update-script,
  pam,
  pango,
  pipewire,
  pkg-config,
  python3,
  seatd,
  vulkan-headers,
  vulkan-loader,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xwayland,
  demoSupport ? true,
  jpegSupport ? true,
  lcmsSupport ? true,
  luaSupport ? true,
  pangoSupport ? true,
  pipewireSupport ? true,
  rdpSupport ? true,
  remotingSupport ? true,
  vaapiSupport ? false,
  vncSupport ? true,
  vulkanSupport ? true,
  webpSupport ? true,
  xwaylandSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "weston";
  version = "15.0.1";

  src = fetchFromGitLab {
    owner = "wayland";
    repo = "weston";
    rev = finalAttrs.version;
    hash = "sha256-c6h8GQt1S3t2+K+8A4ncxBtWLtaV61EABdYA55o9i4o=";
    domain = "gitlab.freedesktop.org";
  };

  patches = [
    # backend-vnc, gitlab-ci: Update to Neat VNC 1.0.0, aml 1.0.0
    # https://gitlab.freedesktop.org/wayland/weston/-/merge_requests/2064
    (fetchpatch {
      excludes = [ ".gitlab-ci.yml" ];
      hash = "sha256-9eBONM7OfzHhCuT8Wnq534KS51q2VtUyOOLjYHohEds=";
      url = "https://gitlab.freedesktop.org/wayland/weston/-/commit/8a1c91e771312d1e0d0cd92495ef717402784dae.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    wayland-scanner
  ]
  ++ lib.optional vulkanSupport glslang;

  buildInputs = [
    cairo
    libGL
    libdisplay-info_0_2
    libdrm
    libevdev
    libinput
    libxkbcommon
    libgbm
    seatd
    wayland
    wayland-protocols
  ]
  ++ lib.optional jpegSupport libjpeg
  ++ lib.optional lcmsSupport lcms2
  ++ lib.optional luaSupport lua5_4_compat
  ++ lib.optional pangoSupport pango
  ++ lib.optional pipewireSupport pipewire
  ++ lib.optional rdpSupport freerdp
  ++ lib.optionals remotingSupport [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ]
  ++ lib.optional vaapiSupport libva
  ++ lib.optionals vncSupport [
    aml
    neatvnc
    pam
  ]
  ++ lib.optionals vulkanSupport [
    vulkan-headers
    vulkan-loader
  ]
  ++ lib.optional webpSupport libwebp
  ++ lib.optionals xwaylandSupport [
    libxcursor
    libxcb-cursor
    xwayland
  ];

  mesonFlags = [
    (lib.mesonBool "deprecated-backend-drm-screencast-vaapi" vaapiSupport)
    (lib.mesonBool "backend-pipewire" pipewireSupport)
    (lib.mesonBool "backend-rdp" rdpSupport)
    (lib.mesonBool "backend-vnc" vncSupport)
    (lib.mesonBool "color-management-lcms" lcmsSupport)
    (lib.mesonBool "demo-clients" demoSupport)
    (lib.mesonBool "image-jpeg" jpegSupport)
    (lib.mesonBool "image-webp" webpSupport)
    (lib.mesonBool "pipewire" pipewireSupport)
    (lib.mesonBool "remoting" remotingSupport)
    (lib.mesonBool "renderer-vulkan" vulkanSupport)
    (lib.mesonOption "simple-clients" "")
    (lib.mesonBool "shell-lua" luaSupport)
    (lib.mesonBool "test-junit-xml" false)
    (lib.mesonBool "xwayland" xwaylandSupport)
  ]
  ++ lib.optionals xwaylandSupport [
    (lib.mesonOption "xwayland-path" (lib.getExe xwayland))
  ];

  depsBuildBuild = [ pkg-config ];

  passthru = {
    providedSessions = [ "weston" ];
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lightweight and functional Wayland compositor";

    longDescription = ''
      Weston is the reference implementation of a Wayland compositor, as well
      as a useful environment in and of itself.
      Out of the box, Weston provides a very basic desktop, or a full-featured
      environment for non-desktop uses such as automotive, embedded, in-flight,
      industrial, kiosks, set-top boxes and TVs. It also provides a library
      allowing other projects to build their own full-featured environments on
      top of Weston's core. A small suite of example or demo clients are also
      provided.
    '';

    homepage = "https://gitlab.freedesktop.org/wayland/weston";
    license = lib.licenses.mit; # Expat version

    maintainers = with lib.maintainers; [
      qyliss
    ];

    platforms = lib.platforms.linux;
    mainProgram = "weston";
  };
})
