{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  pandoc,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bdsync";
  version = "0.11.4";

  src = fetchFromGitHub {
    owner = "rolffokkens";
    repo = "bdsync";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-uvP26gdyIPC+IHxO5CYVuabfT4mnoWDOyaLTplYCW0I=";
  };

  postPatch = ''
    patchShebangs ./tests.sh
    patchShebangs ./tests/
  '';

  nativeBuildInputs = [
    pandoc
    which
  ];

  buildInputs = [ openssl ];
  doCheck = true;

  installPhase = ''
    install -Dm755 bdsync -t $out/bin/
    install -Dm644 bdsync.1 -t $out/share/man/man1/
  '';

  meta = {
    description = "Fast block device synchronizing tool";
    homepage = "https://github.com/rolffokkens/bdsync";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jluttine ];
    platforms = lib.platforms.linux;
    mainProgram = "bdsync";
  };
})
