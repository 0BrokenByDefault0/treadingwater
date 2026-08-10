import Foundation
import SwiftUI

enum TermCat: String, CaseIterable, Identifiable {
    case transport = "TRANSPORT"
    case editing = "EDITING"
    case arrange = "ARRANGE"
    case mixer = "MIXER"
    case effect = "EFFECT"
    case synth = "SYNTH"
    case theory = "THEORY"
    case file = "FILE"

    var id: String { rawValue }

    var tint: Color {
        switch self {
        case .transport: return Ink.orange
        case .editing:   return Ink.clay
        case .arrange:   return Ink.amber
        case .mixer:     return Ink.plum
        case .effect:    return Ink.steel
        case .synth:     return Ink.claySoft
        case .theory:    return Ink.concreteLo
        case .file:      return Ink.blackSoft
        }
    }
}

struct Term: Identifiable {
    let id: String
    let name: String
    let cat: TermCat
    var aka: [String] = []
    /// One line: what the thing is.
    let isA: String
    /// What it actually does to the sound or the session.
    let does: String
    /// The moment you'd reach for it.
    let when: String
    var found: [DAWLocation] = []
    var related: [String] = []

    var searchText: String {
        ([name, isA, does, when, cat.rawValue] + aka).joined(separator: " ").lowercased()
    }
}

enum Glossary {
    static let terms: [Term] = GlossaryCore.terms + GlossaryMix.terms

    private static let index: [String: Term] = {
        Dictionary(terms.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
    }()

    static func term(_ id: String) -> Term? { index[id] }

    static func lookup(_ ids: [String]) -> [Term] { ids.compactMap { index[$0] } }

    static func search(_ query: String, category: TermCat?) -> [Term] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var result = terms
        if let category { result = result.filter { $0.cat == category } }
        guard !q.isEmpty else {
            return result.sorted { $0.name < $1.name }
        }
        return result
            .filter { $0.searchText.contains(q) }
            .sorted { a, b in
                // Exact and prefix matches on the name float to the top.
                let an = a.name.lowercased(), bn = b.name.lowercased()
                let ap = an.hasPrefix(q), bp = bn.hasPrefix(q)
                if ap != bp { return ap }
                return an < bn
            }
    }
}
