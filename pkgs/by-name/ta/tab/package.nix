{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tab";
  version = "9.2";

  src = fetchFromGitHub {
    owner = "ivan-tkatchev";
    repo = "tab";
    rev = finalAttrs.version;
    hash = "sha256-UOXfnpzYMKDdp8EeBo2HsVPGn61hkCqHe8olX9KAgOU=";
  };

  # gcc12; see https://github.com/ivan-tkatchev/tab/commit/673bdac998
  postPatch = ''
    sed '1i#include <cstring>' -i deps.h
  '';

  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin tab
    install -Dm444 -t $out/share/doc/tab docs/*.html

    runHook postInstall
  '';

  checkTarget = "test";

  meta = {
    description = "Programming language/shell calculator";
    homepage = "https://tab-lang.xyz";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ mstarzyk ];
    platforms = with lib.platforms; unix;
    mainProgram = "tab";
  };
})
