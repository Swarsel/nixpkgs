{
  lib,
  stdenv,
  fetchzip,
  nixosTests,
  pkgs,
}:

let

  buildGnomeExtension =
    {
      description,
      # extensions.gnome.org extension URL
      link,
      # Hex-encoded string of JSON bytes
      metadata,
      name,
      pname,
      sha256,
      # Every gnome extension has a UUID. It's the name of the extension folder once unpacked
      # and can always be found in the metadata.json of every extension.
      uuid,
      # Extension version numbers are integers
      version,
    }:

    stdenv.mkDerivation {
      pname = "gnome-shell-extension-${pname}";
      version = toString version;

      src = fetchzip {
        inherit sha256;

        url = "https://extensions.gnome.org/extension-data/${
          builtins.replaceStrings [ "@" ] [ "" ] uuid
        }.v${toString version}.shell-extension.zip";

        # The download URL may change content over time. This is because the
        # metadata.json is automatically generated, and parts of it can be changed
        # without making a new release. We simply substitute the possibly changed fields
        # with their content from when we last updated, and thus get a deterministic output
        # hash.
        postFetch = ''
          echo "${metadata}" | base64 --decode > $out/metadata.json
        '';

        stripRoot = false;
      };

      nativeBuildInputs = with pkgs; [ buildPackages.glib ];

      buildPhase = ''
        runHook preBuild
        if [ -d schemas ]; then
          glib-compile-schemas --strict schemas
        fi
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/gnome-shell/extensions/
        cp -r -T . $out/share/gnome-shell/extensions/${uuid}
        runHook postInstall
      '';

      passthru = {
        extensionPortalSlug = pname;
        # Store the extension's UUID, because we might need it at some places
        extensionUuid = uuid;

        tests = {
          gnome-extensions = nixosTests.gnome-extensions;
        };
      };

      meta = {
        description = builtins.head (lib.splitString "\n" description);
        longDescription = description;
        homepage = link;
        license = lib.licenses.gpl2Plus; # https://gjs.guide/extensions/review-guidelines/review-guidelines.html#licensing
        maintainers = [ lib.maintainers.honnip ];
        platforms = lib.platforms.linux;
      };
    };
in
lib.makeOverridable buildGnomeExtension
