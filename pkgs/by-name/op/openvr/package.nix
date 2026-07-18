{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch2,
  jsoncpp,
  libGL,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openvr";
  version = "2.15.6";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "openvr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xtCqro73fWQ6i0PiVmWYCK30DUSq1WeALoUolUjuWlE=";
  };

  patches = [
    # https://github.com/ValveSoftware/openvr/pull/594
    (fetchpatch2 {
      hash = "sha256-0sPNDx5qKqCzN35FfArbgJ0cTztQp+SMLsXICxneLx4=";
      name = "use-correct-CPP11-definition-for-vsprintf_s.patch";
      url = "https://github.com/ValveSoftware/openvr/commit/0fa21ba17748efcca1816536e27bdca70141b074.patch";
    })
    # https://github.com/ValveSoftware/openvr/pull/1716
    (fetchpatch2 {
      hash = "sha256-aMojjbNjLvsGev0JaBx5sWuMv01sy2tG/S++I1NUi7U=";
      name = "add-ability-to-build-with-system-installed-jsoncpp.patch";
      url = "https://github.com/ValveSoftware/openvr/commit/54a58e479f4d63e62e9118637cd92a2013a4fb95.patch";
    })
  ];

  postPatch = ''
    # Fix jsoncpp ABI for downstream packages
    substituteInPlace CMakeLists.txt \
      --replace-fail "-std=c++11" "-std=c++17"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    jsoncpp
    libGL
  ];

  cmakeFlags = [
    "-DUSE_SYSTEM_JSONCPP=ON"
    "-DBUILD_SHARED=1"
  ];

  postUnpack = ''
    # Move in-tree jsoncpp out to complement the patch above
    # fetchpatch2 is not able to handle these renames
    mkdir source/thirdparty
    mv source/src/json source/thirdparty/jsoncpp
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "API and runtime that allows access to VR hardware from multiple vendors without requiring that applications have specific knowledge of the hardware they are targeting";
    homepage = "https://github.com/ValveSoftware/openvr";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
