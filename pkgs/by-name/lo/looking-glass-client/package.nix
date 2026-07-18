{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  expat,
  fontconfig,
  freefont_ttf,
  libGL,
  libbfd,
  libffi,
  libsamplerate,
  libx11,
  libxcursor,
  libxdmcp,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxpresent,
  libxrandr,
  libxscrnsaver,
  nanosvg,
  nettle,
  pipewire,
  pkg-config,
  pulseaudio,
  spice-protocol,
  wayland,
  wayland-protocols,
  wayland-scanner,
  openGLSupport ? true,
  pipewireSupport ? true,
  pulseSupport ? true,
  waylandSupport ? true,
  xorgSupport ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "looking-glass-client";
  version = "B7";

  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = finalAttrs.version;
    hash = "sha256-I84oVLeS63mnR19vTalgvLvA5RzCPTXV+tSsw+ImDwQ=";
    fetchSubmodules = true;
  };

  patches = [
    ./nanosvg-unvendor.diff
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libx11
    libGL
    freefont_ttf
    spice-protocol
    expat
    libbfd
    nettle
    fontconfig
    libffi
    nanosvg
  ]
  ++ lib.optionals xorgSupport [
    libxkbcommon
    libxi
    libxscrnsaver
    libxinerama
    libxcursor
    libxpresent
    libxext
    libxrandr
    libxdmcp
  ]
  ++ lib.optionals waylandSupport [
    libxkbcommon
    wayland
    wayland-protocols
  ]
  ++ lib.optionals pipewireSupport [
    pipewire
    libsamplerate
  ]
  ++ lib.optionals pulseSupport [
    pulseaudio
    libsamplerate
  ];

  cmakeFlags = [
    "-DOPTIMIZE_FOR_NATIVE=OFF"
  ]
  ++ lib.optionals (!openGLSupport) [ "-DENABLE_OPENGL=no" ]
  ++ lib.optionals (!xorgSupport) [ "-DENABLE_X11=no" ]
  ++ lib.optionals (!waylandSupport) [ "-DENABLE_WAYLAND=no" ]
  ++ lib.optionals (!pulseSupport) [ "-DENABLE_PULSEAUDIO=no" ]
  ++ lib.optionals (!pipewireSupport) [ "-DENABLE_PIPEWIRE=no" ];

  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp $src/resources/lg-logo.png $out/share/pixmaps
  '';

  postUnpack = ''
    echo ${finalAttrs.src.rev} > source/VERSION
    export sourceRoot="source/client"
  '';

  meta = {
    description = "KVM Frame Relay (KVMFR) implementation";

    longDescription = ''
      Looking Glass is an open source application that allows the use of a KVM
      (Kernel-based Virtual Machine) configured for VGA PCI Pass-through
      without an attached physical monitor, keyboard or mouse. This is the final
      step required to move away from dual booting with other operating systems
      for legacy programs that require high performance graphics.
    '';

    homepage = "https://looking-glass.io/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      alexbakker
      babbaj
      j-brn
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "looking-glass-client";
  };
})
