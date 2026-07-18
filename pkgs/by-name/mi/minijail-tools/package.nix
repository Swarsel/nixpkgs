{
  lib,
  minijail,
  pkgsBuildTarget,
  python3,
  python3Packages,
}:

let
  targetClang = pkgsBuildTarget.targetPackages.clangStdenv.cc;
in

python3Packages.buildPythonApplication {
  inherit (minijail) version src;
  pname = "minijail-tools";

  postPatch = ''
    substituteInPlace Makefile --replace-fail /bin/echo echo
  '';

  postConfigure = ''
    substituteInPlace tools/compile_seccomp_policy.py \
        --replace-fail "'constants.json'" "'$out/share/constants.json'"
  '';

  preBuild = ''
    make libconstants.gen.c libsyscalls.gen.c
    ${targetClang}/bin/${targetClang.targetPrefix}cc -S -emit-llvm \
        libconstants.gen.c libsyscalls.gen.c
    ${python3.pythonOnBuildForHost.interpreter} tools/generate_constants_json.py \
        --output constants.json \
        libconstants.gen.ll libsyscalls.gen.ll
  '';

  postInstall = ''
    mkdir -p $out/share
    cp -v constants.json $out/share/constants.json
  '';

  build-system = [
    python3Packages.setuptools
  ];

  pyproject = true;

  meta = {
    inherit (minijail.meta) maintainers platforms;
    description = "Set of tools for minijail";
    homepage = "https://android.googlesource.com/platform/external/minijail/+/refs/heads/master/tools/";
    license = lib.licenses.asl20;
  };
}
