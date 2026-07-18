{
  stdenv,
  flit-core,
  installer,
  python,
}:

stdenv.mkDerivation {
  inherit (installer)
    version
    src
    patches
    meta
    ;

  pname = "${python.libPrefix}-bootstrap-${installer.pname}";

  buildPhase = ''
    runHook preBuild

    PYTHONPATH="${flit-core}/${python.sitePackages}" \
      ${python.interpreter} -m flit_core.wheel

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    PYTHONPATH=src ${python.interpreter} -m installer \
      --destdir "$out" --prefix "" dist/installer-*.whl

    runHook postInstall
  '';
}
