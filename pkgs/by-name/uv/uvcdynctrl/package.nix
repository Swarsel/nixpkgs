{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libxml2,
  pkg-config,
  udevCheckHook,
}:

stdenv.mkDerivation {
  pname = "uvcdynctrl";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "cshorler";
    repo = "webcam-tools";
    rev = "bee2ef3c9e350fd859f08cd0e6745871e5f55cb9";
    sha256 = "0s15xxgdx8lnka7vi8llbf6b0j4rhbjl6yp0qxaihysf890xj73s";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace libwebcam/CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace uvcdynctrl/CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    udevCheckHook
  ];

  buildInputs = [ libxml2 ];
  doInstallCheck = true;

  prePatch = ''
    local fixup_list=(
      uvcdynctrl/CMakeLists.txt
      uvcdynctrl/udev/rules/80-uvcdynctrl.rules
      uvcdynctrl/udev/scripts/uvcdynctrl
    )
    for f in "''${fixup_list[@]}"; do
      substituteInPlace "$f" \
        --replace "/etc/udev" "$out/etc/udev" \
        --replace "/lib/udev" "$out/lib/udev"
    done
  '';

  meta = {
    description = "Simple interface for devices supported by the linux UVC driver";
    homepage = "https://guvcview.sourceforge.net";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.puffnfresh ];
    platforms = lib.platforms.linux;
  };
}
