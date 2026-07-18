{
  lib,
  fetchFromGitHub,
  build-idris-package,
  effects,
  pkgs,
}:
build-idris-package {
  pname = "glfw";
  version = "2016-12-05";

  src = fetchFromGitHub {
    owner = "eckart";
    repo = "glfw-idris";
    rev = "10220a734b69f3b884683041a1a9c533800b663a";
    sha256 = "045ylaj66g5m4syzhqxlaxmivy8y7jznkcf1y7w4awa4y5znyqqd";
  };

  postPatch = ''
    substituteInPlace src/MakefileGlfw \
      --replace glfw3 "glfw3 gl"
  '';

  nativeBuildInputs = [ pkgs.pkg-config ];
  extraBuildInputs = [ pkgs.glfw ];
  idrisDeps = [ effects ];

  meta = {
    description = "GLFW bindings for Idris";
    homepage = "https://github.com/eckart/glfw-idris";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
