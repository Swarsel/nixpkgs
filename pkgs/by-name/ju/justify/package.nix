{
  lib,
  stdenv,
  cmake,
  fetchFromGitea,
}:

stdenv.mkDerivation {
  pname = "justify";
  version = "unstable-2022-03-19";

  src = fetchFromGitea {
    owner = "jns";
    repo = "justify";
    rev = "0d397c20ed921c8e091bf18e548d174e15810e62";
    sha256 = "sha256-406OhJt2Ila/LIhfqJXhbFqFxJJiRyMVI4/VK8Y43kc=";
    domain = "tildegit.org";
  };

  postPatch = ''
    sed '1i#include <algorithm>' -i src/stringHelper.h # gcc12
  '';

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    install -D justify $out/bin/justify
  '';

  meta = {
    description = "Simple text alignment tool that supports left/right/center/fill justify alignment";
    homepage = "https://tildegit.org/jns/justify";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xfnw ];
    platforms = lib.platforms.unix;
    mainProgram = "justify";
  };
}
