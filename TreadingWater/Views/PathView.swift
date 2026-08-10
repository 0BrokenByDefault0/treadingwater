import SwiftUI

struct PathView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var store: Store

    var body: some View {
        ZStack(alignment: .top) {
            theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    masthead
                    progressPanel
                    if let next = store.upNext { upNextPanel(next) }
                    stageList
                    footer
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
                .padding(.bottom, 130)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: Masthead

    private var masthead: some View {
        VStack(spacing: 0) {
            HStack {
                Caption("N°001")
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                Caption("MUSIC PRODUCTION MANUAL")
                Button { theme.night.toggle() } label: {
                    Text(theme.night ? "DAY" : "NIGHT")
                        .font(TW.label(8.5))
                        .tracking(1.2)
                        .foregroundStyle(theme.bg)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(theme.fg)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)

            DisplayTitle(text: "TREADING", size: 52)
            DisplayTitle(text: "WATER", size: 52, color: theme.accent)

            HStack(spacing: 8) {
                Text("BEGINNER → EXPERT")
                    .font(TW.label(9)).tracking(1.6)
                    .foregroundStyle(theme.fgMuted)
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                Barcode(seed: "treadingwater", height: 16)
                    .frame(width: 90)
            }
            .padding(.top, 4)

            SwatchStrip().padding(.top, 8)
        }
    }

    // MARK: Progress

    private var progressPanel: some View {
        Panel(serial: "PRG", title: "YOUR POSITION", trailing: "\(store.doneCount)/\(store.totalCount)") {
            VStack(alignment: .leading, spacing: 10) {
                MeterBar(value: store.overallProgress, segments: 32)
                HStack(spacing: 12) {
                    Readout(label: "COMPLETE", value: "\(Int(store.overallProgress * 100))%", tint: theme.accent)
                    Readout(label: "LESSONS", value: "\(store.doneCount) OF \(store.totalCount)")
                    Readout(label: "STAGES", value: "\(Curriculum.stages.count)")
                }
            }
        }
    }

    // MARK: Up next

    private func upNextPanel(_ lesson: Lesson) -> some View {
        let stage = Curriculum.stage(for: lesson.id)
        return Panel(serial: "NXT", title: "UP NEXT", tint: theme.accent) {
            VStack(alignment: .leading, spacing: 10) {
                Caption(stage.map { "STAGE \(String.serial($0.number, 2)) · \($0.title)" } ?? "")
                Text(lesson.title)
                    .font(TW.wide(21, .black))
                    .foregroundStyle(theme.fg)
                    .fixedSize(horizontal: false, vertical: true)
                Text(lesson.kicker)
                    .font(TW.label(9)).tracking(1.3)
                    .foregroundStyle(theme.fgMuted)
                NavigationLink {
                    LessonView(lesson: lesson)
                } label: {
                    HStack {
                        Text("START · \(lesson.minutes) MIN")
                            .font(TW.wide(12, .heavy)).tracking(0.6)
                        Spacer()
                        Text("→").font(TW.wide(14, .black))
                    }
                    .foregroundStyle(theme.onAccent)
                    .padding(.horizontal, 12).padding(.vertical, 11)
                    .background(theme.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Stages

    private var stageList: some View {
        VStack(spacing: 12) {
            HStack {
                Caption("THE PATH")
                Rectangle().frame(height: 1).foregroundStyle(theme.rule.opacity(0.4))
                Caption("SIX STAGES")
            }
            ForEach(Curriculum.stages) { stage in
                NavigationLink {
                    StageView(stage: stage)
                } label: {
                    StageCard(stage: stage, progress: store.progress(for: stage))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Ticker(text: "OPEN MID-SESSION · FIND THE ANSWER · GET BACK TO THE DAW", repeats: 3)
            HStack(spacing: 8) {
                Barcode(seed: "footer-tw", height: 20)
                Caption("CTRL 025763901370")
            }
        }
    }
}

// MARK: - Stage card

struct StageCard: View {
    @EnvironmentObject var theme: Theme
    var stage: Stage
    var progress: Double

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(String.serial(stage.number, 2))
                    .font(TW.display(30))
                    .foregroundStyle(theme.bg)
                    .frame(width: 52, height: 52)
                    .background(stage.level.tint)

                VStack(alignment: .leading, spacing: 3) {
                    Text(stage.title)
                        .font(TW.wide(17, .black))
                        .foregroundStyle(theme.fg)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(stage.subtitle)
                        .font(TW.body(12.5))
                        .foregroundStyle(theme.fgMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                Spacer(minLength: 4)
                Text("→")
                    .font(TW.wide(16, .black))
                    .foregroundStyle(theme.fg)
            }
            .padding(10)

            HStack(spacing: 8) {
                Tag(text: stage.level.rawValue, tint: stage.level.tint)
                Caption("\(stage.lessons.count) LESSONS")
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(TW.mono(10, .bold))
                    .foregroundStyle(progress >= 1 ? theme.accent : theme.fgMuted)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)

            MeterBar(value: progress, segments: 40, tint: stage.level.tint)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
        }
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }
}
