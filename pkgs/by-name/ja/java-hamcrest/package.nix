{
  lib,
  fetchFromGitHub,
  gradle,
  jdk,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "java-hamcrest";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "hamcrest";
    repo = "JavaHamcrest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ntae6XWpD0wEs36YoPsfTl6cSR6ULl6dAJ5oZsV+ih0=";
  };

  nativeBuildInputs = [ gradle ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/java"
    cp hamcrest/build/libs/*.jar "$out/share/java"

    runHook postInstall
  '';

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  meta = {
    description = "Java library containing matchers that can be combined to create flexible expressions of intent";
    homepage = "https://hamcrest.org/JavaHamcrest/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tomodachi94 ];
    platforms = jdk.meta.platforms;
  };
})
