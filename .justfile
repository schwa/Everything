set shell := ["/opt/homebrew/bin/fish", "-c"]
sources := "Sources/Everything"
templates := `find "Sources/Everything" -name "*.gyb"`

default:
  @just --list

generate:
    for template in (find {{sources}} -name "*.gyb"); \
        python3 Utilities/gyb.py "$template" > (path change-extension "" "$template"); \
    end
