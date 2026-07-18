{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libx11,
  libxext,
  libxrandr,
  pkg-config,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "master_me";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "trummerschlunk";
    repo = "master_me";
    tag = finalAttrs.version;
    hash = "sha256-eesMXxRcCgzhSQ+WUqM00EuKYhFxysjH+RWKHKGYzUM=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs ./dpf/utils/
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libGL
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
    libxext
    libxrandr
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  enableParallelBuilding = true;

  meta = {
    description = "Automatic mastering plugin for live streaming, podcasts and internet radio";
    homepage = "https://github.com/trummerschlunk/master_me";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.all;
    mainProgram = "master_me";
    broken = stdenv.hostPlatform.isDarwin; # error: no type or protocol named 'NSPasteboardType'
  };
})
