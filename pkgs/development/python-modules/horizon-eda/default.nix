{
  buildPythonPackage,
  fetchpatch,
  horizon-eda,
  pycairo,
  python,
}:

let
  base = horizon-eda.passthru.base;
in
buildPythonPackage {
  inherit (base)
    pname
    version
    src
    meta
    env
    ;

  patches = [
    # Replaces osmesa with EGL_PLATFORM_SURFACELESS_MESA
    (fetchpatch {
      hash = "sha256-g0rP9NBDdDijh35Y2h4me9N5R/mjCn+2w7uhnv9bweY=";
      url = "https://github.com/horizon-eda/horizon/commit/663a8adaa1cb7eae7a824de07df8909bc33677c3.patch";
    })
  ];

  nativeBuildInputs = base.nativeBuildInputs;

  buildInputs = base.buildInputs ++ [
    python
  ];

  propagatedBuildInputs = [ pycairo ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${python.sitePackages}
    cp horizon.so $out/${python.sitePackages}

    runHook postInstall
  '';

  enableParallelBuilding = true;
  ninjaFlags = [ "horizon.so" ];
  pyproject = false;
}
