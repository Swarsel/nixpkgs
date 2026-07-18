{
  lib,
  stdenv,
  fetchzip,
  gtest,
  libgbm,
  libxcb,
  libxkbcommon,
  meson,
  ninja,
  pixman,
  pkg-config,
  python3,
  python3Packages,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "sommelier";
  version = "126.0";

  src = fetchzip rec {
    url = "https://chromium.googlesource.com/chromiumos/platform2/+archive/${passthru.rev}/vm_tools/sommelier.tar.gz";
    sha256 = "BmWZnMcK7IGaEAkVPulyb3hngsmuI0D1YtQEbqMjV5c=";
    stripRoot = false;
    passthru.rev = "fd3798efe23f2edbc48f86f2fbd82ba5059fd875";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    python3Packages.jinja2
    wayland-scanner
  ];

  buildInputs = [
    libxkbcommon
    libgbm
    pixman
    wayland
    libxcb
  ];

  preConfigure = ''
    patchShebangs gen-shim.py
  '';

  doCheck = true;
  nativeCheckInputs = [ gtest ];

  postInstall = ''
    rm $out/bin/sommelier_test # why does it install the test binary? o_O
  '';

  passthru.updateScript = ./update.py;

  meta = {
    description = "Nested Wayland compositor with support for X11 forwarding";
    homepage = "https://chromium.googlesource.com/chromiumos/platform2/+/refs/heads/main/vm_tools/sommelier/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.linux;
    mainProgram = "sommelier";
    # Marked broken 2025-11-28 because it has failed on Hydra for at least one year.
    broken = true;
  };
}
