{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  flex,
  makeWrapper,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spicy";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "zeek";
    repo = "spicy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cqOeopmGFVFphhaSCkxtTzGqfJma84WmYUq/XxZXY+c=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs scripts tests/scripts
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bison
    cmake
    flex
    makeWrapper
    python3
  ];

  buildInputs = [
    flex
    zlib
  ];

  cmakeFlags = [
    "-DHILTI_DEV_PRECOMPILE_HEADERS=OFF"
  ];

  preFixup = ''
    for b in $out/bin/*
      do wrapProgram "$b" --prefix PATH : "${
        lib.makeBinPath [
          bison
          flex
        ]
      }"
    done
  '';

  meta = {
    description = "C++ parser generator for dissecting protocols & files";

    longDescription = ''
      Spicy is a parser generator that makes it easy to create robust C++
      parsers for network protocols, file formats, and more. Spicy is a bit
      like a "yacc for protocols", but it's much more than that: It's an
      all-in-one system enabling developers to write attributed grammars that
      describe both syntax and semantics of an input format using a single,
      unified language. Think of Spicy as a domain-specific scripting language
      for all your parsing needs.
    '';

    homepage = "https://github.com/zeek/spicy";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tobim ];
    platforms = lib.platforms.unix;
  };
})
