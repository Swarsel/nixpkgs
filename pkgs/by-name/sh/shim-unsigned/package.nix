{
  lib,
  stdenv,
  fetchFromGitHub,
  elfutils,
  fetchpatch2,
  defaultLoader ? null,
  vendorCertFile ? null,
}:

let

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  archSuffix =
    {
      aarch64-linux = "aa64";
      x86_64-linux = "x64";
    }
    .${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "shim";
  version = "16.1";

  src = fetchFromGitHub {
    owner = "rhboot";
    repo = "shim";
    tag = finalAttrs.version;
    hash = "sha256-qHZfr7ncJOsb1Cijlp6eJSMzxa34H1h4lACqceOzg+s=";
    fetchSubmodules = true;
  };

  patches = [
    # Fix build with binutils 2.46.
    (fetchpatch2 {
      hash = "sha256-0QGqEo5qu3TrG9yqwQLZGuKhgoeReF+RrJzlOVQYDmA=";
      url = "https://github.com/rhboot/shim/commit/c4665d282072df2ed8ab6ae1d5fa0de41e5db02f.patch?full_index=1";
    })
  ];

  buildInputs = [ elfutils ];

  makeFlags =
    lib.optional (vendorCertFile != null) "VENDOR_CERT_FILE=${vendorCertFile}"
    ++ lib.optional (defaultLoader != null) "DEFAULT_LOADER=${defaultLoader}";

  env.NIX_CFLAGS_COMPILE = toString [ "-I${toString elfutils.dev}/include" ];

  installFlags = [
    "DATATARGETDIR=$(out)/share/shim"
  ];

  installTargets = [ "install-as-data" ];

  passthru = {
    # Expose the arch suffix and target file names so that consumers
    # (e.g. infrastructure for signing this shim) don't need to
    # duplicate the logic from here
    inherit archSuffix;
    fallbackTarget = "fb${archSuffix}.efi";
    mokManagerTarget = "mm${archSuffix}.efi";
    target = "shim${archSuffix}.efi";
  };

  meta = {
    description = "UEFI shim loader";
    homepage = "https://github.com/rhboot/shim";
    license = lib.licenses.bsd1;

    maintainers = with lib.maintainers; [
      baloo
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
