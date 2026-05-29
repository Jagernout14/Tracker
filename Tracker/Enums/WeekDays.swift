enum WeekDays: Int, CaseIterable {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var displayName: String {
        switch self {
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }
    }
}
