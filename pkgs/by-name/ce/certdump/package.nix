{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
}:

buildDotnetModule {
  pname = "certdump";
  version = "0-unstable-2023-12-25";

  src = fetchFromGitHub {
    owner = "secana";
    repo = "CertDump";
    rev = "a834da24ee18503109631d836540a2b0cb481517";
    hash = "sha256-86s6KLP0DliKOr0fVId7SGN333b7HkiL5p/q0vazwMc=";
  };

  dotnetFlags = [
    "-property:ImportByWildcardBeforeSolution=false"
  ];

  executables = [ "CertDump" ];
  nugetDeps = ./deps.json;
  projectFile = [ "CertDump.sln" ];
  selfContainedBuild = true;

  meta = {
    description = "Dump certificates from PE files in different formats";

    longDescription = ''
      Cross-Platform tool to dump the signing certificate from a Portable Executable (PE) file.
    '';

    homepage = "https://github.com/secana/CertDump";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.baloo ];
    mainProgram = "CertDump";
    broken = stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isDarwin;
  };
}
