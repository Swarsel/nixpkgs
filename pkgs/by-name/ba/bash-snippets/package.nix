{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  bind,
  curl,
  gitMinimal,
  iproute2,
  makeWrapper,
  python3,
}:
let
  deps = lib.makeBinPath [
    curl
    python3
    bind.dnsutils
    iproute2
    bc
    gitMinimal
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bash-snippets";
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "alexanderepstein";
    repo = "Bash-Snippets";
    rev = "v${finalAttrs.version}";
    sha256 = "044nxgd3ic2qr6hgq5nymn3dyf5i4s8mv5z4az6jvwlrjnvbg8cp";
  };

  postPatch = ''
    patchShebangs install.sh
    substituteInPlace install.sh --replace /usr/local "$out"
  '';

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out"/bin "$out"/share/man/man1
    ./install.sh all
    for file in "$out"/bin/*; do
      wrapProgram "$file" --prefix PATH : "${deps}"
    done
  '';

  dontBuild = true;

  meta = {
    description = "Collection of small bash scripts for heavy terminal users";
    homepage = "https://github.com/alexanderepstein/Bash-Snippets";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
