{
  lib,
  stdenv,
  fetchFromGitHub,
  eigen,
  fetchpatch,
  glew,
  libGL,
  libGLU,
  libsForQt5,
  vcg,
}:

stdenv.mkDerivation {
  pname = "openbrf";
  version = "unstable-2016-01-09";

  src = fetchFromGitHub {
    owner = "cfcohen";
    repo = "openbrf";
    rev = "4bdc66e38def5e5184f5379c84a7558b7484c70a";
    sha256 = "16254cnr60ihcn7bki7wl1qm6gkvzb99cn66md1pnb7za8nvzf4j";
  };

  patches = [
    # https://github.com/cfcohen/openbrf/pull/7
    (fetchpatch {
      hash = "sha256-rNxAw6Le6QXMSirIAMhMmqVgNJLq6osnEOhWrY3mTpM=";
      name = "fix-build-against-newer-vcglib.patch";
      url = "https://github.com/cfcohen/openbrf/commit/6d82a25314a393e72bfbe2ffc3965bcac407df4c.patch";
    })
  ];

  postPatch = ''
    sed -i 's,^VCGLIB .*,VCGLIB = ${vcg}/include,' openBrf.pro
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    vcg
    glew
    eigen
  ];

  env.NIX_CFLAGS_COMPILE = "-isystem ${lib.getDev eigen}/include/eigen3";

  installPhase = ''
    install -Dm755 openBrf $out/share/openBrf/openBrf
    install -Dm644 carry_positions.txt $out/share/openBrf/carry_positions.txt
    install -Dm644 reference.brf $out/share/openBrf/reference.brf

    patchelf  \
      --set-rpath "${
        lib.makeLibraryPath [
          libsForQt5.qtbase
          glew
          stdenv.cc.cc
          libGLU
          libGL
        ]
      }" \
      $out/share/openBrf/openBrf

    mkdir -p "$out/bin"
    ln -s "$out/share/openBrf/openBrf" "$out/bin/openBrf"
  '';

  dontPatchELF = true;
  qmakeFlags = [ "openBrf.pro" ];

  meta = {
    description = "Tool to edit resource files (BRF)";
    homepage = "https://github.com/cfcohen/openbrf";
    license = lib.licenses.free;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "openBrf";
  };
}
