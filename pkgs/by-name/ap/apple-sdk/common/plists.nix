{
  lib,
  sdkVersion,
  stdenvNoCC,
  xcodePlatform,
}:

let
  inherit (lib.generators) toPlist;

  Info = rec {
    CFBundleIdentifier = "com.apple.platform.${Name}";

    DefaultProperties = {
      COMPRESS_PNG_FILES = "NO";
      DEPLOYMENT_TARGET_SETTING_NAME = stdenvNoCC.hostPlatform.darwinMinVersionVariable;
      STRIP_PNG_TEXT = "NO";
    };

    Description = if stdenvNoCC.hostPlatform.isMacOS then "macOS" else "iOS";
    FamilyIdentifier = lib.toLower xcodePlatform;
    FamilyName = Description;
    Identifier = CFBundleIdentifier;
    MinimumSDKVersion = stdenvNoCC.hostPlatform.darwinMinVersion;
    Name = lib.toLower xcodePlatform;
    Type = "Platform";
    Version = sdkVersion;
  };

  # These files are all based off of Xcode spec files found in
  # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Xcode/PrivatePlugIns/IDEOSXSupportCore.ideplugin/Contents/Resources.

  # Based off of the "MacOSX Architectures.xcspec" file. All x86 stuff
  # is removed because Nixpkgs only supports aarch64-darwin.
  Architectures = [
    {
      ArchitectureSetting = "ARCHS_STANDARD";
      Identifier = "Standard";
      Name = "Standard Architectures (Apple Silicon)";

      RealArchitectures = [
        "arm64"
      ];

      Type = "Architecture";
    }
    {
      ArchitectureSetting = "ARCHS_STANDARD_32_64_BIT";
      Identifier = "Universal";
      Name = "Universal (Apple Silicon)";

      RealArchitectures = [
        "arm64"
      ];

      Type = "Architecture";
    }
    {
      ArchitectureSetting = "NATIVE_ARCH_ACTUAL";
      Identifier = "Native";
      Name = "Native Architecture of Build Machine";
      Type = "Architecture";
    }
    {
      ArchitectureSetting = "ARCHS_STANDARD_64_BIT";
      Identifier = "Standard64bit";
      Name = "Apple Silicon";

      RealArchitectures = [
        "arm64"
      ];

      Type = "Architecture";
    }
    {
      Identifier = stdenvNoCC.hostPlatform.darwinArch;
      Name = "Apple Silicon";
      Type = "Architecture";
    }
    {
      ArchitectureSetting = "ARCHS_STANDARD_INCLUDING_64_BIT";
      Identifier = "Standard_Including_64_bit";
      Name = "Standard Architectures (including 64-bit)";

      RealArchitectures = [
        "arm64"
      ];

      Type = "Architecture";
    }
  ];

  # Based off of the "MacOSX Package Types.xcspec" file. Only keep the
  # bare minimum needed.
  PackageTypes = [
    {
      DefaultBuildSettings = {
        EXECUTABLE_NAME = "$(EXECUTABLE_PREFIX)$(PRODUCT_NAME)$(EXECUTABLE_VARIANT_SUFFIX)$(EXECUTABLE_SUFFIX)";
        EXECUTABLE_PATH = "$(EXECUTABLE_NAME)";
      };

      Identifier = "com.apple.package-type.mach-o-executable";
      Name = "Mach-O Executable";

      ProductReference = {
        FileType = "compiled.mach-o.executable";
        Name = "$(EXECUTABLE_NAME)";
      };

      Type = "PackageType";
    }
    {
      DefaultBuildSettings = {
        EXECUTABLE_NAME = "$(EXECUTABLE_PREFIX)$(PRODUCT_NAME)$(EXECUTABLE_VARIANT_SUFFIX)$(EXECUTABLE_SUFFIX)";
        EXECUTABLE_PATH = "$(EXECUTABLE_NAME)";
      };

      Identifier = "com.apple.package-type.mach-o-objfile";
      Name = "Mach-O Object File";

      ProductReference = {
        FileType = "compiled.mach-o.objfile";
        Name = "$(EXECUTABLE_NAME)";
      };

      Type = "PackageType";
    }
    {
      DefaultBuildSettings = {
        EXECUTABLE_NAME = "$(EXECUTABLE_PREFIX)$(PRODUCT_NAME)$(EXECUTABLE_VARIANT_SUFFIX)$(EXECUTABLE_SUFFIX)";
        EXECUTABLE_PATH = "$(EXECUTABLE_NAME)";
      };

      Identifier = "com.apple.package-type.mach-o-dylib";
      Name = "Mach-O Dynamic Library";

      ProductReference = {
        FileType = "compiled.mach-o.dylib";
        Name = "$(EXECUTABLE_NAME)";
      };

      Type = "PackageType";
    }
    {
      DefaultBuildSettings = {
        EXECUTABLE_NAME = "$(EXECUTABLE_PREFIX)$(PRODUCT_NAME)$(EXECUTABLE_VARIANT_SUFFIX)$(EXECUTABLE_SUFFIX)";
        EXECUTABLE_PATH = "$(EXECUTABLE_NAME)";
        EXECUTABLE_PREFIX = "lib";
        EXECUTABLE_SUFFIX = ".a";
      };

      Identifier = "com.apple.package-type.static-library";
      Name = "Mach-O Static Library";

      ProductReference = {
        FileType = "archive.ar";
        IsLaunchable = "NO";
        Name = "$(EXECUTABLE_NAME)";
      };

      Type = "PackageType";
    }
    {
      DefaultBuildSettings = {
        CONTENTS_FOLDER_PATH = "$(WRAPPER_NAME)/Contents";
        DOCUMENTATION_FOLDER_PATH = "$(LOCALIZED_RESOURCES_FOLDER_PATH)/Documentation";
        EXECUTABLES_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/Executables";
        EXECUTABLE_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/MacOS";
        EXECUTABLE_NAME = "$(EXECUTABLE_PREFIX)$(PRODUCT_NAME)$(EXECUTABLE_VARIANT_SUFFIX)$(EXECUTABLE_SUFFIX)";
        EXECUTABLE_PATH = "$(EXECUTABLE_FOLDER_PATH)/$(EXECUTABLE_NAME)";
        FRAMEWORKS_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/Frameworks";
        INFOPLIST_PATH = "$(CONTENTS_FOLDER_PATH)/Info.plist";
        INFOSTRINGS_PATH = "$(LOCALIZED_RESOURCES_FOLDER_PATH)/InfoPlist.strings";
        LOCALIZED_RESOURCES_FOLDER_PATH = "$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/$(DEVELOPMENT_LANGUAGE).lproj";
        PBDEVELOPMENTPLIST_PATH = "$(CONTENTS_FOLDER_PATH)/pbdevelopment.plist";
        PKGINFO_PATH = "$(CONTENTS_FOLDER_PATH)/PkgInfo";
        PLUGINS_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/PlugIns";
        PRIVATE_HEADERS_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/PrivateHeaders";
        PUBLIC_HEADERS_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/Headers";
        SCRIPTS_FOLDER_PATH = "$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/Scripts";
        SHARED_FRAMEWORKS_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/SharedFrameworks";
        SHARED_SUPPORT_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/SharedSupport";
        UNLOCALIZED_RESOURCES_FOLDER_PATH = "$(CONTENTS_FOLDER_PATH)/Resources";
        VERSIONPLIST_PATH = "$(CONTENTS_FOLDER_PATH)/version.plist";
        WRAPPER_NAME = "$(WRAPPER_PREFIX)$(PRODUCT_NAME)$(WRAPPER_SUFFIX)";
        WRAPPER_SUFFIX = ".bundle";
      };

      Identifier = "com.apple.package-type.wrapper";
      Name = "Wrapper";

      ProductReference = {
        FileType = "wrapper.cfbundle";
        IsLaunchable = "NO";
        Name = "$(WRAPPER_NAME)";
      };

      Type = "PackageType";
    }
    {
      BasedOn = "com.apple.package-type.wrapper";

      DefaultBuildSettings = {
        GENERATE_PKGINFO_FILE = "YES";
      };

      Identifier = "com.apple.package-type.wrapper.application";
      Name = "Application Wrapper";

      ProductReference = {
        FileType = "wrapper.application";
        IsLaunchable = "YES";
        Name = "$(WRAPPER_NAME)";
      };

      Type = "PackageType";
    }
  ];

  # Based off of the "MacOSX Product Types.xcspec" file. All
  # bundles/wrapper are removed, because we prefer dynamic products in
  # NixPkgs.
  ProductTypes = [
    {
      Identifier = "com.apple.product-type.tool";
      Name = "Command-line Tool";
      PackageTypes = [ "com.apple.package-type.mach-o-executable" ];
      Type = "ProductType";
    }
    {
      Identifier = "com.apple.product-type.objfile";
      Name = "Object File";
      PackageTypes = [ "com.apple.package-type.mach-o-objfile" ];
      Type = "ProductType";
    }
    {
      DefaultBuildProperties = {
        CODE_SIGNING_ALLOWED = "YES";
        CODE_SIGNING_REQUIRED = "NO";
        DYLIB_COMPATIBILITY_VERSION = "1";
        DYLIB_CURRENT_VERSION = "1";
        EXECUTABLE_EXTENSION = "dylib";
        EXECUTABLE_SUFFIX = ".$(EXECUTABLE_EXTENSION)";
        FRAMEWORK_FLAG_PREFIX = "-framework";
        FULL_PRODUCT_NAME = "$(EXECUTABLE_NAME)";
        GCC_INLINES_ARE_PRIVATE_EXTERN = "YES";
        LIBRARY_FLAG_NOSPACE = "YES";
        LIBRARY_FLAG_PREFIX = "-l";
        MACH_O_TYPE = "mh_dylib";
        REZ_EXECUTABLE = "YES";
        STRIP_STYLE = "debugging";
      };

      Identifier = "com.apple.product-type.library.dynamic";
      Name = "Dynamic Library";
      PackageTypes = [ "com.apple.package-type.mach-o-dylib" ];
      Type = "ProductType";
    }
    {
      DefaultBuildProperties = {
        CLANG_ENABLE_MODULE_DEBUGGING = "NO";
        EXECUTABLE_EXTENSION = "a";
        EXECUTABLE_PREFIX = "lib";
        EXECUTABLE_SUFFIX = ".$(EXECUTABLE_EXTENSION)";
        FRAMEWORK_FLAG_PREFIX = "-framework";
        FULL_PRODUCT_NAME = "$(EXECUTABLE_NAME)";
        LIBRARY_FLAG_NOSPACE = "YES";
        LIBRARY_FLAG_PREFIX = "-l";
        MACH_O_TYPE = "staticlib";
        REZ_EXECUTABLE = "YES";
        SEPARATE_STRIP = "YES";
        STRIP_STYLE = "debugging";
      };

      Identifier = "com.apple.product-type.library.static";
      Name = "Static Library";
      PackageTypes = [ "com.apple.package-type.static-library" ];
      Type = "ProductType";
    }
    {
      DefaultBuildProperties = {
        FRAMEWORK_FLAG_PREFIX = "-framework";
        FULL_PRODUCT_NAME = "$(WRAPPER_NAME)";
        LIBRARY_FLAG_NOSPACE = "YES";
        LIBRARY_FLAG_PREFIX = "-l";
        MACH_O_TYPE = "mh_bundle";
        STRIP_STYLE = "non-global";
        WRAPPER_EXTENSION = "bundle";
        WRAPPER_NAME = "$(WRAPPER_PREFIX)$(PRODUCT_NAME)$(WRAPPER_SUFFIX)";
        WRAPPER_PREFIX = "";
        WRAPPER_SUFFIX = ".$(WRAPPER_EXTENSION)";
      };

      HasInfoPlist = "YES";
      HasInfoPlistStrings = "YES";
      Identifier = "com.apple.product-type.bundle";
      IsWrapper = "YES";
      Name = "Bundle";
      PackageTypes = [ "com.apple.package-type.wrapper" ];
      Type = "ProductType";
    }
    {
      BasedOn = "com.apple.product-type.bundle";

      DefaultBuildProperties = {
        MACH_O_TYPE = "mh_execute";
        WRAPPER_EXTENSION = "app";
        WRAPPER_SUFFIX = ".$(WRAPPER_EXTENSION)";
      };

      Identifier = "com.apple.product-type.application";
      Name = "Application";
      PackageTypes = [ "com.apple.package-type.wrapper.application" ];
      Type = "ProductType";
    }
    {
      DefaultBuildProperties = {
        FRAMEWORK_FLAG_PREFIX = "-framework";
        FULL_PRODUCT_NAME = "$(WRAPPER_NAME)";
        LIBRARY_FLAG_NOSPACE = "YES";
        LIBRARY_FLAG_PREFIX = "-l";
        MACH_O_TYPE = "mh_bundle";
        STRIP_STYLE = "non-global";
        WRAPPER_EXTENSION = "bundle";
        WRAPPER_NAME = "$(WRAPPER_PREFIX)$(PRODUCT_NAME)$(WRAPPER_SUFFIX)";
        WRAPPER_PREFIX = "";
        WRAPPER_SUFFIX = ".$(WRAPPER_EXTENSION)";
      };

      HasInfoPlist = "YES";
      HasInfoPlistStrings = "YES";
      Identifier = "com.apple.product-type.framework";
      IsWrapper = "YES";
      Name = "Bundle";
      PackageTypes = [ "com.apple.package-type.wrapper" ];
      Type = "ProductType";
    }
  ];

  ToolchainInfo = {
    Identifier = "com.apple.dt.toolchain.XcodeDefault";
  };
in
{
  "Architectures.xcspec" = builtins.toFile "Architectures.xcspec" (
    toPlist { escape = true; } Architectures
  );

  "Info.plist" = builtins.toFile "Info.plist" (toPlist { escape = true; } Info);

  "PackageTypes.xcspec" = builtins.toFile "PackageTypes.xcspec" (
    toPlist { escape = true; } PackageTypes
  );

  "ProductTypes.xcspec" = builtins.toFile "ProductTypes.xcspec" (
    toPlist { escape = true; } ProductTypes
  );

  "ToolchainInfo.plist" = builtins.toFile "ToolchainInfo.plist" (
    toPlist { escape = true; } ToolchainInfo
  );
}
