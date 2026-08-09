import SwiftUI

/// The DAW decoder. Type a control name you don't recognise, get what it is,
/// what it does, when you'd use it, and where it lives in your DAW.
struct DecodeView: View {
    @EnvironmentObject var theme: Theme
    @State var query = ""
    @State var category: TermCat? = nil
    @State var openTerm: Term? = nil
    @FocusState var searchFocused: Bool

    private var results: [Term] {
        Glossary.search(query, category: category)
    }

    var body: some View {
        ZStack(alignment: .top) {
            theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                categoryRail

                ScrollView {
                    LazyVStack(spacing: 8) {
                        if results.isEmpty {
                            emptyState
                        } else {
                            ForEach(results) { term in
                                Button { openTerm = term } label: {
                                    TermRow(term: term)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 130)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $openTerm) { term in
            TermDetailView(term: term).environmentObject(theme)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Caption("N°003")
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                Caption("\(Glossary.terms.count) ENTRIES")
            }
            DisplayTitle(text: "DECODER", size: 40)
            Text("What is this button and when would I press it.")
                .font(TW.body(13.5))
                .foregroundStyle(theme.fgMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Text("SEARCH")
                    .font(TW.label(9)).tracking(1.2)
                    .foregroundStyle(theme.bg)
                    .padding(.horizontal, 8)
                    .frame(height: 38)
                    .background(theme.fg)

                TextField("", text: $query, prompt:
                    Text("COMPRESSOR, SIDECHAIN, LUFS…")
                        .font(TW.mono(12))
                        .foregroundColor(theme.fgMuted)
                )
                .font(TW.mono(13))
                .foregroundStyle(theme.fg)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($searchFocused)
                .padding(.horizontal, 8)
                .frame(height: 38)

                if !query.isEmpty {
                    Button { query = "" } label: {
                        Text("✕")
                            .font(TW.wide(12, .black))
                            .foregroundStyle(theme.fg)
                            .frame(width: 36, height: 38)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(theme.panel)
            .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 8)
    }

    private var categoryRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                Button { category = nil } label: {
                    Tag(text: "ALL", filled: category == nil)
                }
                .buttonStyle(.plain)

                ForEach(TermCat.allCases) { cat in
                    Button {
                        category = (category == cat) ? nil : cat
                    } label: {
                        Tag(text: cat.rawValue, filled: category == cat, tint: cat.tint)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 8)
        }
    }

    private var emptyState: some View {
        Panel(serial: "404", title: "NOTHING MATCHED") {
            VStack(alignment: .leading, spacing: 8) {
                Text("No entry for “\(query)”.")
                    .font(TW.body(14))
                    .foregroundStyle(theme.fg)
                Text("Try the plain-English version — 'ducking' instead of a plugin name, or 'muddy' instead of a frequency. The STUCK tab covers symptoms rather than controls.")
                    .font(TW.body(13))
                    .foregroundStyle(theme.fgMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Row

struct TermRow: View {
    @EnvironmentObject var theme: Theme
    var term: Term

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle()
                .frame(width: 4)
                .foregroundStyle(term.cat.tint)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(term.name)
                        .font(TW.wide(13.5, .black)).tracking(0.4)
                        .foregroundStyle(theme.fg)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 4)
                    Caption(term.cat.rawValue, color: term.cat.tint)
                }
                Text(term.isA)
                    .font(TW.body(13))
                    .foregroundStyle(theme.fgMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 9)
            .padding(.trailing, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }
}

// MARK: - Detail

struct TermDetailView: View {
    @EnvironmentObject var theme: Theme
    @Environment(\.dismiss) var dismiss

    /// Presented as a sheet, so "see also" swaps the content in place rather
    /// than pushing — there's no navigation stack inside a sheet.
    @State var term: Term
    @State var trail: [Term] = []

    init(term: Term) {
        _term = State(initialValue: term)
    }

    var body: some View {
        ZStack(alignment: .top) {
            theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    header

                    field("WHAT IT IS", term.isA, theme.fg)
                    field("WHAT IT DOES", term.does, theme.accent2)
                    field("WHEN YOU'D USE IT", term.when, theme.accent)

                    if !term.found.isEmpty {
                        Panel(serial: "LOC", title: "WHERE IT LIVES") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(term.found) { loc in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text(loc.daw)
                                            .font(TW.label(9)).tracking(1.0)
                                            .foregroundStyle(theme.bg)
                                            .frame(width: 74, alignment: .leading)
                                            .padding(.horizontal, 5).padding(.vertical, 3)
                                            .background(theme.fg)
                                        Text(loc.path)
                                            .font(TW.mono(11.5))
                                            .foregroundStyle(theme.fg)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }

                    let related = Glossary.lookup(term.related)
                    if !related.isEmpty {
                        Panel(serial: "REL", title: "SEE ALSO") {
                            VStack(spacing: 6) {
                                ForEach(related) { r in
                                    Button {
                                        trail.append(term)
                                        term = r
                                    } label: {
                                        HStack {
                                            Text(r.name)
                                                .font(TW.label(10)).tracking(0.8)
                                                .foregroundStyle(theme.fg)
                                            Spacer()
                                            Text("→").font(TW.wide(12, .black))
                                                .foregroundStyle(r.cat.tint)
                                        }
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 8)
                                        .overlay(Rectangle().strokeBorder(theme.rule.opacity(0.4), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    Ticker(text: term.name, repeats: 5, background: term.cat.tint)
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 6) {
                if let previous = trail.last {
                    Button {
                        term = previous
                        trail.removeLast()
                    } label: {
                        Text("←")
                            .font(TW.wide(13, .black))
                            .foregroundStyle(theme.fg)
                            .frame(width: 34, height: 30)
                            .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
                    }
                    .buttonStyle(.plain)
                }
                Button { dismiss() } label: {
                    Text("✕")
                        .font(TW.wide(13, .black))
                        .foregroundStyle(theme.bg)
                        .frame(width: 34, height: 30)
                        .background(theme.fg)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 14)
            .padding(.top, 12)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Caption(term.cat.rawValue, color: term.cat.tint)
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
            }
            .padding(.trailing, 44)

            DisplayTitle(text: term.name, size: 32)

            if !term.aka.isEmpty {
                Text("AKA " + term.aka.joined(separator: " · ").uppercased())
                    .font(TW.label(9)).tracking(1.2)
                    .foregroundStyle(theme.fgMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            SwatchStrip(colors: [term.cat.tint, theme.fill, Ink.orange, Ink.clay, Ink.black], height: 6)
        }
    }

    private func field(_ label: String, _ body: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Rectangle().frame(width: 10, height: 3).foregroundStyle(tint)
                Caption(label, color: tint)
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.25))
            }
            Text(body)
                .font(TW.body(15))
                .foregroundStyle(theme.fg)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(11)
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }
}
