{
  lib,
  stdenv,
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
}:

let
  pname = "s3proxy";
  version = "2.6.0";
in
maven.buildMavenPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "gaul";
    repo = "s3proxy";
    rev = "s3proxy-${version}";
    hash = "sha256-wd3GdSAcoJvlyFqnccdhM83IY2Q7KJQHoyV+sQGEwo4=";
  };

  nativeBuildInputs = [ makeWrapper ];
  doCheck = !stdenv.hostPlatform.isDarwin;

  installPhase = ''
    install -D --mode=644 --target-directory=$out/share/s3proxy target/s3proxy-${version}-jar-with-dependencies.jar

    makeWrapper ${jre}/bin/java $out/bin/s3proxy \
      --add-flags "-jar $out/share/s3proxy/s3proxy-${version}-jar-with-dependencies.jar"
  '';

  mvnHash = "sha256-OCFs1Q4NL5heP8AVvkQ+ZdhmPD2SNZMCF2gxjXpbfW4=";

  meta = {
    description = "Access other storage backends via the S3 API";
    homepage = "https://github.com/gaul/s3proxy";
    changelog = "https://github.com/gaul/s3proxy/releases/tag/s3proxy-${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ camelpunch ];
    mainProgram = "s3proxy";
  };
}
