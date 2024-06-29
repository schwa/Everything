import Foundation

public func printColumnar(_ columns: Any..., headerRow: Bool = false, leadingSeparator: String = "| ", fieldSeparator: String = " | ", trailingSeparator: String = " |") {
    var s = ""
    printColumnar(columns, headerRow: headerRow, leadingSeparator: leadingSeparator, fieldSeparator: fieldSeparator, trailingSeparator: trailingSeparator, to: &s)
    print(s, terminator: "")
}

public func printColumnar <Target>(_ columns: [Any], headerRow: Bool = false, leadingSeparator: String = "| ", fieldSeparator: String = " | ", trailingSeparator: String = " |", to target: inout Target) where Target: TextOutputStream {
    let columns = columns.map { column in
        var s = ""
        print(column, to: &s)
        return s.split(separator: "\n")
    }
    let columnWidths = columns.map { column in
        column.reduce(0) { result, current in
            max(result, current.count)
        }
    }
    func printCell(_ cell: (any StringProtocol)?, columnWidth: Int) {
        if let cell {
            print(cell + String(repeating: " ", count: columnWidth - cell.count), terminator: "", to: &target)
        } else {
            print(String(repeating: " ", count: columnWidth), terminator: "", to: &target)
        }
    }
    func printRow(cells: [(any StringProtocol)?]) {
        print(leadingSeparator, terminator: "", to: &target)
        let z = Array(zip(cells, columnWidths))
        if let first = z.first {
            printCell(first.0, columnWidth: first.1)

            for (cell, columnWidth) in z.dropFirst() {
                print(fieldSeparator, terminator: "", to: &target)
                printCell(cell, columnWidth: columnWidth)
            }
        }
        print(trailingSeparator, to: &target)
    }

    func printDivider() {
        // print(leadingSeparator + String(repeating: "-", count: columnWidths.reduce(0, +) + (columns.count - 1) * (fieldSeparator.count)) + trailingSeparator)
        printRow(cells: columnWidths.map { String(repeating: "-", count: $0) })
    }

    printDivider()
    var iterators = columns.map { $0.makeIterator() }
    var row = 0
    while true {
        let cells = (iterators.startIndex ..< iterators.endIndex).map { index in
            iterators[index].next()
        }
        guard !cells.allSatisfy({ $0 == nil }) else {
            break
        }
        printRow(cells: cells)
        if headerRow && row == 0 {
            printDivider()
        }
        row += 1
    }
    printDivider()
}
