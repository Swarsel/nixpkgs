{
  stdenv,
  flit-core,
  installer,
  packaging,
  python,
}:

stdenv.mkDerivation {
  inherit (packaging) version src meta;
  pname = "${python.libPrefix}-bootstrap-${packaging.pname}";

  buildPhase = ''
    runHook preBuild

    PYTHONPATH="${flit-core}/${python.sitePackages}" \
      ${python.interpreter} -m flit_core.wheel

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    PYTHONPATH="${installer}/${python.sitePackages}" \
      ${python.interpreter} -m installer \
        --destdir "$out" --prefix "" dist/*.whl

    runHook postInstall
  '';
}
