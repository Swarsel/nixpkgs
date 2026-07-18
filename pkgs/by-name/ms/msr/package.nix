{
  lib,
  stdenv,
  fetchzip,
  installShellFiles,
}:

stdenv.mkDerivation rec {
  pname = "msr";
  version = "20060208";

  src = fetchzip {
    inherit pname version;
    url = "https://www.etallen.com/msr/msr-${version}.src.tar.gz";
    hash = "sha256-e01qYWbOALkXp5NpexuVodMxA3EBySejJ6ZBpZjyT+E=";
  };

  patches = [
    ./000-include-sysmacros.patch
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin/
    cp msr $out/bin/
    installManPage msr.man
    runHook postInstall
  '';

  meta = {
    description = "Linux tool to display or modify x86 model-specific registers (MSRs)";
    homepage = "http://www.etallen.com/msr.html";
    license = lib.licenses.bsd0;
    maintainers = [ ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "msr";
  };
}
