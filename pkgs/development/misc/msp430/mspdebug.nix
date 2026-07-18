{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  libusb-compat-0_1,
  enableMspds ? false,
  enableReadline ? true,
  hidapi ? null,
  mspds ? null,
  pkg-config ? null,
  readline ? null,
}:

assert stdenv.hostPlatform.isDarwin -> hidapi != null && pkg-config != null;
assert enableReadline -> readline != null;
assert enableMspds -> mspds != null;

stdenv.mkDerivation rec {
  pname = "mspdebug";
  version = "0.26";

  src = fetchFromGitHub {
    owner = "dlbeer";
    repo = "mspdebug";
    rev = "v${version}";
    sha256 = "sha256-4TisC0Nm3lYMWCJ3TtaHDAfLDejMQZJIruh2f7fCndU=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # TODO: remove once a new 0.26+ release is made
    substituteInPlace drivers/tilib_api.c --replace .so ${stdenv.hostPlatform.extensions.sharedLibrary}

    # Makefile only uses pkg-config if it detects homebrew
    substituteInPlace Makefile --replace brew true
  '';

  nativeBuildInputs =
    lib.optional stdenv.hostPlatform.isDarwin pkg-config
    ++ lib.optional (enableMspds && stdenv.hostPlatform.isLinux) autoPatchelfHook;

  buildInputs = [
    libusb-compat-0_1
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin hidapi
  ++ lib.optional enableReadline readline;

  makeFlags = [ "UNAME_S=$(unameS)" ] ++ lib.optional (!enableReadline) "WITHOUT_READLINE=1";

  postFixup = lib.optionalString (enableMspds && stdenv.hostPlatform.isDarwin) ''
    # autoPatchelfHook only works on linux so...
    for dep in $runtimeDependencies; do
      install_name_tool -add_rpath $dep/lib $out/bin/$pname
    done
  '';

  enableParallelBuilding = true;

  installFlags = [
    "PREFIX=$(out)"
    "INSTALL=install"
  ];

  # TODO: wrap with MSPDEBUG_TILIB_PATH env var instead of these rpath fixups in 0.26+
  runtimeDependencies = lib.optional enableMspds mspds;
  unameS = lib.optionalString stdenv.hostPlatform.isDarwin "Darwin";

  meta = {
    description = "Free programmer, debugger, and gdb proxy for MSP430 MCUs";
    homepage = "https://dlbeer.co.nz/mspdebug/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ aerialx ];
    platforms = lib.platforms.all;
    mainProgram = "mspdebug";
  };
}
