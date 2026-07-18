{
  stdenv,
  flit-core,
  python,
}:

stdenv.mkDerivation {
  inherit (flit-core)
    version
    src
    patches
    meta
    ;

  pname = "${python.libPrefix}-bootstrap-${flit-core.pname}";
  postPatch = "cd flit_core";

  buildPhase = ''
    runHook preBuild

    ${python.interpreter} -m flit_core.wheel

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${python.interpreter} bootstrap_install.py dist/flit_core-*.whl \
      --install-root "$out" --installdir "/${python.sitePackages}"

    runHook postInstall
  '';
}
