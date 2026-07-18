{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "gocd-agent";
  version = "23.1.0";

  src = fetchurl {
    url = "https://download.go.cd/binaries/${version}-${rev}/generic/go-agent-${version}-${rev}.zip";
    sha256 = "sha256-L2MOkbVHoQu99lKrbnsNkhuU0SZ8VANSK72GZrGLbiQ=";
  };

  nativeBuildInputs = [ unzip ];

  buildCommand = "
    unzip $src -d $out
    mv $out/go-agent-${version} $out/go-agent
  ";

  rev = "16079";
  passthru.tests = { inherit (nixosTests) gocd-agent; };

  meta = {
    description = "Continuous delivery server specializing in advanced workflow modeling and visualization";
    homepage = "http://www.go.cd";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [
      swarren83
    ];

    platforms = lib.platforms.all;
  };
}
