{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  docbook5,
  findutils,
  fzf,
  gnugrep,
  gnused,
  jing-trang,
  libxml2,
  libxslt,
  makeWrapper,
  dev_only_shellcheck ? null,
}:
stdenv.mkDerivation rec {
  pname = "xmloscopy";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "grahamc";
    repo = "xmloscopy";
    rev = "v${version}";
    sha256 = "06y5bckrmnq7b5ny2hfvlmdws910jw3xbw5nzy3bcpqsccqnjxrc";
  };

  nativeBuildInputs = [
    makeWrapper
    dev_only_shellcheck
  ];

  installPhase = ''
    sed -i "s/hard to say/v${version}/" ./xmloscopy
    type -P shellcheck && shellcheck ./xmloscopy
    chmod +x ./xmloscopy
    patchShebangs ./xmloscopy
    mkdir -p $out/bin
    cp ./xmloscopy $out/bin/
    wrapProgram $out/bin/xmloscopy \
      --set RNG "${docbook5}/xml/rng/docbook/docbook.rng" \
      --set PATH "${spath}"
  '';

  spath = lib.makeBinPath [
    fzf
    coreutils
    libxml2
    libxslt
    jing-trang
    findutils
    gnugrep
    gnused
  ];

  meta = {
    description = "XML debugger";
    homepage = "https://github.com/grahamc/xmloscopy";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "xmloscopy";
  };
}
