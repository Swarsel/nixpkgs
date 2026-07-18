{
  lib,
  stdenv,
  fetchFromGitHub,
  liboprf,
  libsodium,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libopaque";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "stef";
    repo = "libopaque";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VVD4489yWAJTWLGrpXYe8or5QjDnAuQ9/tzlNJJu/lo=";
  };

  # expand_message_xmd has been renamed to oprf_expand_message_xmd in liboprf
  # TODO: remove in the next release
  postPatch = ''
    substituteInPlace opaque.c \
      --replace-fail 'expand_message_xmd' 'oprf_expand_message_xmd'
  '';

  strictDeps = true;

  buildInputs = [
    libsodium
    liboprf
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mkdir -p ${placeholder "out"}/lib/pkgconfig
    cp ../libopaque.pc ${placeholder "out"}/lib/pkgconfig/
  '';

  sourceRoot = "${finalAttrs.src.name}/src";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Implementation of the OPAQUE protocol with support for threshold variants";
    homepage = "https://github.com/stef/libopaque/";
    changelog = "https://github.com/stef/libopaque/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libopaque" ];
    teams = [ lib.teams.ngi ];
  };
})
