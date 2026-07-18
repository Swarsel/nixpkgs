{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
}:

let
  version = "1.10.5";
in
stdenv.mkDerivation {
  inherit version;
  pname = "libcpr";

  src = fetchFromGitHub {
    owner = "libcpr";
    repo = "cpr";
    rev = version;
    hash = "sha256-mAuU2uF8d+aHvCmotgIrBi/pUp1jkP6G0f98M76zjOw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # Linking with stdc++fs is no longer necessary.
    sed -i '/stdc++fs/d' include/CMakeLists.txt
  '';

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ curl ];
  cmakeFlags = [ "-DCPR_USE_SYSTEM_CURL=ON" ];

  postInstall = ''
    substituteInPlace "$out/lib/cmake/cpr/cprTargets.cmake" \
      --replace "_IMPORT_PREFIX \"$out\"" \
                "_IMPORT_PREFIX \"$dev\""
  '';

  meta = {
    description = "C++ wrapper around libcurl";
    homepage = "https://docs.libcpr.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rycee ];
    platforms = lib.platforms.all;
  };
}
