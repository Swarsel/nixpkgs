{
  lib,
  buildPackages,
  cacert,
  glibcLocales,
  stdenvNoCC,
  subversion,
  openssh ? null,
  sshSupport ? true,
}:

let
  repoToName =
    url: rev:
    let
      inherit (lib)
        removeSuffix
        splitString
        reverseList
        head
        last
        elemAt
        ;
      base = removeSuffix "/" (last (splitString ":" url));
      path = reverseList (splitString "/" base);
      repoName =
        # ../repo/trunk -> repo
        if head path == "trunk" then
          elemAt path 1
        # ../repo/branches/branch -> repo-branch
        else if elemAt path 1 == "branches" then
          "${elemAt path 2}-${head path}"
        # ../repo/tags/tag -> repo-tag
        else if elemAt path 1 == "tags" then
          "${elemAt path 2}-${head path}"
        # ../repo (no trunk) -> repo
        else
          head path;
    in
    "${repoName}-r${toString rev}";
in

{
  url,
  hash ? "",
  ignoreExternals ? false,
  ignoreKeywords ? false,
  name ? repoToName url rev,
  preferLocalBuild ? true,
  rev ? "HEAD",
  sha256 ? "",
}:

assert sshSupport -> openssh != null;

if hash != "" && sha256 != "" then
  throw "Only one of sha256 or hash can be set"
else
  stdenvNoCC.mkDerivation {
    inherit name;

    inherit
      url
      rev
      ignoreExternals
      ignoreKeywords
      ;

    inherit preferLocalBuild;

    nativeBuildInputs = [
      cacert
      subversion
      glibcLocales
    ]
    ++ lib.optional sshSupport openssh;

    SVN_SSH = if sshSupport then "${buildPackages.openssh}/bin/ssh" else null;
    builder = ./builder.sh;
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;

    outputHash =
      if hash != "" then
        hash
      else if sha256 != "" then
        sha256
      else
        lib.fakeSha256;

    outputHashAlgo = if hash != "" then null else "sha256";
    outputHashMode = "recursive";
  }
