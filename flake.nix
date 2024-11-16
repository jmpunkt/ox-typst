{
  description = "environment for ox-typst";

  nixConfig = {
    extra-substituters = "https://emacs-ci.cachix.org";
    extra-trusted-public-keys = "emacs-ci.cachix.org-1:B5FVOrxhXXrOL0S+tQ7USrhjMT5iOPH+QN9q0NItom4=";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-emacs-ci.url = "github:purcell/nix-emacs-ci";
    "org-9-7-15" = {
      url = "git+https://git.savannah.gnu.org/git/emacs/org-mode.git?tag=release_9.7.15";
      flake = false;
    };
    "org-main" = {
      url = "git+https://git.savannah.gnu.org/git/emacs/org-mode.git";
      flake = false;
    };
    "typst-0-12-0" = {
      url = "https://github.com/typst/typst/releases/download/v0.12.0/typst-x86_64-unknown-linux-musl.tar.xz";
      flake = false;
    };
    "typst-0-11-0" = {
      url = "https://github.com/typst/typst/releases/download/v0.11.0/typst-x86_64-unknown-linux-musl.tar.xz";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-emacs-ci,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs [
      "x86_64-linux"
    ];
    versionToKey = version: builtins.replaceStrings ["."] ["-"] version;
    platformsToGithub = {
      "x86_64-linux" = "ubuntu-latest";
      "x86_64-darwin" = "macos-latest";
      "aarch64-darwin" = "macos-latest";
    };
    org-versions = [
      "9.7.15"
      "main"
    ];
    emacs-versions = [
      "29.4"
      "snapshot"
      "release-snapshot"
    ];
    typst-versions = [
      "0.12.0"
      "0.11.0"
    ];
    buildTypst = {
      pkgs,
      typst-src,
      typst-version,
    }:
      pkgs.stdenv.mkDerivation {
        pname = "typst";
        version = typst-version;
        src = typst-src;
        installPhase = ''
          mkdir -p $out/bin
          install $src/typst $out/bin/
        '';
      };
    buildOrg = {
      writeText,
      melpaBuild,
      org-src,
      org-version,
    }:
      melpaBuild {
        pname = "org";
        version =
          if org-version == "main"
          then org-src.lastModifiedDate
          else org-version;
        commit = org-src.rev;

        src = org-src;

        recipe = writeText "recipe" ''
          (org :url "https://git.savannah.gnu.org/git/emacs/org-mode.git" :fetcher git)
        '';
      };

    buildPackage = {
      pkgs,
      typst-version,
      org-version,
      emacs-version,
    }: let
      typst-bin = pkgs."typst-${versionToKey typst-version}";
      emacs = nix-emacs-ci.packages.${pkgs.system}."emacs-${versionToKey emacs-version}";
      emacs-final = (pkgs.emacsPackagesFor emacs).emacsWithPackages (
        epkgs: [
          epkgs.melpaPackages.package-lint
          epkgs.melpaPackages.dash
          epkgs.manualPackages."org-${versionToKey org-version}"
        ]
      );
      load-path = ''
        (add-to-list 'load-path ".")
      '';
    in
      pkgs.writeShellScriptBin "emacs" ''
        export PATH="${typst-bin}/bin/:$PATH"
        ${emacs-final}/bin/emacs -q --eval ${pkgs.lib.escapeShellArg load-path} "$@"
      '';

    buildTestCase = {
      pkgs,
      typst-version,
      org-version,
      emacs-version,
    }: let
      package-lint-setup = ''
        (progn
          (require 'package-lint)
          (require 'finder)
          ;; These keywords do not exists and we know that. So we just ignore
          ;; this lint for the following keywords.
          (add-to-list 'finder-known-keywords '(org . "ORG"))
          (add-to-list 'finder-known-keywords '(typst . "TYPST")))
      '';
      byte-compile-setup = ''
        (setq byte-compile-error-on-warn t)
      '';
      emacs =
        self
        .packages
        .${pkgs.system}
        .${
          versionsToString {
            inherit typst-version org-version emacs-version;
          }
        };
    in
      pkgs.writeShellScriptBin "test-ox-typst.sh" ''
        set -e

        echo -e "\n\n\nPackage lint"
        ${emacs}/bin/emacs -batch --eval ${pkgs.lib.escapeShellArg package-lint-setup} -f package-lint-batch-and-exit ox-typst.el
        echo -e "\n\n\nByte compile"
        ${emacs}/bin/emacs -batch --eval ${pkgs.lib.escapeShellArg byte-compile-setup} -f batch-byte-compile *.el
        echo -e "\n\n\nTests"
        ${emacs}/bin/emacs -batch -l tests/test.el -f org-typst-test-run
      '';

    versionsToString = {
      typst-version,
      org-version,
      emacs-version,
    }: "emacs-${versionToKey emacs-version}-org-${versionToKey org-version}-typst-${versionToKey typst-version}";

    genMatrix = f: system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.org-mode
          self.overlays.typst-bin
        ];
      };
    in
      lib.mergeAttrsList (
        lib.mapCartesianProduct (
          {
            emacs-version,
            org-version,
            typst-version,
          }: let
            key = versionsToString {
              inherit typst-version org-version emacs-version;
            };
          in {
            ${key} = f {
              inherit typst-version org-version emacs-version pkgs;
            };
          }
        ) {
          emacs-version = emacs-versions;
          org-version = org-versions;
          typst-version = typst-versions;
        }
      );
  in {
    checks = forAllSystems (genMatrix buildTestCase);
    packages = forAllSystems (genMatrix buildPackage);
    githubActions = let
      mappingSystemToTasks =
        builtins.mapAttrs
        (name: value: (builtins.attrNames value)) (forAllSystems (genMatrix buildTestCase));
      constructEntry = set: value: {
        image = platformsToGithub.${set.name};
        system = set.name;
        target = value;
      };
    in (builtins.concatMap (set:
      if builtins.hasAttr set.name platformsToGithub
      then (map (constructEntry set) set.value)
      else [])
    (nixpkgs.lib.attrsToList mappingSystemToTasks));
    overlays.typst-bin = final: prev: (prev.lib.mergeAttrsList (map (
        typst-version: {
          "typst-${versionToKey typst-version}" = buildTypst {
            pkgs = prev;
            inherit typst-version;
            typst-src = inputs."typst-${versionToKey typst-version}";
          };
        }
      )
      typst-versions));
    overlays.org-mode = final: prev: {
      emacsPackagesFor = emacs: (
        (prev.emacsPackagesFor emacs).overrideScope
        (
          eself: esuper: let
            manualPackages =
              esuper.manualPackages
              // (prev.lib.mergeAttrsList
                (
                  map
                  (org-version: {
                    "org-${versionToKey org-version}" = buildOrg {
                      inherit (esuper) melpaBuild;
                      inherit (prev) writeText;
                      inherit org-version;
                      org-src = inputs."org-${versionToKey org-version}";
                    };
                  })
                  org-versions
                ));
          in
            esuper.override {inherit manualPackages;}
        )
      );
    };
  };
}
