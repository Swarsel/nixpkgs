{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gnum4,
  intel-gpu-tools,
  libGL,
  libdrm,
  libva,
  libx11,
  libxext,
  nix-update-script,
  pkg-config,
  python3,
  vaapi-intel-hybrid,
  wayland,
  wayland-scanner,
  enableGui ? true,
  enableHybridCodec ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "intel-vaapi-driver";
  version = "2.4.5";

  src = fetchFromGitHub {
    owner = "irql-notlessorequal";
    repo = "intel-vaapi-driver";
    tag = finalAttrs.version;
    hash = "sha256-exQBA42jCmwybE7WIfF83cjmzBdtluDzUtOdqt49HSg=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gnum4
    pkg-config
    python3
    wayland-scanner
  ];

  buildInputs = [
    intel-gpu-tools
    libdrm
    libva
  ]
  ++ lib.optionals enableGui [
    libx11
    libxext
    libGL
    wayland
  ]
  ++ lib.optional enableHybridCodec vaapi-intel-hybrid;

  configureFlags = [
    (lib.enableFeature enableGui "x11")
    (lib.enableFeature enableGui "wayland")
  ]
  ++ lib.optional enableHybridCodec "--enable-hybrid-codec";

  # Set the correct install path:
  env.LIBVA_DRIVERS_PATH = "${placeholder "out"}/lib/dri";

  postInstall = lib.optionalString enableHybridCodec ''
    ln -s ${vaapi-intel-hybrid}/lib/dri/* $out/lib/dri/
  '';

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "VA-API user mode driver for Intel GEN Graphics family";

    longDescription = ''
      This VA-API video driver backend provides a bridge to the GEN GPUs through
      the packaging of buffers and commands to be sent to the i915 driver for
      exercising both hardware and shader functionality for video decode,
      encode, and processing.
      VA-API is an open-source library and API specification, which provides
      access to graphics hardware acceleration capabilities for video
      processing. It consists of a main library and driver-specific acceleration
      backends for each supported hardware vendor.
    '';

    homepage = "https://github.com/irql-notlessorequal/intel-vaapi-driver";
    changelog = "https://github.com/irql-notlessorequal/intel-vaapi-driver/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
})
