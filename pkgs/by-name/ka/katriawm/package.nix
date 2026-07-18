{
  lib,
  stdenv,
  fetchzip,
  gitUpdater,
  libx11,
  libxft,
  libxrandr,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "katriawm";
  version = "26.03";

  src = fetchzip {
    url = "https://www.uninformativ.de/git/katriawm/archives/katriawm-v${finalAttrs.version}.tar.gz";
    hash = "sha256-vnnc5SkNzCLZTBxKcaHDo9F5f++7dtESD5hOB0zrxjo=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace src/config.mk \
      --replace pkg-config "$PKG_CONFIG"
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxft
    libxrandr
  ];

  makeFlags = [
    "-C"
    "src"
  ];

  installFlags = [ "prefix=$(out)" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://www.uninformativ.de/git/katriawm.git/";
  };

  meta = {
    inherit (libx11.meta) platforms;
    description = "Non-reparenting, dynamic window manager with decorations";
    homepage = "https://www.uninformativ.de/git/katriawm/file/README.html";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "katriawm";
  };
})
