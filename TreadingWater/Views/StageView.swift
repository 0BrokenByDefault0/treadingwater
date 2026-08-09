import SwiftUI

struct StageView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var store: Store
    var stage: Stage

    var body: some View {
        Sheet(serial: String.serial(stage.number, 3),
              kicker: stage.level.rawValue,
              title: stage.title,
              subtitle: stage.subtitle) {

            Panel(serial: "PRG", title: "STAGE PROGRESS",
                  trailing: "\(doneCount)/\(stage.lessons.count)") {
                MeterBar(value: store.progress(for: stage), segments: 32, tint: stage.level.tint)
            }

            VStack(spacing: 10) {
                ForEach(Array(stage.lessons.enumerated()), id: \.element.id) { index, lesson in
                    NavigationLink {
                        LessonView(lesson: lesson)
                    } label: {
                        LessonRow(index: index + 1, lesson: lesson,
                                  done: store.isDone(lesson.id), tint: stage.level.tint)
                    }
                    .buttonStyle(.plain)
                }
            }

            Ticker(text: "\(stage.title) · \(stage.level.rawValue)", repeats: 4,
                   background: stage.level.tint)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(theme.bg, for: .navigationBar)
    }

    private var doneCount: Int {
        stage.lessons.filter { store.isDone($0.id) }.count
    }
}

struct LessonRow: View {
    @EnvironmentObject var theme: Theme
    var index: Int
    var lesson: Lesson
    var done: Bool
    var tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(String.serial(index, 2))
                .font(TW.wide(15, .black))
                .foregroundStyle(done ? theme.bg : theme.fg)
                .frame(width: 34, height: 40)
                .background(done ? tint : Color.clear)
                .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                    .font(TW.wide(13.5, .heavy))
                    .foregroundStyle(theme.fg)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Text(lesson.kicker)
                    .font(TW.label(8.5)).tracking(1.1)
                    .foregroundStyle(theme.fgMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(lesson.minutes)′")
                    .font(TW.mono(11, .semibold))
                    .foregroundStyle(theme.fgMuted)
                Text(done ? "✓" : "→")
                    .font(TW.wide(13, .black))
                    .foregroundStyle(done ? tint : theme.fg)
            }
        }
        .padding(9)
        .background(theme.panel)
        .overlay(Rectangle().strokeBorder(theme.rule, lineWidth: 1.2))
    }
}
