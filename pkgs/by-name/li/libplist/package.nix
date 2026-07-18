{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  python3,
  enablePython ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libplist";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libplist";
    rev = finalAttrs.version;
    hash = "sha256-Rc1KwJR+Pb2lN8019q5ywERrR7WA2LuLRiEvNsZSxXc=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ]
  ++ lib.optional enablePython "py";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = lib.optionals enablePython [
    python3
    python3.pkgs.cython
  ];

  configureFlags = [
    "--enable-debug"
  ]
  ++ lib.optionals (!enablePython) [
    "--without-cython"
  ];

  # Tests segfault on aarch64-darwin: https://hydra.nixos.org/build/323410364
  doCheck = !(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64);

  postFixup = lib.optionalString enablePython ''
    moveToOutput "lib/${python3.libPrefix}" "$py"
  '';

  preAutoreconf = ''
    export RELEASE_VERSION=${finalAttrs.version}
  '';

  meta = {
    description = "Library to handle Apple Property List format in binary or XML";
    homepage = "https://github.com/libimobiledevice/libplist";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "plistutil";
  };
})
