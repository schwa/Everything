import Foundation

class Unit {
    var name: String
    var synonyms: [String]

    init(name: String, synonyms: [String] = []) {
        self.name = name
        self.synonyms = synonyms
    }
}

class BaseUnit: Unit {
}

extension Unit {
    static func == (lhs: Unit, rhs: Unit) -> Bool {
        lhs.name == rhs.name
    }
}

class DerivedUnit: Unit {
    let value: SVGValue

    init(name: String, synonyms: [String] = [], value: SVGValue) {
        self.value = value
        super.init(name: name, synonyms: synonyms)
    }
}

struct SVGValue {
    let quantity: Double
    let unit: Unit

    init(quantity: Double, unit: Unit) {
        self.quantity = quantity
        self.unit = unit
    }
}

struct UnitTable {
    var units: [Unit] = []

    init(units: [Unit]) {
        self.units = units
    }

    mutating func addUnit(unit: Unit) {
        units.append(unit)
    }

    func commonUnit(lhs: Unit, rhs: Unit) -> Unit? {
        if lhs == rhs {
            return lhs
        }
        return nil
    }
}

struct SVGValueConverter {
    func convert(value: SVGValue, unit: Unit) -> SVGValue? {
        nil
    }
}

//
// let m = BaseUnit(name: "meter")
// let mm = DerivedUnit(name: "millimeter", value: Value(quantity: 0.01, unit: m))
//
// var units = UnitTable(units: [m,mm])
//
//
//
//
// println(units)
