{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libjpeg,
  nix-update-script,
  obs-studio,
}:

buildGoModule rec {
  pname = "obs-teleport";
  version = "0.7.7";

  src = fetchFromGitHub {
    owner = "fzwoch";
    repo = "obs-teleport";
    rev = version;
    sha256 = "sha256-jwoD9qz7JDOIwPY6vammtQY9Igftu9UkI7PgsyJgQZ0=";
  };

  buildInputs = [
    libjpeg
    obs-studio
  ];

  vendorHash = "sha256-5uxZr2jpzRKupDC9+H9+efiHZKTBbkyv5mQKWV+6uEo=";

  env = {
    CGO_CFLAGS = "-I${obs-studio}/include/obs";
    CGO_LDFLAGS = "-L${obs-studio}/lib -lobs -lobs-frontend-api";
  };

  buildPhase = ''
    runHook preBuild

    go build -buildmode=c-shared -o obs-teleport.so .

    runHook postBuild
  '';

  postInstall = ''
    mkdir -p $out/lib/obs-plugins
    mv obs-teleport.so $out/lib/obs-plugins
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OBS Studio plugin for an open NDI-like replacement";
    homepage = "https://github.com/fzwoch/obs-teleport";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = obs-studio.meta.platforms;
  };
}
