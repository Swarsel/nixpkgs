{
  lib,
  stdenv,
  cli11,
  cmake,
  coreutils,
  ddcutil,
  fetchFromCodeberg,
  fmt,
  libx11,
  libxcb-image,
  libxext,
  nix-update-script,
  nlohmann_json,
  sdbus-cpp,
  spdlog,
  testers,
  udev,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gummy";
  version = "0.6.1";

  src = fetchFromCodeberg {
    owner = "fusco";
    repo = "gummy";
    rev = finalAttrs.version;
    hash = "sha256-ic+kTBoirMX6g79NdNoeFbNNo1LYg/z+nlt/GAB6UyQ=";
  };

  # Fixes the "gummy start" command, without this it cannot find the binary.
  # Setting this through cmake does not seem to work.
  postPatch = ''
    substituteInPlace gummyd/gummyd/api.cpp \
      --replace "CMAKE_INSTALL_DAEMON_PATH" "\"${placeholder "out"}/libexec/gummyd\""
  '';

  nativeBuildInputs = [
    cmake
    udevCheckHook
  ];

  buildInputs = [
    cli11
    ddcutil
    fmt
    libx11
    libxext
    nlohmann_json
    sdbus-cpp
    spdlog
    udev
    libxcb-image
  ];

  cmakeFlags = [
    (lib.mapAttrsToList lib.cmakeFeature {
      "UDEV_DIR" = "${placeholder "out"}/lib/udev";
      "UDEV_RULES_DIR" = "${placeholder "out"}/lib/udev/rules.d";
    })
  ];

  doInstallCheck = true;

  preFixup = ''
    substituteInPlace $out/lib/udev/rules.d/99-gummy.rules \
      --replace "/bin/chmod" "${coreutils}/bin/chmod"

    ln -s $out/libexec/gummyd $out/bin/gummyd
  '';

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Brightness and temperature manager for X11";

    longDescription = ''
      CLI screen manager for X11 that allows automatic and manual brightness/temperature adjustments,
      via backlight (currently only for embedded displays) and gamma. Multiple monitors are supported.
    '';

    homepage = "https://codeberg.org/fusco/gummy";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
})
