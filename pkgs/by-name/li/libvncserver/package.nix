{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libgcrypt,
  libjpeg,
  libpng,
  openssl,
  systemd,
  zlib,
  buildExamples ? false,
  enableShared ? !stdenv.hostPlatform.isStatic,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvncserver";
  version = "0.9.15";

  src = fetchFromGitHub {
    owner = "LibVNC";
    repo = "libvncserver";
    tag = "LibVNCServer-${finalAttrs.version}";
    hash = "sha256-a3acEjJM+ZA9jaB6qZ/czjIfx/L3j71VjJ6mtlqYcSw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # fix generated pkg-config files
    ./pkgconfig.patch

    (fetchpatch {
      hash = "sha256-AAZ3H34+nLqQggb/sNSx2gIGK96m4zatHX3wpyjNLOA=";
      name = "libvncserver-fix-cmake-4.patch";
      url = "https://github.com/LibVNC/libvncserver/commit/e64fa928170f22a2e21b5bbd6d46c8f8e7dd7a96.patch";
    })
  ];

  # This test checks if using the **installed** headers works.
  # As it doesn't set the include paths correctly, and we have nixpkgs-review to check if
  # packages continue to build, patching it would serve no purpose, so we can just remove the test entirely.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'add_test(NAME includetest COMMAND' '# add_test(NAME includetest COMMAND'
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libjpeg
    openssl
    libgcrypt
    libpng
  ]
  ++ lib.optionals withSystemd [
    systemd
  ];

  propagatedBuildInputs = [
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_SYSTEMD" withSystemd)
    (lib.cmakeBool "BUILD_SHARED_LIBS" enableShared)
    (lib.cmakeBool "WITH_EXAMPLES" buildExamples)
    (lib.cmakeBool "WITH_TESTS" finalAttrs.doCheck)
  ];

  doCheck = enableShared;

  meta = {
    description = "VNC server library";
    homepage = "https://libvnc.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
  };
})
