{
  lib,
  stdenv,
  fetchurl,
  bash,
  python3Packages,
  zlib,
}:

let
  pythonPackages = python3Packages;
  inherit (pythonPackages) python;
in

pythonPackages.buildPythonApplication rec {
  pname = "quast";
  version = "5.3.0";

  src = fetchurl {
    url = "https://github.com/ablab/quast/releases/download/quast_${version}/quast-${version}.tar.gz";
    hash = "sha256-rJ26A++dClHXqeLFaCYQTnjzQPYmOjrTk2SEQt68dOw=";
  };

  buildInputs = [ zlib ] ++ pythonPath;
  # Tests need to download data files, so manual run after packaging is needed
  doCheck = false;

  installPhase = ''
    substituteInPlace quast_libs/bedtools/Makefile \
      --replace "/bin/bash" "${bash}/bin/bash"
    mkdir -p "$out/${python.sitePackages}"
    export PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"
    ${python.pythonOnBuildForHost.interpreter} setup.py install \
      --install-lib=$out/${python.sitePackages} \
      --prefix="$out"
  '';

  postFixup = ''
    for file in $(find $out -type f -type f -perm /0111); do
        old_rpath=$(patchelf --print-rpath $file) && \
        patchelf --set-rpath $old_rpath:${lib.getLib stdenv.cc.cc}/lib $file || true
    done
    # Link to the master program
    ln -s $out/bin/quast.py $out/bin/quast
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  format = "other";

  pythonPath = with pythonPackages; [
    simplejson
    joblib
    setuptools
    distutils
    matplotlib
  ];

  meta = {
    description = "Evaluates genome assemblies by computing various metrics";
    homepage = "https://github.com/ablab/quast";
    license = lib.licenses.gpl2;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # source bundles binary dependencies
    ];

    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.all;
  };
}
