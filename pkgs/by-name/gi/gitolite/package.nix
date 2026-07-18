{
  lib,
  stdenv,
  coreutils,
  fetchFromCodeberg,
  git,
  makeWrapper,
  net-tools,
  nixosTests,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gitolite";
  version = "3.6.14";

  src = fetchFromCodeberg {
    owner = "sitaramc";
    repo = "gitolite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BwpqvjpHzoypV91W/QReAgiNrmpxZ0IE3W/bpCVO1GE=";
  };

  postPatch = ''
    substituteInPlace ./install --replace " 2>/dev/null" ""
    substituteInPlace src/lib/Gitolite/Hooks/PostUpdate.pm \
      --replace /usr/bin/perl "${perl}/bin/perl"
    substituteInPlace src/lib/Gitolite/Hooks/Update.pm \
      --replace /usr/bin/perl "${perl}/bin/perl"
    substituteInPlace src/lib/Gitolite/Setup.pm \
      --replace hostname "${net-tools}/bin/hostname"
    substituteInPlace src/commands/sskm \
      --replace /bin/rm "${coreutils}/bin/rm"
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    net-tools
    perl
  ];

  propagatedBuildInputs = [ git ];

  installPhase = ''
    mkdir -p $out/bin
    perl ./install -to $out/bin
    echo ${finalAttrs.version} > $out/bin/VERSION
  '';

  postFixup = ''
    wrapProgram $out/bin/gitolite-shell \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          (perl.withPackages (p: [ p.JSON ]))
        ]
      }
  '';

  dontBuild = true;

  passthru.tests = {
    gitolite = nixosTests.gitolite;
  };

  meta = {
    description = "Finely-grained git repository hosting";
    homepage = "https://gitolite.com/gitolite/index.html";
    license = lib.licenses.gpl2;

    maintainers = [
      lib.maintainers.thoughtpolice
      lib.maintainers.lassulus
      lib.maintainers.tomberek
    ];

    platforms = lib.platforms.unix;
  };
})
