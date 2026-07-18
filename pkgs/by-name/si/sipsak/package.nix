{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  c-ares,
  nix-update-script,
  openssl ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sipsak";
  version = "4.5.12.1";

  src = fetchFromGitHub {
    owner = "sipwise";
    repo = "sipsak";
    tag = "mr${finalAttrs.version}";
    hash = "sha256-j4KF87krXvY2pcepEYRRxtadV8QxHRGICK6VrmXw5BQ=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    openssl
    c-ares
  ];

  # -fcommon: workaround build failure on -fno-common toolchains like upstream
  # gcc-10. Otherwise build fails as:
  #   ld: transport.o:/build/source/sipsak.h:323: multiple definition of
  #     `address'; auth.o:/build/source/sipsak.h:323: first defined here
  env.NIX_CFLAGS_COMPILE = "-std=gnu89 -fcommon";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "SIP Swiss army knife";
    homepage = "https://github.com/sipwise/sipsak";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
    mainProgram = "sipsak";
  };

})
