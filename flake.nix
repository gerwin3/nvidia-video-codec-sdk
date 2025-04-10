{
  description = "nvidia-video-codec-sdk";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    inputs.flake-utils.lib.eachSystem (builtins.attrNames inputs.zig.packages) (
      system:
      let
        overlays = [
          (final: prev: { zigpkgs = inputs.zig.packages.${prev.system}; })
          (final: prev: { zlspkgs = inputs.zls.packages.${prev.system}; })
        ];
        pkgs = import nixpkgs { inherit overlays system; };
      in
      {
        devShells.default = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
          packages = with pkgs; [
            zigpkgs.default
            zls
          ];
          # This is the equivalent of addDriverRunpath for dev shell. In a Nix
          # build we would use addDriverRunpath to patch the binary rpath to
          # load the driver libraries. In a devshell we do not have access to
          # the binary so we just add the driver library path to
          # LD_LIBRARY_PATH.
          shellHook = ''
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/run/opengl-driver/lib/";
          '';
        };
      }
    );
}
