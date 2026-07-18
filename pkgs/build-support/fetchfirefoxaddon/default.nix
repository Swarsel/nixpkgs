{
  stdenv,
  fetchurl,
  jq,
  strip-nondeterminism,
  unzip,
  writeScript,
  zip,
}:

{
  name,
  fixedExtid ? null,
  hash ? "",
  sha1 ? "",
  sha256 ? "",
  sha512 ? "",
  src ? "",
  url ? null,
}:

let
  extid = if fixedExtid == null then "nixos@${name}" else fixedExtid;
  source =
    if url == null then
      src
    else
      fetchurl {
        inherit
          sha1
          sha256
          sha512
          hash
          ;

        url = url;
      };
in
stdenv.mkDerivation {
  inherit name;

  nativeBuildInputs = [
    jq
    strip-nondeterminism
    unzip
    zip
  ];

  builder = writeScript "xpibuilder" ''
    echo "firefox addon $name into $out"

    UUID="${extid}"
    mkdir -p "$out/$UUID"
    unzip -q ${source} -d "$out/$UUID"
    NEW_MANIFEST=$(jq '. + {"applications": { "gecko": { "id": "${extid}" }}, "browser_specific_settings":{"gecko":{"id": "${extid}"}}}' "$out/$UUID/manifest.json")
    echo "$NEW_MANIFEST" > "$out/$UUID/manifest.json"
    cd "$out/$UUID"
    zip -r -q -FS "$out/$UUID.xpi" *
    strip-nondeterminism "$out/$UUID.xpi"
    rm -r "$out/$UUID"
  '';

  passthru = {
    inherit extid;
  };
}
