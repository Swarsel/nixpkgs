{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  blas,
  buildOctavePackage,
  gfortran,
  lapack,
  nix-update-script,
}:

buildOctavePackage rec {
  pname = "control";
  version = "4.2.2";

  src = fetchFromGitHub {
    owner = "gnu-octave";
    repo = "pkg-control";
    tag = "${pname}-${version}";
    sha256 = "sha256-Miv+XFt8yAx890VfwI6lchW5u2wkaeOV3OfYNr9xWxs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    gfortran
    autoreconfHook
  ];

  buildInputs = [
    lapack
    blas
  ];

  postAutoreconf = ''
    popd
  '';

  # Running autoreconfHook inside the src directory fixes a compile issue about
  # the config.h header for control missing.
  # This is supposed to be handled by control's top-level Makefile, but does not
  # appear to be working. This manually forces it instead.
  preAutoreconf = ''
    pushd src
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "control-(.*)"
    ];
  };

  meta = {
    description = "Computer-Aided Control System Design (CACSD) Tools for GNU Octave, based on the proven SLICOT Library";
    homepage = "https://gnu-octave.github.io/packages/control/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
