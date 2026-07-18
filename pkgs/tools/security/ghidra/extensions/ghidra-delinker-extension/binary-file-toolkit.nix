{
  lib,
  fetchFromGitHub,
  maven,
}:
maven.buildMavenPackage (finalAttrs: {
  pname = "binary-file-toolkit";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "boricj";
    repo = "binary-file-toolkit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HMzRh/Q06Ik33mEkmh5U6qLiWk7ZCEstYq3Ll/pFhXM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp dist/* $out/

    runHook postInstall
  '';

  mvnHash = "sha256-UrvPqh5zxhTQ6MJNJ7CSAA6dg5DX+Jdx6/wKr4/1brs=";

  meta = {
    description = "Set of Java libraries for manipulating toolchain file formats";
    homepage = "https://github.com/boricj/binary-file-toolkit";
    changelog = "https://github.com/boricj/binary-file-toolkit/releases";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ timschumi ];
  };
})
