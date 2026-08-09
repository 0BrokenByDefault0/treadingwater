import SwiftUI

struct LessonView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var store: Store
    var lesson: Lesson

    @State var openTerm: Term? = nil

    private var stage: Stage? { Curriculum.stage(for: lesson.id) }

    var body: some View {
        Sheet(serial: lesson.id.uppercased(),
              kicker: stage?.title ?? "LESSON",
              title: lesson.title,
              subtitle: nil) {

            HStack(spacing: 8) {
                Tag(text: lesson.kicker, tint: stage?.level.tint ?? theme.accent)
                Caption("\(lesson.minutes) MIN READ")
                Spacer()
            }

            ForEach(Array(lesson.blocks.enumerated()), id: \.offset) { _, block in
                blockView(block)
            }

            completionPanel
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $openTerm) { term in
            TermDetailView(term: term)
                .environmentObject(theme)
        }
        .onAppear { store.lastLesson = lesson.id }
    }

    // MARK: Blocks

    @ViewBuilder
    private func blockView(_ block: Block) -> some View {
        switch block {

        case .text(let s):
            Text(s)
                .font(TW.body())
                .foregroundStyle(theme.fg)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .heading(let s):
            HStack(spacing: 8) {
                Rectangle().frame(width: 14, height: 3).foregroundStyle(theme.accent)
                Text(s.uppercased())
                    .font(TW.wide(14, .black))
                    .foregroundStyle(theme.fg)
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.35))
            }
            .padding(.top, 4)

        case .bullets(let items):
            Panel(padded: true) {
                VStack(alignment: .leading, spacing: 9) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        HStack(alignment: .top, spacing: 8) {
                            Rectangle()
                                .frame(width: 6, height: 6)
                                .foregroundStyle(theme.accent)
                                .padding(.top, 5)
                            Text(item)
                                .font(TW.body(14.5))
                                .foregroundStyle(theme.fg)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

        case .steps(let items):
            Panel(serial: "SEQ", title: "DO THIS, IN THIS ORDER") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                        HStack(alignment: .top, spacing: 9) {
                            Text(String.serial(i + 1, 2))
                                .font(TW.label(10))
                                .foregroundStyle(theme.bg)
                                .frame(width: 22, height: 18)
                                .background(theme.fg)
                            Text(item)
                                .font(TW.body(14.5))
                                .foregroundStyle(theme.fg)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

        case .callout(let kind, let title, let body):
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text(kind.label)
                        .font(TW.label(8.5)).tracking(1.4)
                        .foregroundStyle(theme.bg)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(kind.tint)
                    Text(title.uppercased())
                        .font(TW.wide(11, .heavy)).tracking(0.5)
                        .foregroundStyle(theme.fg)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                .padding(.bottom, 6)

                Text(body)
                    .font(TW.body(14.5))
                    .foregroundStyle(theme.fg)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .background(kind.tint.opacity(theme.night ? 0.14 : 0.10))
            .overlay(alignment: .leading) {
                Rectangle().frame(width: 3).foregroundStyle(kind.tint)
            }
            .overlay(Rectangle().strokeBorder(kind.tint.opacity(0.5), lineWidth: 1))

        case .pattern(let caption, let beat):
            PatternPlayer(beat: beat, caption: caption)

        case .lab(let kind, let instruction):
            NavigationLink {
                switch kind {
                case .drums:     DrumLabView()
                case .pianoRoll: PianoRollView()
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Caption("HANDS ON", color: theme.onAccent)
                        Spacer()
                        Text("→").font(TW.wide(14, .black)).foregroundStyle(theme.onAccent)
                    }
                    Text(kind.title)
                        .font(TW.wide(17, .black))
                        .foregroundStyle(theme.onAccent)
                    Text(instruction)
                        .font(TW.body(13.5))
                        .foregroundStyle(theme.onAccent.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Ink.black)
            }
            .buttonStyle(.plain)

        case .terms(let ids):
            let terms = Glossary.lookup(ids)
            if !terms.isEmpty {
                Panel(serial: "REF", title: "TERMS IN THIS LESSON") {
                    FlowChips(terms: terms) { openTerm = $0 }
                }
            }

        case .dawPaths(let locations):
            Panel(serial: "LOC", title: "WHERE IT LIVES") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(locations) { loc in
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

        case .compare(let aTitle, let aBody, let bTitle, let bBody):
            HStack(alignment: .top, spacing: 8) {
                comparePane(aTitle, aBody, theme.accent)
                comparePane(bTitle, bBody, theme.accent2)
            }

        case .dial(let title, let points):
            Panel(serial: "SCL", title: title) {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(Array(points.enumerated()), id: \.offset) { i, point in
                        HStack(alignment: .top, spacing: 8) {
                            Rectangle()
                                .frame(width: 3, height: 14)
                                .foregroundStyle(dialTint(i, points.count))
                            Text(point)
                                .font(TW.mono(12))
                                .foregroundStyle(theme.fg)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private func comparePane(_ title: String, _ body: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(TW.wide(11, .black)).tracking(0.6)
                .foregroundStyle(theme.bg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 7).padding(.vertical, 4)
                .background(tint)
            Text(body)
                .font(TW.body(13))
                .foregroundStyle(theme.fg)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }

    private func dialTint(_ i: Int, _ total: Int) -> Color {
        let ramp = [Ink.steel, Ink.plum, Ink.clay, Ink.orange, Ink.amber]
        guard total > 1 else { return ramp[0] }
        let idx = Int(Double(i) / Double(total - 1) * Double(ramp.count - 1))
        return ramp[min(ramp.count - 1, max(0, idx))]
    }

    // MARK: Completion

    private var completionPanel: some View {
        VStack(spacing: 10) {
            Button {
                store.toggle(lesson.id)
            } label: {
                HStack {
                    Text(store.isDone(lesson.id) ? "✓ COMPLETED" : "MARK COMPLETE")
                        .font(TW.wide(13, .heavy)).tracking(0.8)
                    Spacer()
                }
                .foregroundStyle(store.isDone(lesson.id) ? theme.onAccent : theme.fg)
                .padding(.horizontal, 12).padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(store.isDone(lesson.id) ? theme.accent : Color.clear)
                .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
            }
            .buttonStyle(.plain)

            if let next = Curriculum.next(after: lesson.id) {
                NavigationLink {
                    LessonView(lesson: next)
                } label: {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Caption("NEXT")
                            Text(next.title)
                                .font(TW.wide(13, .heavy))
                                .foregroundStyle(theme.fg)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Text("→").font(TW.wide(15, .black)).foregroundStyle(theme.fg)
                    }
                    .padding(11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.panel)
                    .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Term chips

struct FlowChips: View {
    @EnvironmentObject var theme: Theme
    var terms: [Term]
    var onTap: (Term) -> Void

    let columns = [GridItem(.adaptive(minimum: 96), spacing: 6)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
            ForEach(terms) { term in
                Button { onTap(term) } label: {
                    Text(term.name)
                        .font(TW.label(9)).tracking(0.8)
                        .foregroundStyle(theme.fg)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .overlay(Rectangle().strokeBorder(term.cat.tint, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
