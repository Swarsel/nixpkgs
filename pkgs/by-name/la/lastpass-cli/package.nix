{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  bash-completion,
  cmake,
  curl,
  docbook_xsl,
  fetchpatch,
  libxml2,
  libxslt,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "lastpass-cli";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "lastpass";
    repo = "lastpass-cli";
    rev = "v${version}";
    sha256 = "sha256-Q0ZG5Ehg29STLeAerMoLfzjaH9JyPk7269RgiPmDJV8=";
  };

  patches = [
    # CMake 3.1 is deprecated and no longer supported by CMake > 4
    # https://github.com/NixOS/nixpkgs/issues/445447
    # The patch comes from https://github.com/lastpass/lastpass-cli/pull/716 while
    # it is not merged and integrated in a new release.
    ./716-bump-cmake-minimum-version.patch
  ];

  nativeBuildInputs = [
    asciidoc
    cmake
    docbook_xsl
    pkg-config
  ];

  buildInputs = [
    bash-completion
    curl
    openssl
    libxml2
    libxslt
  ];

  postInstall = ''
    install -Dm644 -T ../contrib/lpass_zsh_completion $out/share/zsh/site-functions/_lpass
    install -Dm644 -T ../contrib/completions-lpass.fish $out/share/fish/vendor_completions.d/lpass.fish
    install -Dm755 -T ../contrib/examples/git-credential-lastpass $out/bin/git-credential-lastpass
  '';

  installTargets = [
    "install"
    "install-doc"
  ];

  meta = {
    description = "Stores, retrieves, generates, and synchronizes passwords securely";
    homepage = "https://github.com/lastpass/lastpass-cli";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ vinylen ];
    platforms = lib.platforms.unix;
  };
}
