{
  lib,
  stdenv,
  jupyter-kernel-definition,
  jupyter-kernel-specs,
  makeWrapper,
  requireSageTests,
  sage-tests,
  sage-with-env,
  sagedoc,
  withDoc,
}:

# A wrapper that makes sure sage finds its docs (if they were build) and the
# jupyter kernel spec.

stdenv.mkDerivation (finalAttrs: {
  pname = "sage";
  version = finalAttrs.src.version;
  src = sage-with-env.env.lib.src;
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = lib.optionals requireSageTests [
    # This is a hack to make sure sage-tests is evaluated. It doesn't actually
    # produce anything of value, it just decouples the tests from the build.
    sage-tests
  ];

  buildPhase = "#do nothing";

  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper "${sage-with-env}/bin/sage" "$out/bin/sage" \
      --set SAGE_DOC_SRC_OVERRIDE "${finalAttrs.src}/src/doc" ${lib.optionalString withDoc "--set SAGE_DOC_OVERRIDE ${sagedoc}/share/doc/sage"} \
      --prefix JUPYTER_PATH : "${jupyter-kernel-specs}"
  '';

  doInstallCheck = withDoc;

  installCheckPhase = ''
    export HOME="$TMPDIR/sage-home"
    mkdir -p "$HOME"
    "$out/bin/sage" -c 'browse_sage_doc._open("reference", testing=True)'
  '';

  configurePhase = "#do nothing";
  dontUnpack = true;

  passthru = {
    kernelspec = jupyter-kernel-definition;
    lib = sage-with-env.env.lib;

    quicktest = sage-tests.override {
      longTests = false;
      timeLimit = 600;
    }; # as many tests as possible in ~10m

    tests = sage-tests;
    with-env = sage-with-env;
  }
  // lib.optionalAttrs withDoc {
    doc = sagedoc;
  };

  meta = {
    description = "Open Source Mathematics Software, free alternative to Magma, Maple, Mathematica, and Matlab";
    homepage = "https://www.sagemath.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ [ "aarch64-darwin" ];
    mainProgram = "sage";
    teams = [ lib.teams.sage ];
  };
})
