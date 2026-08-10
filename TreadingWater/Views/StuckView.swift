import SwiftUI

/// The reason the app exists: you're mid-session, something's wrong, and you
/// need one specific answer in under thirty seconds.
struct StuckView: View {
    @EnvironmentObject var theme: Theme
    @State var query = ""
    @State var openFix: Fix? = nil

    private var searchResults: [Fix] { Troubleshoot.search(query) }

    var body: some View {
        ZStack(alignment: .top) {
            theme.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    header

                    if !query.isEmpty {
                        if searchResults.isEmpty {
                            Panel(serial: "404", title: "NOTHING MATCHED") {
                                Text("Try a symptom in plain words — 'muddy', 'boring', 'thin', 'can't finish'. Or search the DECODE tab for a specific control.")
                                    .font(TW.body(14))
                                    .foregroundStyle(theme.fg)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        } else {
                            VStack(spacing: 8) {
                                ForEach(searchResults) { fix in
                                    Button { openFix = fix } label: {
                                        FixRow(fix: fix, tint: theme.accent)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    } else {
                        ForEach(Troubleshoot.groups) { group in
                            groupPanel(group)
                        }
                        Ticker(text: "GRAB THE PHONE · FIND THE ANSWER · GET BACK TO THE DAW", repeats: 3)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
                .padding(.bottom, 130)
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $openFix) { fix in
            FixDetailView(fix: fix).environmentObject(theme)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Caption("N°005")
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                Caption("\(Troubleshoot.allFixes.count) ANSWERS")
            }
            DisplayTitle(text: "STUCK", size: 52, color: theme.accent)
            Text("Symptom in, next action out.")
                .font(TW.body(14))
                .foregroundStyle(theme.fgMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Text("WHAT'S WRONG")
                    .font(TW.label(9)).tracking(1.2)
                    .foregroundStyle(theme.bg)
                    .padding(.horizontal, 8)
                    .frame(height: 38)
                    .background(theme.accent)

                TextField("", text: $query, prompt:
                    Text("MUDDY, BORING, NO PUNCH…")
                        .font(TW.mono(12))
                        .foregroundColor(theme.fgMuted)
                )
                .font(TW.mono(13))
                .foregroundStyle(theme.fg)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
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

            SwatchStrip()
        }
    }

    private func groupPanel(_ group: FixGroup) -> some View {
        Panel(serial: group.id.prefix(3).uppercased(), title: group.title,
              trailing: "\(group.fixes.count)", tint: group.tint) {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.blurb)
                    .font(TW.body(13))
                    .foregroundStyle(theme.fgMuted)
                ForEach(group.fixes) { fix in
                    Button { openFix = fix } label: {
                        FixRow(fix: fix, tint: group.tint)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct FixRow: View {
    @EnvironmentObject var theme: Theme
    var fix: Fix
    var tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Rectangle().frame(width: 4).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(fix.title)
                    .font(TW.wide(12.5, .heavy)).tracking(0.4)
                    .foregroundStyle(theme.fg)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Text(fix.symptom)
                    .font(TW.body(12.5))
                    .foregroundStyle(theme.fgMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 4)
            Text("→")
                .font(TW.wide(13, .black))
                .foregroundStyle(tint)
                .padding(.top, 2)
        }
        .padding(.vertical, 8)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(Rectangle().strokeBorder(theme.rule.opacity(0.45), lineWidth: 1))
    }
}

// MARK: - Detail

struct FixDetailView: View {
    @EnvironmentObject var theme: Theme
    @Environment(\.dismiss) var dismiss
    var fix: Fix

    @State var openTerm: Term? = nil

    var body: some View {
        ZStack(alignment: .top) {
            theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Caption("FIX")
                            Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                        }
                        .padding(.trailing, 44)
                        DisplayTitle(text: fix.title, size: 26)
                        Text(fix.symptom)
                            .font(TW.body(14))
                            .foregroundStyle(theme.fgMuted)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        SwatchStrip(height: 6)
                    }

                    Panel(serial: "SEQ", title: "DO THIS, IN THIS ORDER", tint: theme.accent) {
                        VStack(alignment: .leading, spacing: 11) {
                            ForEach(Array(fix.steps.enumerated()), id: \.offset) { i, step in
                                HStack(alignment: .top, spacing: 9) {
                                    Text(String.serial(i + 1, 2))
                                        .font(TW.label(10))
                                        .foregroundStyle(theme.bg)
                                        .frame(width: 22, height: 18)
                                        .background(theme.accent)
                                    Text(step)
                                        .font(TW.body(15))
                                        .foregroundStyle(theme.fg)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }

                    Panel(serial: "WHY", title: "WHY THIS WORKS", tint: Ink.clay) {
                        Text(fix.why)
                            .font(TW.body(14.5))
                            .foregroundStyle(theme.fg)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    let terms = Glossary.lookup(fix.terms)
                    if !terms.isEmpty {
                        Panel(serial: "REF", title: "RELATED TERMS") {
                            FlowChips(terms: terms) { openTerm = $0 }
                        }
                    }

                    if let lessonID = fix.lesson, let lesson = Curriculum.lesson(lessonID) {
                        Panel(serial: "LSN", title: "FULL LESSON", tint: Ink.plum) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title)
                                    .font(TW.wide(14, .black))
                                    .foregroundStyle(theme.fg)
                                Text(lesson.kicker)
                                    .font(TW.label(9)).tracking(1.2)
                                    .foregroundStyle(theme.fgMuted)
                                Text("Open the PATH tab and find this lesson when you have \(lesson.minutes) minutes.")
                                    .font(TW.body(12.5))
                                    .foregroundStyle(theme.fgMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 2)
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("✕")
                    .font(TW.wide(13, .black))
                    .foregroundStyle(theme.bg)
                    .frame(width: 34, height: 30)
                    .background(theme.fg)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 14)
            .padding(.top, 12)
        }
        .sheet(item: $openTerm) { term in
            TermDetailView(term: term).environmentObject(theme)
        }
    }
}
