{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fftw,
  fftwSinglePrec,
  hdf5,
  jq,
  libjpeg,
  libpng,
  libtiff,
  nix-update,
  openexr,
  python3,
  writeShellScript,
}:

let
  python = python3.withPackages (py: with py; [ numpy ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vigra";
  version = "1.12.3";

  src = fetchFromGitHub {
    owner = "ukoethe";
    repo = "vigra";
    tag = "Version-${lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version}";
    hash = "sha256-pknZHHIIhjfOxdp+qCOOGvo0W5ByTHXRiIQzzN7Z6M4=";
  };

  postPatch = ''
    chmod +x config/run_test.sh.in
    patchShebangs --build config/run_test.sh.in
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    fftw
    fftwSinglePrec
    hdf5
    libjpeg
    libpng
    libtiff
    openexr
    python
  ];

  cmakeFlags = [
    "-DWITH_OPENEXR=1"
    "-DVIGRANUMPY_INSTALL_DIR=${placeholder "out"}/${python.sitePackages}"
  ]
  ++ lib.optionals (stdenv.hostPlatform.system == "x86_64-linux") [
    "-DCMAKE_CXX_FLAGS=-fPIC"
    "-DCMAKE_C_FLAGS=-fPIC"
  ];

  enableParallelBuilding = true;

  passthru = {
    tests = {
      check = finalAttrs.finalPackage.overrideAttrs (previousAttrs: {
        doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
      });
    };

    updateScript = writeShellScript "update-vigra" ''
      latestVersion=$(curl ''${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} --fail --silent https://api.github.com/repos/ukoethe/vigra/releases/latest | ${lib.getExe jq} --raw-output .tag_name | sed -E 's/Version-([0-9]+)-([0-9]+)-([0-9]+)/\1.\2.\3/')
      ${lib.getExe nix-update} vigra --version $latestVersion
    '';
  };

  meta = {
    description = "Novel computer vision C++ library with customizable algorithms and data structures";
    homepage = "https://hci.iwr.uni-heidelberg.de/vigra";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ShamrockLee
      kyehn
    ];

    platforms = lib.platforms.unix;
    mainProgram = "vigra-config";
  };
})
