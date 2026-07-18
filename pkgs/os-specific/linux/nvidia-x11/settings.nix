nvidia_x11: sha256:

{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  dbus,
  fetchpatch,
  gtk2,
  gtk3,
  jansson,
  libglvnd,
  librsvg,
  libvdpau,
  libxext,
  libxrandr,
  libxv,
  libxxf86vm,
  m4,
  pkg-config,
  vulkan-headers,
  wrapGAppsHook3,
  withGtk2 ? false,
  withGtk3 ? true,
}:

let
  src = fetchFromGitHub {
    inherit sha256;
    owner = "NVIDIA";
    repo = "nvidia-settings";
    rev = nvidia_x11.settingsVersion;
  };

  meta = {
    homepage = "https://www.nvidia.com/object/unix.html";
    platforms = nvidia_x11.meta.platforms;
  };

  libXNVCtrl = stdenv.mkDerivation {
    inherit src;
    pname = "libXNVCtrl";
    version = nvidia_x11.settingsVersion;

    patches = [
      # Patch the Makefile to also produce a shared library.
      (
        if lib.versionOlder nvidia_x11.settingsVersion "400" then
          ./libxnvctrl-build-shared-3xx.patch
        else
          ./libxnvctrl-build-shared.patch
      )
    ];

    buildInputs = [
      libxrandr
      libxext
    ];

    makeFlags = [
      "OUTPUTDIR=." # src/libXNVCtrl
      "libXNVCtrl.a"
      "libXNVCtrl.so"
    ];

    preBuild = ''
      cd src/libXNVCtrl
    '';

    installPhase = ''
      mkdir -p $out/lib
      mkdir -p $out/include/NVCtrl

      cp libXNVCtrl.a $out/lib
      cp NVCtrl.h     $out/include/NVCtrl
      cp NVCtrlLib.h  $out/include/NVCtrl
      cp -P libXNVCtrl.so* $out/lib
    '';

    meta = meta // {
      description = "NVIDIA NV-CONTROL X extension";
      # https://github.com/NVIDIA/nvidia-settings/commit/edcf9edad9f52f9b10e63d4480bbe88b22dde884
      license = lib.licenses.mit;
    };
  };

  runtimeDependencies = [
    libglvnd
    libxrandr
    libxv
  ];

  runtimeLibraryPath = lib.makeLibraryPath runtimeDependencies;

in

stdenv.mkDerivation {
  inherit src;
  pname = "nvidia-settings";
  version = nvidia_x11.settingsVersion;

  patches =
    lib.optional (lib.versionOlder nvidia_x11.settingsVersion "440") (fetchpatch {
      hash = "sha256-ZwF3dRTYt/hO8ELg9weoz1U/XcU93qiJL2d1aq1Jlak=";
      # fixes "multiple definition of `VDPAUDeviceFunctions'" linking errors
      url = "https://github.com/NVIDIA/nvidia-settings/commit/a7c1f5fce6303a643fadff7d85d59934bd0cf6b6.patch";
    })
    ++
      lib.optional
        (
          (lib.versionAtLeast nvidia_x11.settingsVersion "515.43.04")
          && (lib.versionOlder nvidia_x11.settingsVersion "545.29")
        )
        (fetchpatch {
          hash = "sha256-wKuO5CUTUuwYvsP46Pz+6fI0yxLNpZv8qlbL0TFkEFE=";
          # fix wayland support for compositors that use wl_output version 4
          url = "https://github.com/NVIDIA/nvidia-settings/pull/99/commits/2e0575197e2b3247deafd2a48f45afc038939a06.patch";
        });

  postPatch = lib.optionalString nvidia_x11.useProfiles ''
    sed -i 's,/usr/share/nvidia/,${nvidia_x11.bin}/share/nvidia/,g' src/gtk+-2.x/ctkappprofile.c
  '';

  nativeBuildInputs = [
    pkg-config
    m4
    addDriverRunpath
  ]
  ++ lib.optionals withGtk3 [ wrapGAppsHook3 ];

  buildInputs = [
    jansson
    libxv
    libxrandr
    libxext
    libxxf86vm
    libvdpau
    nvidia_x11
    dbus
    vulkan-headers
  ]
  ++ lib.optionals (withGtk2 || lib.versionOlder nvidia_x11.settingsVersion "525.53") [ gtk2 ]
  ++ lib.optionals withGtk3 [
    gtk3
    librsvg
  ];

  makeFlags = [ "NV_USE_BUNDLED_LIBJANSSON=0" ];

  preBuild = ''
    if [ -e src/libXNVCtrl/libXNVCtrl.a ]; then
      ( cd src/libXNVCtrl
        make $makeFlags
      )
    fi
  '';

  postInstall =
    lib.optionalString (!withGtk2) ''
      rm -f $out/lib/libnvidia-gtk2.so.*
    ''
    + lib.optionalString (!withGtk3) ''
      rm -f $out/lib/libnvidia-gtk3.so.*
    ''
    + ''
      # Install the desktop file and icon.
      # The template has substitution variables intended to be replaced resulting
      # in absolute paths. Because absolute paths break after the desktop file is
      # copied by a desktop environment, make Exec and Icon be just a name.
      sed -i doc/nvidia-settings.desktop \
        -e "s|^Exec=.*$|Exec=nvidia-settings|" \
        -e "s|^Icon=.*$|Icon=nvidia-settings|" \
        -e "s|__NVIDIA_SETTINGS_DESKTOP_CATEGORIES__|Settings|g"
      install doc/nvidia-settings.desktop -D -t $out/share/applications/
      install doc/nvidia-settings.png -D -t $out/share/icons/hicolor/128x128/apps/
    '';

  postFixup = ''
    patchelf --set-rpath "$(patchelf --print-rpath $out/bin/$binaryName):$out/lib:${runtimeLibraryPath}" \
      $out/bin/$binaryName

    addDriverRunpath $out/bin/$binaryName
  '';

  binaryName = if withGtk3 then ".nvidia-settings-wrapped" else "nvidia-settings";
  enableParallelBuilding = true;
  installFlags = [ "PREFIX=$(out)" ];

  passthru = {
    inherit libXNVCtrl;
  };

  meta = meta // {
    description = "Settings application for NVIDIA graphics cards";
    # nvml.h is licensed as part of the cuda developer license.
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "nvidia-settings";
  };
}
