{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libGLU,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glbinding";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "cginternals";
    repo = "glbinding";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-oLtOsiXfl/18rY/89vl9JDDWpPmEELOFKAHuClveU0c=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libGLU ];

  meta = {
    description = "C++ binding for the OpenGL API, generated using the gl.xml specification";
    homepage = "https://github.com/cginternals/glbinding/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mt-caret ];
  };
})
