{
  buildPythonPackage,
  cython,
  python,
  unittestCheckHook,
  vapoursynth,
}:

buildPythonPackage {
  inherit (vapoursynth) version src;
  inherit (vapoursynth) meta;
  pname = "vapoursynth";
  nativeBuildInputs = [ cython ];
  buildInputs = [ vapoursynth ];
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";

  unittestFlagsArray = [
    "-s"
    "test"
    "-p"
    "'*test.py'"
  ];

  passthru = {
    withPlugins =
      plugins: python.pkgs.vapoursynth.override { vapoursynth = vapoursynth.withPlugins plugins; };
  };
}
