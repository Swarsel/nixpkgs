{
  lib,
  stdenv,
  fetchFromGitHub,
  libsodium,
  nix-update-script,
  pkgconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liboprf";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "stef";
    repo = "liboprf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CQF7feBL83iN2I6GfWjJ2Xe6fLm7D2yEUb6KgioXWkw=";
  };

  patches = [
    ./no-static.patch
  ];

  # strip: error: option is not supported for MachO
  postPatch = lib.optionalString stdenv.hostPlatform.isMacho ''
    substituteInPlace makefile \
      --replace-fail "--strip-unneeded" ""
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkgconf ];
  buildInputs = [ libsodium ];
  makeFlags = [ "PREFIX=$(out)" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";
  sourceRoot = "${finalAttrs.src.name}/src";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library providing OPRF and Threshold OPRF based on libsodium";
    homepage = "https://github.com/stef/liboprf";
    changelog = "https://github.com/stef/liboprf/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.ngi ];
  };
})
