{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fftw,
  lapack,
  makeWrapper,
  openblas,
  raspa,
  raspa-data,
  runCommandLocal,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "raspa";
  version = "2.0.47";

  src = fetchFromGitHub {
    owner = "iRASPA";
    repo = "RASPA2";
    rev = "v${finalAttrs.version}";
    hash = "sha256-i8Y+pejiOuyPNJto+/0CmRoAnMljCrnDFx8qDh4I/68=";
  };

  # Prepare for the Python binding packaging.
  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  buildInputs = [
    fftw
    lapack
    openblas
  ];

  # K&R `T func()` declarations whose definitions take real args
  env.CFLAGS = "-std=gnu17";
  doCheck = true;

  # Wrap with RASPA_DIR
  # so that users can run $out/bin/simulate directly
  # without the need of a `run` script.
  postInstall = ''
    wrapProgram "$out/bin/simulate" \
      --set RASPA_DIR "$out"
  '';

  enableParallelBuilding = true;

  postAutoreconf = ''
    automake --add-missing
    autoconf
  '';

  preAutoreconf = ''
    mkdir "m4"
  '';

  passthru.tests.run-an-example = runCommandLocal "raspa-test-run-an-example" { } ''
    set -eu -o pipefail
    exampleDir="${raspa-data}/share/raspa/examples/Basic/1_MC_Methane_in_Box"
    exampleDirWritable="$(basename "$exampleDir")"
    cp -rT "$exampleDir" "./$exampleDirWritable"
    chmod u+rw -R "$exampleDirWritable"
    cd "$exampleDirWritable"
    ${raspa}/bin/simulate
    touch "$out"
  '';

  meta = {
    description = "General purpose classical molecular simulation package";
    homepage = "https://iraspa.org/raspa/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    platforms = lib.platforms.all;
    mainProgram = "simulate";
  };
})
