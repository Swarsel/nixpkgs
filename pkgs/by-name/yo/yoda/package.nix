{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bash,
  makeWrapper,
  python3,
  root,
  zlib,
  withRootSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yoda";
  version = "2.1.2";

  src = fetchFromGitLab {
    owner = "hepcedar";
    repo = "yoda";
    rev = "yoda-${finalAttrs.version}";
    hash = "sha256-cgThoxqPX6dVyGNTLXatW3uQV+41o38fTfkvHXsDs9A=";
  };

  postPatch = ''
    touch pyext/yoda/*.{pyx,pxd}
    patchShebangs .

    substituteInPlace pyext/yoda/plotting/script_generator.py \
      --replace '/usr/bin/env python' '${python3.interpreter}'
  '';

  strictDeps = true;

  nativeBuildInputs = with python3.pkgs; [
    autoreconfHook
    bash
    cython
    makeWrapper
  ];

  buildInputs = [
    python3
  ]
  ++ (with python3.pkgs; [
    numpy
    matplotlib
  ])
  ++ lib.optionals withRootSupport [ root ];

  propagatedBuildInputs = [ zlib ];
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-DWITH_OSX";

  postInstall = ''
    patchShebangs --build $out/bin/yoda-config
    for prog in "$out"/bin/*; do
      wrapProgram "$prog" --set PYTHONPATH $PYTHONPATH:$(toPythonPath "$out")
    done
  '';

  doInstallCheck = true;
  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];
  installCheckTarget = "check";

  meta = {
    description = "Provides small set of data analysis (specifically histogramming) classes";
    homepage = "https://yoda.hepforge.org";
    changelog = "https://gitlab.com/hepcedar/yoda/-/blob/yoda-${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
  };
})
