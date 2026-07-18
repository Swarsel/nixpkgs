{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  imgui,
  vcpkg,
}:

stdenv.mkDerivation rec {
  pname = "implot";
  version = "0.17";

  src = fetchFromGitHub {
    owner = "epezent";
    repo = "implot";
    rev = "v${version}";
    hash = "sha256-HNzNRHPLr352EDkAci4nx5qQnPI308rGH8yHkF+n5OY=";
  };

  postPatch = ''
    cp "$cmakeRules"/CMakeLists.txt ./
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ imgui ];
  cmakeRules = "${vcpkg.src}/ports/implot";

  passthru.tests = {
    implot-demos = callPackage ./demos { };
  };

  meta = {
    description = "Immediate Mode Plotting";
    homepage = "https://github.com/epezent/implot";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
    platforms = lib.platforms.all;
  };
}
