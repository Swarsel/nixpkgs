{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  buildOctavePackage,
  cmake,
  gdcm,
  nix-update-script,
  pkg-config,
}:

buildOctavePackage rec {
  pname = "dicom";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "gnu-octave";
    repo = "octave-dicom";
    tag = "release-${version}";
    sha256 = "sha256-jvqnL9b4o5SQdqlk04LAL/U898R8B+NxC8xyV144hx4=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    cmake
  ];

  propagatedBuildInputs = [
    gdcm
  ];

  dontUseCmakeConfigure = true;

  postAutoreconf = ''
    popd
  '';

  preAutoreconf = ''
    pushd src
    # Removed these so autoreconf actually fires for our environment.
    rm config.*
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=release-(.*)" ]; };

  meta = {
    description = "Digital communications in medicine (DICOM) file io";
    homepage = "https://gnu-octave.github.io/packages/dicom/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
