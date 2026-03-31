## 1: Remove force casts and force unwraps in FileSystem module
status: new
priority: medium
kind: task
labels: lint, safety, filesystem
created: 2026-03-31T21:10:24.620232+00:00

FSPath.swift and FileSystem.swift contain 22 force_cast and force_unwrapping violations. These should be replaced with proper optional handling or guard statements to improve safety.

---

## 2: Remove force unwraps in SwiftUI module
status: new
priority: medium
kind: task
labels: lint, safety, swiftui
created: 2026-03-31T21:10:29.436547+00:00

Binding+Extensions.swift has 5 force_unwrapping violations. InigoColorPalette.swift has 2 violations. SuperImportWidget.swift has 1 closure_body_length violation (31 lines, limit is 30). Replace with proper optional handling and refactor long closure.

---

## 3: Remove force unwraps in Foundation extensions
status: new
priority: low
kind: task
labels: lint, safety, foundation
created: 2026-03-31T21:10:33.980958+00:00

Multiple Foundation extension files have force_unwrapping violations:\n- Process+Extensions.swift: 3 violations\n- Date+Extensions.swift: 3 violations\n- FileManager+xattr.swift: 2 violations\n- String+Extensions.swift, Scanner+Extensions.swift, Foundation+Misc.swift, Errors.swift, CharacterSet+Extensions.swift: 1 each\n\nReplace with proper optional handling.

---

## 4: Remove force casts and force unwraps in Combine module
status: new
priority: low
kind: task
labels: lint, safety, combine
created: 2026-03-31T21:10:38.194314+00:00

DisplayLinkPublisher.swift: 3 force_unwrapping violations\nFSEventPublisher.swift: 2 force_cast violations\nCombine.swift: 1 force_unwrapping violation\n\nReplace with safe casts and proper optional handling.

---

## 5: Remove force unwraps in Algorithms module
status: new
priority: low
kind: task
labels: lint, safety, algorithms
created: 2026-03-31T21:10:42.660723+00:00

Visitor.swift: 3 force_unwrapping violations\nAStarSearch.swift: 2 force_unwrapping violations\nSearch.swift: 1 force_unwrapping violation\nHeap.swift: 1 force_unwrapping violation\n\nReplace with proper optional handling or guard statements.

---

## 6: Remove force try in Cache.swift
status: new
priority: low
kind: task
labels: lint, safety, cache
created: 2026-03-31T21:10:49.779909+00:00

Cache.swift has 2 force_try violations at lines 130 and 134. These should be properly handled with do-catch or converted to throwing functions.

---

## 7: Remove remaining force unwraps in misc modules
status: new
priority: low
kind: task
labels: lint,safety
created: 2026-03-31T21:10:54.234317+00:00

BitRange.swift (Memory): 2 force_unwrapping violations\nColorParser.swift, CGColor+More.swift (Color): 3 total violations\nCollectionScanner.swift (Parsing): 1 violation\nVersion.swift, Scratch.swift (Misc): 2 total violations\nMath.swift: 1 violation\nEverythingUnsafeConformances.swift: 1 violation\n\nReplace with proper optional handling.

---

