{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-core,
  cairo,
  cmake,
  dbus,
  eigen,
  fontconfig,
  freetype,
  glew,
  gtkmm3,
  json_c,
  libGLU,
  libdatrie,
  libepoxy,
  libpng,
  libpthread-stubs,
  libselinux,
  libsepol,
  libspnav,
  libthai,
  libxdmcp,
  libxkbcommon,
  libxtst,
  pangomm,
  pcre2,
  pkg-config,
  util-linuxMinimal, # provides libmount
  wrapGAppsHook3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "solvespace";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "solvespace";
    repo = "solvespace";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+ZSAC7wDOaN51RjbSAqaQOp10JzxSME3g0ln4VdkwcA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patch CMakeLists.txt <<EOF
    @@ -20,9 +20,9 @@
     # NOTE TO PACKAGERS: The embedded git commit hash is critical for rapid bug triage when the builds
     # can come from a variety of sources. If you are mirroring the sources or otherwise build when
     # the .git directory is not present, please comment the following line:
    -include(GetGitCommitHash)
    +# include(GetGitCommitHash)
     # and instead uncomment the following, adding the complete git hash of the checkout you are using:
    -# set(GIT_COMMIT_HASH 0000000000000000000000000000000000000000)
    +set(GIT_COMMIT_HASH $version)
    EOF
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    at-spi2-core
    cairo
    dbus
    eigen
    freetype
    fontconfig
    glew
    gtkmm3
    json_c
    libdatrie
    libepoxy
    libGLU
    libpng
    libselinux
    libsepol
    libspnav
    libthai
    libxkbcommon
    pangomm
    pcre2
    util-linuxMinimal
    libpthread-stubs
    libxdmcp
    libxtst
    zlib
  ];

  cmakeFlags = [
    "-DENABLE_OPENMP=ON"
    # CMake 4 needs a minimum version
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  __structuredAttrs = true;

  meta = {
    description = "Parametric 3d CAD program";
    homepage = "https://solvespace.com";
    changelog = "https://github.com/solvespace/solvespace/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.edef ];
    platforms = lib.platforms.linux;
  };
})
