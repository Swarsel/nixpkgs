{
  lib,
  fetchFromGitHub,
  ruby,
  stdenvNoCC,
  testers,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rsmangler";
  version = "1.5-unstable-2019-07-24";

  src = fetchFromGitHub {
    owner = "digininja";
    repo = "RSMangler";
    rev = "e85da7d4a6e6241a92389aecf376077adc7544c3";
    hash = "sha256-DN20XzrlkunLyk4nkgytUJEtCOlFjWUUUAQ416l3Aug=";
  };

  postPatch = ''
    substituteInPlace rsmangler.rb \
      --replace-quiet ./rsmangler.rb rsmangler \
      --replace-quiet rsmangler.rb rsmangler
  '';

  buildInputs = [ ruby ];

  postInstall = ''
    install -Dm555 rsmangler.rb $out/bin/rsmangler
  '';

  passthru.tests.version = testers.testVersion {
    version = "rsmangler v ${lib.versions.majorMinor finalAttrs.version}";
    command = "rsmangler --help";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Perform various manipulations on the wordlists";
    homepage = "https://github.com/digininja/RSMangler";
    license = lib.licenses.cc-by-sa-20;
    maintainers = [ ];
    platforms = ruby.meta.platforms;
    mainProgram = "rsmangler";
  };
})
