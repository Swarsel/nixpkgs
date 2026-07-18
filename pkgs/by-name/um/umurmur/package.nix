{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libconfig,
  nixosTests,
  openssl,
  protobufc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "umurmur";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "umurmur";
    repo = "umurmur";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pJRGyfG5y5wdB+zoWiJ1+2O1L3TThC6IairVDlE76tA=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    openssl
    protobufc
    libconfig
  ];

  configureFlags = [
    "--with-ssl=openssl"
    "--enable-shmapi"
  ];

  passthru = {
    tests = {
      inherit (nixosTests) umurmur;
    };
  };

  meta = {
    description = "Minimalistic Murmur (Mumble server)";
    homepage = "https://github.com/umurmur/umurmur";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ _3JlOy-PYCCKUi ];
    platforms = lib.platforms.all;
    mainProgram = "umurmurd";
    # never built on aarch64-darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
  };
})
