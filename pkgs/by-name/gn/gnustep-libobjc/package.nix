{
  lib,
  fetchFromGitHub,
  clangStdenv,
  cmake,
  robin-map,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "gnustep-libobjc";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "gnustep";
    repo = "libobjc2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C7Dwqp5ewtBhuIyfNZmjhGSCBod3xM9KfUXZgHmvIB0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ robin-map ];
  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ];

  meta = {
    description = "Objective-C runtime for use with GNUstep";
    homepage = "https://gnustep.github.io/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ashalkhakov
      dblsaiko
    ];

    platforms = lib.platforms.unix;
    broken = clangStdenv.hostPlatform.isDarwin;
  };
})
