{
  lib,
  fetchFromGitHub,
  cmake,
  help2man,
  irods,
  llvmPackages,
  ninja,
}:

llvmPackages.stdenv.mkDerivation (finalAttrs: {
  inherit (irods) version;
  pname = "irods-icommands";

  src = fetchFromGitHub {
    owner = "irods";
    repo = "irods_client_icommands";
    tag = finalAttrs.version;
    hash = "sha256-jR7AhWeXYuJKzZRmYQUjiKSwK6PaB4dLQO8GVZwJQXk=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    help2man
  ];

  buildInputs = [ irods ];

  cmakeFlags = irods.commonCmakeFlags ++ [
    (lib.cmakeFeature "ICOMMANDS_INSTALL_DIRECTORY" "${placeholder "out"}/bin")
    (lib.cmakeBool "ICOMMANDS_INSTALL_SYMLINKS" false)
  ];

  meta = {
    inherit (irods.meta)
      homepage
      license
      maintainers
      platforms
      ;

    description = irods.meta.description + " CLI clients";

    longDescription = irods.meta.longDescription + ''

      This package provides the CLI clients, called 'icommands'.
    '';
  };
})
