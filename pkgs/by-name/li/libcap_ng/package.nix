{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  nix-update-script,
  pkg-config,
  swig,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcap-ng";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "stevegrubb";
    repo = "libcap-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-anuPOBWp4Hlpo+m6kYlSd2v7H3P7LQ9brZdq1lo7Po4=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  # NEWS needs to exist or else the build fails
  postPatch = ''
    touch NEWS
    substituteInPlace utils/captest.c \
      --replace-fail /usr/bin/captest ${placeholder "out"}/bin/captest
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    swig
  ];

  configureFlags = [
    "--without-python"
  ];

  # assumption: build machine runs linux kernel 5.0 or newer
  # see https://github.com/stevegrubb/libcap-ng?tab=readme-ov-file#note-to-distributions
  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    tests = {
      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Library for working with POSIX capabilities";
    homepage = "https://people.redhat.com/sgrubb/libcap-ng/";
    changelog = "https://people.redhat.com/sgrubb/libcap-ng/ChangeLog";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ grimmauld ];
    platforms = lib.platforms.linux;
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "libcap-ng_project" finalAttrs.version;
    pkgConfigModules = [ "libcap-ng" ];
    teams = [ lib.teams.security-review ];
  };
})
