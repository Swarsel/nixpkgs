{
  lib,
  fetchFromGitHub,
  buildDhallPackage,
}:

# This function is used by `dhall-to-nixpkgs` when given a GitHub repository
lib.makePackageOverridable (
  {
    # Arguments passed through to `buildDhallPackage`
    name,
    # Arguments passed through to `fetchFromGitHub`
    owner,
    repo,
    rev,
    dependencies ? [ ],
    # The directory containing the Dhall files, if other than the root of the
    # repository
    directory ? "",
    # Set to `true` to generate documentation for the package
    document ? false,
    # The file to import, relative to the above directory
    file ? "package.dhall",
    source ? false,
    # Extra arguments passed through to `fetchFromGitHub`, such as the hash
    # or `fetchSubmodules`
    ...
  }@args:

  let
    versionedName = "${name}-${rev}";

    src = fetchFromGitHub (
      {
        inherit owner repo rev;
        name = "${versionedName}-source";
      }
      // removeAttrs args [
        "name"
        "dependencies"
        "document"
        "source"
        "directory"
        "file"
        "owner"
        "repo"
        "rev"
      ]
    );

    prefix = lib.optionalString (directory != "") "/${directory}";

  in
  buildDhallPackage (
    {
      inherit dependencies source;
      code = "${src}${prefix}/${file}";
      name = versionedName;
    }
    // lib.optionalAttrs document {
      baseImportUrl = "https://raw.githubusercontent.com/${owner}/${repo}/${rev}${prefix}";
      documentationRoot = "${src}/${prefix}";
    }
  )
)
